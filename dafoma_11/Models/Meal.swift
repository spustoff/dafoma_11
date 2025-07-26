import Foundation

struct Meal: Codable, Identifiable {
    let id = UUID()
    var name: String
    var foods: [Food]
    var mealType: MealType
    var date: Date
    var notes: String?
    
    enum MealType: String, CaseIterable, Codable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
        case drink = "Drink"
    }
    
    var totalCalories: Int {
        foods.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        foods.reduce(0) { $0 + $1.protein }
    }
    
    var totalCarbs: Double {
        foods.reduce(0) { $0 + $1.carbs }
    }
    
    var totalFat: Double {
        foods.reduce(0) { $0 + $1.fat }
    }
    
    var totalFiber: Double {
        foods.reduce(0) { $0 + $1.fiber }
    }
    
    var totalSugar: Double {
        foods.reduce(0) { $0 + $1.sugar }
    }
    
    init(name: String, foods: [Food], mealType: MealType, date: Date = Date(), notes: String? = nil) {
        self.name = name
        self.foods = foods
        self.mealType = mealType
        self.date = date
        self.notes = notes
    }
}

struct Food: Codable, Identifiable {
    let id = UUID()
    var name: String
    var quantity: Double
    var unit: String
    var calories: Int
    var protein: Double // grams
    var carbs: Double // grams
    var fat: Double // grams
    var fiber: Double // grams
    var sugar: Double // grams
    var sodium: Double // mg
    var brand: String?
    var barcode: String?
    
    init(name: String, quantity: Double, unit: String, calories: Int, protein: Double, carbs: Double, fat: Double, fiber: Double = 0, sugar: Double = 0, sodium: Double = 0, brand: String? = nil, barcode: String? = nil) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.brand = brand
        self.barcode = barcode
    }
}

// Sample food database for demo purposes
extension Food {
    static let sampleFoods: [Food] = [
        Food(name: "Apple", quantity: 1, unit: "medium", calories: 95, protein: 0.3, carbs: 25, fat: 0.3, fiber: 4, sugar: 19),
        Food(name: "Banana", quantity: 1, unit: "medium", calories: 105, protein: 1.3, carbs: 27, fat: 0.4, fiber: 3, sugar: 14),
        Food(name: "Chicken Breast", quantity: 100, unit: "g", calories: 165, protein: 31, carbs: 0, fat: 3.6),
        Food(name: "Brown Rice", quantity: 100, unit: "g", calories: 111, protein: 2.6, carbs: 23, fat: 0.9, fiber: 1.8),
        Food(name: "Broccoli", quantity: 100, unit: "g", calories: 34, protein: 2.8, carbs: 7, fat: 0.4, fiber: 2.6, sugar: 1.5),
        Food(name: "Salmon", quantity: 100, unit: "g", calories: 208, protein: 22, carbs: 0, fat: 13),
        Food(name: "Greek Yogurt", quantity: 100, unit: "g", calories: 59, protein: 10, carbs: 3.6, fat: 0.4, sugar: 3.6),
        Food(name: "Almonds", quantity: 28, unit: "g", calories: 164, protein: 6, carbs: 6, fat: 14, fiber: 3.5, sugar: 1.2)
    ]
} 