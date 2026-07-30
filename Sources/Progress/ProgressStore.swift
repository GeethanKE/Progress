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
    /// When true, once `endDate` passes, the whole start/end range shifts
    /// forward by whole days (preserving time-of-day) until it covers "now"
    /// again — so a midnight-midnight or 9-5 range keeps recurring instead
    /// of freezing at "Done" forever after the first day.
    @Published var repeatDaily: Bool {
        didSet { defaults.set(repeatDaily, forKey: Keys.repeatDaily) }
    }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let label = "progress.label"
        static let start = "progress.startDate"
        static let end = "progress.endDate"
        static let mode = "progress.displayMode"
        static let style = "progress.style"
        static let repeatDaily = "progress.repeatDaily"
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
        // Defaults to true: if the key has never been set, object(forKey:)
        // returns nil and `as? Bool` fails, so `?? true` kicks in.
        self.repeatDaily = defaults.object(forKey: Keys.repeatDaily) as? Bool ?? true
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

    /// Call this before reading `fraction`/`isComplete` for display. If
    /// `repeatDaily` is on and the current range has already ended, shifts
    /// `startDate`/`endDate` forward by whole days (via Calendar, so DST
    /// transitions are handled correctly) until the range covers "now"
    /// again. Safe to call every refresh tick — it's a no-op unless the
    /// range has actually elapsed.
    func rollForwardIfNeeded(now: Date = Date()) {
        guard repeatDaily else { return }
        guard now >= endDate else { return }

        let calendar = Calendar.current
        var newStart = startDate
        var newEnd = endDate
        var iterations = 0

        // Loop instead of a single jump so this recovers correctly even
        // after the Mac was asleep for multiple days.
        while newEnd <= now && iterations < 3650 {
            guard
                let nextStart = calendar.date(byAdding: .day, value: 1, to: newStart),
                let nextEnd = calendar.date(byAdding: .day, value: 1, to: newEnd)
            else { break }
            newStart = nextStart
            newEnd = nextEnd
            iterations += 1
        }

        if newStart != startDate {
            startDate = newStart
            endDate = newEnd
        }
    }
}
