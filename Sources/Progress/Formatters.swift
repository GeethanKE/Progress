import Foundation

enum Formatters {
    static func percentString(_ fraction: Double) -> String {
        "\(Int((fraction * 100).rounded()))%"
    }

    static func remainingString(_ seconds: TimeInterval) -> String {
        if seconds <= 0 { return "Done" }
        let totalMinutes = Int(seconds / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
        return "\(max(minutes, 1))m"
    }

    /// Longer form used in the dropdown menu, e.g. "8 hrs 44 min".
    static func remainingLongString(_ seconds: TimeInterval) -> String {
        if seconds <= 0 { return "Done" }
        let totalMinutes = Int(seconds / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return minutes > 0 ? "\(hours) hrs \(minutes) min" : "\(hours) hrs"
        }
        return "\(max(minutes, 1)) min"
    }
}
