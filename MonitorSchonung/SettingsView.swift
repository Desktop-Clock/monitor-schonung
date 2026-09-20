import SwiftUI

struct SettingsView: View {
    @ObservedObject var controller: DimController

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("MonitorSchonung")
                    .font(.headline)
                Spacer()
                Toggle("Aktiv", isOn: $controller.isEnabled)
                    .toggleStyle(.switch)
            }

            Text(controller.statusText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            Picker("Monitor", selection: $controller.selectedDisplayUUID) {
                Text("Automatisch: PD3205U").tag("")
                ForEach(controller.displays.filter { !$0.isMain }) { display in
                    Text(display.menuTitle).tag(display.uuid)
                }
            }
            .disabled(controller.displays.isEmpty)

            Picker("Wartezeit", selection: $controller.idleMinutes) {
                Text("5 Minuten").tag(5)
                Text("10 Minuten").tag(10)
                Text("15 Minuten").tag(15)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Abdunklung")
                    Spacer()
                    Text("\(Int(controller.dimStrength * 100)) %")
                        .monospacedDigit()
                }
                Slider(value: $controller.dimStrength, in: 0.1...0.9, step: 0.05)
                    .accessibilityLabel("Abdunklung")
            }

            Divider()

            HStack {
                Text("Der Bildschirm bleibt bedienbar.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Beenden") { NSApplication.shared.terminate(nil) }
            }
        }
        .padding(16)
        .frame(width: 330)
    }
}
