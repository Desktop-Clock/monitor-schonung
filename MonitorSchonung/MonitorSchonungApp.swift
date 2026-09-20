import SwiftUI

@main
struct MonitorSchonungApp: App {
    @StateObject private var controller = DimController()

    var body: some Scene {
        MenuBarExtra("MonitorSchonung", systemImage: controller.isEnabled ? "display" : "display.slash") {
            SettingsView(controller: controller)
        }
        .menuBarExtraStyle(.window)
    }
}
