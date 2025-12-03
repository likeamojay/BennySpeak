//
//  JLAnalytics.swift
//  iOS Platform Assessment
//
//  Created by James Lane on 7/20/25.
//
import Foundation
import AVFoundation

class JLAnalytics {

    static let shared = JLAnalytics()

    private var startTimes: [String: Double] = [:]
    private let defaults = UserDefaults.standard

    private var recordedKeys: Set<String> = [] // Track to avoid duplicate metrics

    // MARK: - Public API

    func markStartTime(for key: String) {
        self.startTimes[key] = CACurrentMediaTime()
    }

    func markStopTime(for key: String) {
        guard let start = startTimes[key], !recordedKeys.contains(key) else { return }
        self.recordedKeys.insert(key)
        let duration = CACurrentMediaTime() - start
        self.saveToDisk(duration: duration, for: key)
    }

    func saveReport() {
        let durationsByKey = readAllDurations()

        var report: [String: Any] = [:]

        // Include raw durations
        report["durations"] = durationsByKey

        // Add per-metric averages
        var averages: [String: Double] = [:]
        for (key, durations) in durationsByKey {
            guard !durations.isEmpty else { continue }
            let avg = durations.reduce(0, +) / Double(durations.count)
            averages[key] = avg
        }
        report["averages"] = averages

        // Add ISO timestamp for the report creation date
        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        report["timestamp"] = timestamp

        guard let data = try? JSONSerialization.data(withJSONObject: report, options: .prettyPrinted) else {
            print("JLAnalytics: failed to encode report JSON")
            return
        }

        let filename = "performance_report_\(timestamp).json"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(filename)

        try? data.write(to: url, options: .atomic)
        print("JLAnalytics: report saved to \(url.path)")
    
        self.clearSavedData()
    }

    func resetLaunchState() {
        self.recordedKeys.removeAll()
    }

    func clearSavedData() {
        for key in self.defaults.dictionaryRepresentation().keys {
            self.defaults.removeObject(forKey: key)
        }
        print("JLAnalytics: cleared saved durations")
    }

    // MARK: - Private helpers

    private func saveToDisk(duration: TimeInterval, for key: String) {
        var durations = defaults.array(forKey: key) as? [Double] ?? []
        durations.append(duration)
        self.defaults.set(durations, forKey: key)
        print("JLAnalytics: recorded \(duration)s for \(key) (\(durations.count) samples total)")
    }

    private func readAllDurations() -> [String: [Double]] {
        var result: [String: [Double]] = [:]
        for (key, value) in self.defaults.dictionaryRepresentation() {
            if let durations = value as? [Double] {
                result[key] = durations
            }
        }
        return result
    }
}
