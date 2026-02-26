import SwiftUI

// MARK: - Sleep ViewModel
@MainActor
class SleepViewModel: ObservableObject {
    @Published var todaySleep: SleepData
    @Published var weeklySleep: [SleepData] = []
    @Published var bedtime: Date = Calendar.current.date(bySettingHour: 22, minute: 30, second: 0, of: Date()) ?? Date()
    @Published var wakeTime: Date = Calendar.current.date(bySettingHour: 6, minute: 30, second: 0, of: Date()) ?? Date()
    
    private let defaults = UserDefaults.standard
    
    init() {
        self.todaySleep = .empty(for: Date())
        loadData()
        generateWeekly()
    }
    
    var sleepHours: Double {
        let diff = wakeTime.timeIntervalSince(bedtime)
        let hours = diff > 0 ? diff / 3600 : (diff + 86400) / 3600
        return min(max(hours, 0), 24)
    }
    
    var weeklyAverage: Double {
        guard !weeklySleep.isEmpty else { return 0 }
        return weeklySleep.reduce(0) { $0 + $1.hours } / Double(weeklySleep.count)
    }
    
    var chartData: [ChartDataPoint] {
        weeklySleep.map { ChartDataPoint(label: $0.date.singleLetterDay, value: $0.hours, date: $0.date) }
    }
    
    func logSleep(quality: SleepQuality) {
        todaySleep = SleepData(date: Date(), hours: sleepHours, quality: quality, bedtime: bedtime, wakeTime: wakeTime)
        saveSleep()
        
        if todaySleep.isGoalMet {
            GameEngineManager.shared.awardXP(amount: GameEngineManager.xpSleepGoalMet, source: "Sleep Goal", icon: "bed.double.fill")
        }
    }
    
    private func loadData() {
        let key = "sleep_\(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none))"
        if let data = defaults.data(forKey: key),
           let saved = try? JSONDecoder().decode(SleepData.self, from: data) {
            todaySleep = saved
        }
    }
    
    private func saveSleep() {
        let key = "sleep_\(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none))"
        if let data = try? JSONEncoder().encode(todaySleep) { defaults.set(data, forKey: key) }
    }
    
    private func generateWeekly() {
        weeklySleep = Date.lastSevenDays.map { date in
            if Calendar.current.isDateInToday(date) { return todaySleep }
            return SleepData(date: date, hours: Double.random(in: 5...9), quality: [.poor, .fair, .good, .excellent].randomElement()!)
        }
    }
}
