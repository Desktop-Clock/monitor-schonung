import AppKit
import CoreGraphics

struct DisplayInfo: Identifiable, Equatable {
    let id: CGDirectDisplayID
    let uuid: String
    let name: String
    let isMain: Bool
    let screen: NSScreen

    var menuTitle: String {
        "\(name)\(isMain ? " (Hauptmonitor)" : "")"
    }

    static func == (lhs: DisplayInfo, rhs: DisplayInfo) -> Bool {
        lhs.id == rhs.id && lhs.uuid == rhs.uuid && lhs.name == rhs.name && lhs.isMain == rhs.isMain
    }

    static func connected() -> [DisplayInfo] {
        NSScreen.screens.compactMap { screen -> DisplayInfo? in
            guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
                return nil
            }
            let id = CGDirectDisplayID(number.uint32Value)
            guard let displayUUID = CGDisplayCreateUUIDFromDisplayID(id) else { return nil }
            let uuid = CFUUIDCreateString(nil, displayUUID.takeRetainedValue()) as String
            return DisplayInfo(
                id: id,
                uuid: uuid,
                name: screen.localizedName,
                isMain: id == CGMainDisplayID(),
                screen: screen
            )
        }
    }
}
