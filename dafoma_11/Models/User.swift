import Foundation

struct User: Codable, Identifiable {
    let id = UUID()
    var name: String
    var age: Int
    var height: Double // in cm
    var weight: Double // in kg
    var activityLevel: ActivityLevel
    var dietaryGoal: DietaryGoal
    var dietaryRestrictions: [String]
    var dailyCalorieGoal: Int
    var fitnessGoals: [FitnessGoal]
    var joinDate: Date
    
    enum ActivityLevel: String, CaseIterable, Codable {
        case sedentary = "Sedentary"
        case lightlyActive = "Lightly Active"
        case moderatelyActive = "Moderately Active"
        case veryActive = "Very Active"
        case extraActive = "Extra Active"
    }
    
    enum DietaryGoal: String, CaseIterable, Codable {
        case maintainWeight = "Maintain Weight"
        case loseWeight = "Lose Weight"
        case gainWeight = "Gain Weight"
        case buildMuscle = "Build Muscle"
    }
    
    struct FitnessGoal: Codable, Identifiable {
        let id = UUID()
        var name: String
        var targetValue: Double
        var currentValue: Double
        var unit: String
        var deadline: Date?
    }
    
    init(name: String, age: Int, height: Double, weight: Double, activityLevel: ActivityLevel, dietaryGoal: DietaryGoal) {
        self.name = name
        self.age = age
        self.height = height
        self.weight = weight
        self.activityLevel = activityLevel
        self.dietaryGoal = dietaryGoal
        self.dietaryRestrictions = []
        self.fitnessGoals = []
        self.joinDate = Date()
        
        // Calculate daily calorie goal directly
        let bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
        let activityMultiplier: Double = switch activityLevel {
        case .sedentary: 1.2
        case .lightlyActive: 1.375
        case .moderatelyActive: 1.55
        case .veryActive: 1.725
        case .extraActive: 1.9
        }
        let maintenanceCalories = bmr * activityMultiplier
        self.dailyCalorieGoal = switch dietaryGoal {
        case .maintainWeight: Int(maintenanceCalories)
        case .loseWeight: Int(maintenanceCalories - 500)
        case .gainWeight: Int(maintenanceCalories + 500)
        case .buildMuscle: Int(maintenanceCalories + 300)
        }
    }
    
    private func calculateDailyCalorieGoal() -> Int {
        // Basic BMR calculation using Mifflin-St Jeor Equation
        let bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
        
        let activityMultiplier: Double = switch activityLevel {
        case .sedentary: 1.2
        case .lightlyActive: 1.375
        case .moderatelyActive: 1.55
        case .veryActive: 1.725
        case .extraActive: 1.9
        }
        
        let maintenanceCalories = bmr * activityMultiplier
        
        return switch dietaryGoal {
        case .maintainWeight: Int(maintenanceCalories)
        case .loseWeight: Int(maintenanceCalories - 500)
        case .gainWeight: Int(maintenanceCalories + 500)
        case .buildMuscle: Int(maintenanceCalories + 300)
        }
    }
} 
