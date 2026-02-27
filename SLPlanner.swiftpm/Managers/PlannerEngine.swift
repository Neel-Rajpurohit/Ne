import Foundation

// MARK: - Planner Engine
// Reads UserProfile → generates DailyRoutine automatically

@MainActor
class PlannerEngine: ObservableObject {
    static let shared = PlannerEngine()

    @Published var todayRoutine: DailyRoutine = DailyRoutine(date: Date(), blocks: [])

    private init() {
        // Note: Don't call generateToday() here to avoid circular
        // singleton initialization (PlannerEngine → ProfileManager → StorageManager).
        // DashboardView.onAppear calls generateToday() when the view loads.
    }

    func generateToday() {
        todayRoutine = generateRoutine(for: Date(), profile: ProfileManager.shared.profile)
    }

    func generateRoutine(for date: Date, profile: UserProfile) -> DailyRoutine {
        var blocks: [TimeBlock] = []

        // 1. Morning Exercise — 30 mins before Breakfast
        let exerciseStart = advanceTime(
            hour: profile.breakfastHour, minute: profile.breakfastMinute, byMinutes: -30)

        // 2. Wake Up — 15 mins before Breakfast
        let wakeStart = advanceTime(hour: exerciseStart.h, minute: exerciseStart.m, byMinutes: -15)

        blocks.append(
            TimeBlock(
                type: .wakeUp, startHour: wakeStart.h, startMinute: wakeStart.m,
                endHour: exerciseStart.h, endMinute: exerciseStart.m))
        blocks.append(
            TimeBlock(
                type: .exercise, startHour: exerciseStart.h, startMinute: exerciseStart.m,
                endHour: profile.breakfastHour, endMinute: profile.breakfastMinute))

        // 3. School / College
        let institutionType: BlockType = profile.institutionChoice == "College" ? .college : .school
        blocks.append(
            TimeBlock(
                type: institutionType, startHour: profile.schoolStartHour,
                startMinute: profile.schoolStartMinute, endHour: profile.schoolEndHour,
                endMinute: profile.schoolEndMinute))

        // 3. Rest after school — 30 min
        let restStartH = profile.schoolEndHour
        let restStartM = profile.schoolEndMinute
        let restEnd = advanceTime(hour: restStartH, minute: restStartM, byMinutes: 30)
        blocks.append(
            TimeBlock(
                type: .freeTime, subject: "Rest", startHour: restStartH, startMinute: restStartM,
                endHour: restEnd.h, endMinute: restEnd.m))

        // 4. Meal blocks — Breakfast, Lunch, Dinner
        let meals: [(String, Int, Int)] = [
            ("Breakfast", profile.breakfastHour, profile.breakfastMinute),
            ("Lunch", profile.lunchHour, profile.lunchMinute),
            ("Dinner", profile.dinnerHour, profile.dinnerMinute),
        ]
        for (name, mealH, mealM) in meals {
            let mealEnd = advanceTime(hour: mealH, minute: mealM, byMinutes: 30)
            blocks.append(
                TimeBlock(
                    type: .lunch, subject: name, startHour: mealH, startMinute: mealM,
                    endHour: mealEnd.h, endMinute: mealEnd.m))
        }

        // 5. Tuition (if applicable)
        if profile.hasTuition {
            blocks.append(
                TimeBlock(
                    type: .tuition, startHour: profile.tuitionStartHour,
                    startMinute: profile.tuitionStartMinute, endHour: profile.tuitionEndHour,
                    endMinute: profile.tuitionEndMinute))
        }

        // 6. Study blocks in the evening — distribute subjects
        // Each study block is a SINGLE card containing N Pomodoro cycles
        // (25 min study + 5 min break) × cycles — no separate break blocks
        let cycleStudy = profile.recommendedStudyMinutes  // 25 min default
        let cycleBreak = profile.recommendedBreakMinutes  // 5 min default
        let cyclesPerSubject = 2
        let sessionLength = (cycleStudy + cycleBreak) * cyclesPerSubject  // 60 min total

        // Find available evening time
        var studyStartH: Int
        var studyStartM: Int

        if profile.hasTuition {
            let afterTuition = advanceTime(
                hour: profile.tuitionEndHour, minute: profile.tuitionEndMinute, byMinutes: 15)
            studyStartH = afterTuition.h
            studyStartM = afterTuition.m
        } else {
            let afterLunch = advanceTime(
                hour: profile.lunchHour, minute: profile.lunchMinute + 30, byMinutes: 30)
            studyStartH = max(afterLunch.h, restEnd.h + 1)
            studyStartM = afterLunch.m
        }

        // Create ONE study block per subject (break is internal to the Pomodoro timer)
        let dailySubjects = Array(profile.subjects.prefix(3))
        for subject in dailySubjects {
            let sessionEnd = advanceTime(
                hour: studyStartH, minute: studyStartM, byMinutes: sessionLength)
            blocks.append(
                TimeBlock(
                    type: .study,
                    subject: subject,
                    startHour: studyStartH,
                    startMinute: studyStartM,
                    endHour: sessionEnd.h,
                    endMinute: sessionEnd.m,
                    cycles: cyclesPerSubject,
                    studyDuration: cycleStudy,
                    breakDuration: cycleBreak
                ))

            studyStartH = sessionEnd.h
            studyStartM = sessionEnd.m

            // Don't schedule past 21:00
            if studyStartH >= 21 { break }
        }

        // 7. Free Time / Relaxation

        // 8. Sleep
        blocks.append(
            TimeBlock(type: .sleep, startHour: 22, startMinute: 0, endHour: 6, endMinute: 0))

        // Sort by start time and remove overlaps
        blocks.sort { ($0.startHour * 60 + $0.startMinute) < ($1.startHour * 60 + $1.startMinute) }

        return DailyRoutine(date: date, blocks: blocks)
    }

    // MARK: - Helpers
    private func advanceTime(hour: Int, minute: Int, byMinutes: Int) -> (h: Int, m: Int) {
        var total = hour * 60 + minute + byMinutes
        if total < 0 { total += 24 * 60 }
        return ((total / 60) % 24, total % 60)
    }
}
