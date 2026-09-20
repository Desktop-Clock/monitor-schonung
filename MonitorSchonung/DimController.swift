import AppKit
import Combine

@MainActor
final class DimController: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            defaults.set(isEnabled, forKey: Keys.enabled)
            lastOnTarget = Date()
            refresh()
        }
    }
    @Published var idleMinutes: Int {
        didSet { defaults.set(idleMinutes, forKey: Keys.idle); refresh() }
    }
    @Published var dimStrength: Double {
        didSet { defaults.set(dimStrength, forKey: Keys.strength); refresh() }
    }
    @Published var selectedDisplayUUID: String {
        didSet { defaults.set(selectedDisplayUUID, forKey: Keys.display); refresh() }
    }
    @Published private(set) var displays: [DisplayInfo] = []
    @Published private(set) var statusText = "Suche Monitore …"

    private enum Keys {
        static let enabled = "enabled"
        static let idle = "idleMinutes"
        static let strength = "dimStrength"
        static let display = "selectedDisplayUUID"
    }

    private let defaults = UserDefaults.standard
    private var overlay: DimOverlayWindow?
    private var timer: Timer?
    private var screenObserver: NSObjectProtocol?
    private var targetID: CGDirectDisplayID?
    private var lastOnTarget = Date()
    private var fadeStarted: Date?
    private let fadeDuration: TimeInterval = 0.8

    init() {
        isEnabled = defaults.object(forKey: Keys.enabled) as? Bool ?? true
        let savedIdle = defaults.integer(forKey: Keys.idle)
        idleMinutes = [5, 10, 15].contains(savedIdle) ? savedIdle : 10
        let savedStrength = defaults.object(forKey: Keys.strength) as? Double ?? 0.65
        dimStrength = min(max(savedStrength, 0.1), 0.9)
        selectedDisplayUUID = defaults.string(forKey: Keys.display) ?? ""

        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refreshDisplays() }
        }
        refreshDisplays()
        let timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func refreshDisplays() {
        displays = DisplayInfo.connected()
        refresh()
    }

    private func chosenDisplay() -> DisplayInfo? {
        if !selectedDisplayUUID.isEmpty {
            return displays.first { $0.uuid == selectedDisplayUUID && !$0.isMain }
        }
        let matches = displays.filter {
            !$0.isMain && $0.name.localizedCaseInsensitiveContains("PD3205U")
        }
        return matches.count == 1 ? matches[0] : nil
    }

    private func refresh() {
        let target = chosenDisplay()
        if targetID != target?.id {
            overlay?.orderOut(nil)
            overlay = nil
            targetID = target?.id
            lastOnTarget = Date()
            fadeStarted = nil
        }

        if let target {
            if overlay == nil {
                overlay = DimOverlayWindow(screen: target.screen)
            } else {
                overlay?.setFrame(target.screen.frame, display: false)
            }
        } else {
            overlay?.orderOut(nil)
            overlay = nil
        }

        if !isEnabled {
            overlay?.orderOut(nil)
            fadeStarted = nil
            statusText = "Deaktiviert"
        } else if target == nil {
            statusText = selectedDisplayUUID.isEmpty
                ? "PD3205U nicht eindeutig gefunden. Bitte Monitor auswählen."
                : "Gewählter Monitor nicht verbunden. Bitte Monitor neu auswählen."
        } else {
            statusText = "Bereit: \(target!.name)"
        }
    }

    private func tick() {
        guard isEnabled, let target = chosenDisplay(), let overlay else { return }
        let now = Date()
        if target.screen.frame.contains(NSEvent.mouseLocation) {
            lastOnTarget = now
            fadeStarted = nil
            if overlay.isVisible { overlay.orderOut(nil) }
            overlay.alphaValue = 0
            return
        }

        guard now.timeIntervalSince(lastOnTarget) >= Double(idleMinutes * 60) else {
            if overlay.isVisible { overlay.orderOut(nil) }
            return
        }

        if fadeStarted == nil {
            fadeStarted = now
            overlay.alphaValue = 0
            overlay.orderFrontRegardless()
        }
        let progress = min(now.timeIntervalSince(fadeStarted!) / fadeDuration, 1)
        overlay.alphaValue = CGFloat(dimStrength * progress)
    }
}
