import SwiftUI

/// Content of the "Settings…" window. Display mode (Percent / Time Left) and
/// icon style (Pie / Bar) live in the status item's "More" submenu instead,
/// matching native menu bar app conventions.
struct SettingsView: View {
    @EnvironmentObject var store: ProgressStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Label").font(.caption).foregroundColor(.secondary)
                TextField("end of day", text: $store.label)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Start").font(.caption).foregroundColor(.secondary)
                DatePicker("", selection: $store.startDate)
                    .labelsHidden()
                    .datePickerStyle(.compact)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("End").font(.caption).foregroundColor(.secondary)
                DatePicker("", selection: $store.endDate)
                    .labelsHidden()
                    .datePickerStyle(.compact)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 260, height: 200)
    }
}
