import Foundation
import Combine

enum DisplayMode: String, CaseIterable, Identifiable {
    case percentage = "Percent"
    case remainingMinutes = "Time Left"
    var id: String { rawValue }
}

enum ProgressStyle: String, CaseIterable, Identifiable {
    case pie = "Pie"
    case bar = "Bar"
    var id: String { rawValue }
}

/// Holds user-configurable state (start/end time, display preferences) and
/// persists it to UserDefaults so settings survive relaunches.
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published var label: String {
        didSet { defaults.set(label, forKey: Keys.label) }
    }
    @Published var startDate: Date {
        didSet { defaults.set(startDate, forKey: Keys.start) }
    }
    @Published var endDate: Date {
        didSet { defaults.set(endDate, forKey: Keys.end) }
    }
    @Published var displayMode: DisplayMode {
        didSet { defaults.set(displayMode.rawValue, forKey: Keys.mode) }
    }
    @Published var style: ProgressStyle {
        didSet { defaults.set(style.rawValue, forKey: Keys.style) }
    }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let label = "progress.label"
        static let start = "progress.startDate"
        static let end = "progress.endDate"
        static let mode = "progress.displayMode"
        static let style = "progress.style"
    }

    private init() {
        let calendar = Calendar.current
        let now = Date()

        // Default range: 12:00 AM today -> 11:59:59 PM today, so the icon
        // naturally fills up as the whole day passes.
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfToday) ?? now

        self.label = defaults.string(forKey: Keys.label) ?? "end of day"
        self.startDate = defaults.object(forKey: Keys.start) as? Date ?? startOfToday
        self.endDate = defaults.object(forKey: Keys.end) as? Date ?? endOfToday
        self.displayMode = DisplayMode(rawValue: defaults.string(forKey: Keys.mode) ?? "") ?? .percentage
        self.style = ProgressStyle(rawValue: defaults.string(forKey: Keys.style) ?? "") ?? .pie
    }

    /// 0...1 fraction of elapsed time between startDate and endDate.
    var fraction: Double {
        let total = endDate.timeIntervalSince(startDate)
        guard total > 0 else { return isComplete ? 1 : 0 }
        let elapsed = Date().timeIntervalSince(startDate)
        return min(max(elapsed / total, 0), 1)
    }

    var remainingSeconds: TimeInterval {
        max(endDate.timeIntervalSinceNow, 0)
    }

    var isComplete: Bool { Date() >= endDate }
    var isBeforeStart: Bool { Date() < startDate }
}
