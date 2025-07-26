import Foundation

struct Workout: Codable, Identifiable {
    let id = UUID()
    var name: String
    var exercises: [Exercise]
    var date: Date
    var duration: TimeInterval // in seconds
    var totalCaloriesBurned: Int
    var workoutType: WorkoutType
    var notes: String?
    
    enum WorkoutType: String, CaseIterable, Codable {
        case cardio = "Cardio"
        case strength = "Strength Training"
        case flexibility = "Flexibility"
        case sports = "Sports"
        case yoga = "Yoga"
        case pilates = "Pilates"
        case hiking = "Hiking"
        case swimming = "Swimming"
        case cycling = "Cycling"
        case running = "Running"
        case walking = "Walking"
        case other = "Other"
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    init(name: String, exercises: [Exercise], date: Date = Date(), duration: TimeInterval, totalCaloriesBurned: Int, workoutType: WorkoutType, notes: String? = nil) {
        self.name = name
        self.exercises = exercises
        self.date = date
        self.duration = duration
        self.totalCaloriesBurned = totalCaloriesBurned
        self.workoutType = workoutType
        self.notes = notes
    }
}

struct Exercise: Codable, Identifiable {
    let id = UUID()
    var name: String
    var sets: [ExerciseSet]
    var exerciseType: ExerciseType
    var muscleGroups: [MuscleGroup]
    var caloriesPerMinute: Int?
    
    enum ExerciseType: String, CaseIterable, Codable {
        case strength = "Strength"
        case cardio = "Cardio"
        case flexibility = "Flexibility"
        case balance = "Balance"
    }
    
    enum MuscleGroup: String, CaseIterable, Codable {
        case chest = "Chest"
        case back = "Back"
        case shoulders = "Shoulders"
        case arms = "Arms"
        case core = "Core"
        case legs = "Legs"
        case glutes = "Glutes"
        case fullBody = "Full Body"
    }
    
    var totalVolume: Double {
        sets.reduce(0) { total, set in
            total + (set.weight * Double(set.reps))
        }
    }
    
    init(name: String, sets: [ExerciseSet], exerciseType: ExerciseType, muscleGroups: [MuscleGroup], caloriesPerMinute: Int? = nil) {
        self.name = name
        self.sets = sets
        self.exerciseType = exerciseType
        self.muscleGroups = muscleGroups
        self.caloriesPerMinute = caloriesPerMinute
    }
}

struct ExerciseSet: Codable, Identifiable {
    let id = UUID()
    var reps: Int
    var weight: Double // in kg
    var duration: TimeInterval? // for time-based exercises
    var distance: Double? // for cardio exercises in km
    var restTime: TimeInterval? // in seconds
    
    init(reps: Int, weight: Double, duration: TimeInterval? = nil, distance: Double? = nil, restTime: TimeInterval? = nil) {
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.distance = distance
        self.restTime = restTime
    }
}

// Sample exercises for demo purposes
extension Exercise {
    static let sampleExercises: [Exercise] = [
        Exercise(name: "Push-ups", sets: [ExerciseSet(reps: 15, weight: 0)], exerciseType: .strength, muscleGroups: [.chest, .arms, .core]),
        Exercise(name: "Squats", sets: [ExerciseSet(reps: 20, weight: 0)], exerciseType: .strength, muscleGroups: [.legs, .glutes]),
        Exercise(name: "Running", sets: [ExerciseSet(reps: 1, weight: 0, duration: 1800, distance: 5.0)], exerciseType: .cardio, muscleGroups: [.legs], caloriesPerMinute: 12),
        Exercise(name: "Bench Press", sets: [ExerciseSet(reps: 10, weight: 80)], exerciseType: .strength, muscleGroups: [.chest, .arms]),
        Exercise(name: "Deadlift", sets: [ExerciseSet(reps: 8, weight: 100)], exerciseType: .strength, muscleGroups: [.back, .legs, .glutes]),
        Exercise(name: "Plank", sets: [ExerciseSet(reps: 1, weight: 0, duration: 60)], exerciseType: .strength, muscleGroups: [.core]),
        Exercise(name: "Cycling", sets: [ExerciseSet(reps: 1, weight: 0, duration: 3600, distance: 20.0)], exerciseType: .cardio, muscleGroups: [.legs], caloriesPerMinute: 8)
    ]
} 