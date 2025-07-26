import SwiftUI
import Foundation

@MainActor
class FitnessTrackerViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var todaysWorkouts: [Workout] = []
    @Published var selectedDate = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddWorkout = false
    @Published var selectedWorkoutType = Workout.WorkoutType.cardio
    @Published var availableExercises = Exercise.sampleExercises
    @Published var activeWorkout: Workout?
    @Published var workoutStartTime: Date?
    
    init() {
        loadWorkouts()
        updateTodaysWorkouts()
    }
    
    // MARK: - Data Management
    
    func loadWorkouts() {
        isLoading = true
        
        // Load workouts from UserDefaults (in a real app, you'd use Core Data)
        if let workoutsData = UserDefaults.standard.data(forKey: "workoutsData"),
           let loadedWorkouts = try? JSONDecoder().decode([Workout].self, from: workoutsData) {
            workouts = loadedWorkouts
        } else {
            // Create some demo workouts for the first time
            createDemoWorkouts()
        }
        
        updateTodaysWorkouts()
        isLoading = false
    }
    
    func saveWorkouts() {
        do {
            let workoutsData = try JSONEncoder().encode(workouts)
            UserDefaults.standard.set(workoutsData, forKey: "workoutsData")
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save workouts: \(error.localizedDescription)"
        }
    }
    
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
        saveWorkouts()
        updateTodaysWorkouts()
    }
    
    func updateWorkout(_ updatedWorkout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == updatedWorkout.id }) {
            workouts[index] = updatedWorkout
            saveWorkouts()
            updateTodaysWorkouts()
        }
    }
    
    func deleteWorkout(workoutId: UUID) {
        workouts.removeAll { $0.id == workoutId }
        saveWorkouts()
        updateTodaysWorkouts()
    }
    
    func updateTodaysWorkouts() {
        todaysWorkouts = workouts.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date < $1.date }
    }
    
    // MARK: - Workout Session Management
    
    func startWorkout(name: String, type: Workout.WorkoutType) {
        workoutStartTime = Date()
        activeWorkout = Workout(
            name: name,
            exercises: [],
            date: Date(),
            duration: 0,
            totalCaloriesBurned: 0,
            workoutType: type
        )
    }
    
    func endWorkout() {
        guard var workout = activeWorkout,
              let startTime = workoutStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        workout.duration = duration
        workout.totalCaloriesBurned = calculateCaloriesBurned(for: workout)
        
        addWorkout(workout)
        activeWorkout = nil
        workoutStartTime = nil
    }
    
    func cancelWorkout() {
        activeWorkout = nil
        workoutStartTime = nil
    }
    
    func addExerciseToActiveWorkout(_ exercise: Exercise) {
        guard var workout = activeWorkout else { return }
        workout.exercises.append(exercise)
        activeWorkout = workout
    }
    
    var currentWorkoutDuration: TimeInterval {
        guard let startTime = workoutStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    var isWorkoutActive: Bool {
        activeWorkout != nil
    }
    
    // MARK: - Fitness Calculations
    
    var todaysTotalCaloriesBurned: Int {
        todaysWorkouts.reduce(0) { $0 + $1.totalCaloriesBurned }
    }
    
    var todaysTotalWorkoutTime: TimeInterval {
        todaysWorkouts.reduce(0) { $0 + $1.duration }
    }
    
    var todaysWorkoutCount: Int {
        todaysWorkouts.count
    }
    
    func calculateCaloriesBurned(for workout: Workout) -> Int {
        // Simplified calorie calculation based on workout type and duration
        let minutesWorkedOut = workout.duration / 60
        let baseCaloriesPerMinute: Double = switch workout.workoutType {
        case .cardio, .running, .cycling: 12
        case .strength: 8
        case .yoga, .pilates, .flexibility: 4
        case .swimming: 14
        case .hiking, .walking: 6
        case .sports: 10
        case .other: 6
        }
        
        // Add exercise-specific calories if available
        let exerciseCalories = workout.exercises.compactMap { $0.caloriesPerMinute }.reduce(0, +)
        let totalCaloriesPerMinute = baseCaloriesPerMinute + Double(exerciseCalories)
        
        return Int(minutesWorkedOut * totalCaloriesPerMinute)
    }
    
    func workoutsByType(_ workoutType: Workout.WorkoutType) -> [Workout] {
        todaysWorkouts.filter { $0.workoutType == workoutType }
    }
    
    func caloriesBurnedByType(_ workoutType: Workout.WorkoutType) -> Int {
        workoutsByType(workoutType).reduce(0) { $0 + $1.totalCaloriesBurned }
    }
    
    // MARK: - Date Navigation
    
    func selectPreviousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        updateTodaysWorkouts()
    }
    
    func selectNextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        updateTodaysWorkouts()
    }
    
    func selectToday() {
        selectedDate = Date()
        updateTodaysWorkouts()
    }
    
    // MARK: - Quick Actions
    
    func addQuickWorkout(name: String, type: Workout.WorkoutType, duration: TimeInterval) {
        let workout = Workout(
            name: name,
            exercises: [],
            date: selectedDate,
            duration: duration,
            totalCaloriesBurned: 0,
            workoutType: type
        )
        
        var finalWorkout = workout
        finalWorkout.totalCaloriesBurned = calculateCaloriesBurned(for: workout)
        addWorkout(finalWorkout)
    }
    
    func duplicateWorkout(_ workout: Workout) {
        let duplicatedWorkout = Workout(
            name: "\(workout.name) (Copy)",
            exercises: workout.exercises,
            date: selectedDate,
            duration: workout.duration,
            totalCaloriesBurned: workout.totalCaloriesBurned,
            workoutType: workout.workoutType,
            notes: workout.notes
        )
        addWorkout(duplicatedWorkout)
    }
    
    // MARK: - Weekly/Monthly Analytics
    
    func weeklyWorkoutCount() -> Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate) ?? selectedDate
        return workouts.filter { $0.date >= weekAgo && $0.date <= selectedDate }.count
    }
    
    func weeklyCaloriesBurned() -> Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate) ?? selectedDate
        return workouts.filter { $0.date >= weekAgo && $0.date <= selectedDate }
            .reduce(0) { $0 + $1.totalCaloriesBurned }
    }
    
    func weeklyWorkoutTime() -> TimeInterval {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate) ?? selectedDate
        return workouts.filter { $0.date >= weekAgo && $0.date <= selectedDate }
            .reduce(0) { $0 + $1.duration }
    }
    
    func monthlyFitnessSummary() -> (workouts: Int, calories: Int, time: TimeInterval) {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        let monthWorkouts = workouts.filter { $0.date >= monthAgo && $0.date <= selectedDate }
        
        return monthWorkouts.reduce((0, 0, 0.0)) { result, workout in
            (
                result.0 + 1,
                result.1 + workout.totalCaloriesBurned,
                result.2 + workout.duration
            )
        }
    }
    
    func favoriteWorkoutType() -> Workout.WorkoutType {
        let workoutTypeCounts = Dictionary(grouping: workouts) { $0.workoutType }
            .mapValues { $0.count }
        
        return workoutTypeCounts.max(by: { $0.value < $1.value })?.key ?? .cardio
    }
    
    // MARK: - Streaks & Achievements
    
    func currentWorkoutStreak() -> Int {
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        while true {
            let hasWorkout = workouts.contains { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
            
            if hasWorkout {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    func totalWorkoutsCompleted() -> Int {
        workouts.count
    }
    
    func totalCaloriesBurned() -> Int {
        workouts.reduce(0) { $0 + $1.totalCaloriesBurned }
    }
    
    func totalTimeWorkedOut() -> TimeInterval {
        workouts.reduce(0) { $0 + $1.duration }
    }
    
    // MARK: - Demo Data
    
    private func createDemoWorkouts() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today) ?? today
        
        let demoWorkouts = [
            Workout(
                name: "Morning Run",
                exercises: [Exercise.sampleExercises[2]], // Running
                date: today,
                duration: 1800, // 30 minutes
                totalCaloriesBurned: 360,
                workoutType: .running
            ),
            
            Workout(
                name: "Strength Training",
                exercises: [
                    Exercise.sampleExercises[0], // Push-ups
                    Exercise.sampleExercises[1], // Squats
                    Exercise.sampleExercises[3], // Bench Press
                    Exercise.sampleExercises[4]  // Deadlift
                ],
                date: yesterday,
                duration: 3600, // 60 minutes
                totalCaloriesBurned: 480,
                workoutType: .strength
            ),
            
            Workout(
                name: "Evening Cycling",
                exercises: [Exercise.sampleExercises[6]], // Cycling
                date: twoDaysAgo,
                duration: 2400, // 40 minutes
                totalCaloriesBurned: 320,
                workoutType: .cycling
            )
        ]
        
        workouts = demoWorkouts
        saveWorkouts()
    }
    
    // MARK: - Reset & Clear
    
    func clearAllWorkouts() {
        workouts = []
        saveWorkouts()
        updateTodaysWorkouts()
    }
    
    func resetToDefaults() {
        clearAllWorkouts()
        createDemoWorkouts()
        updateTodaysWorkouts()
        selectedDate = Date()
        errorMessage = nil
        cancelWorkout()
    }
} 