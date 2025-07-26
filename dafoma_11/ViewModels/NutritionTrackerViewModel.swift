import SwiftUI
import Foundation

@MainActor
class NutritionTrackerViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var todaysMeals: [Meal] = []
    @Published var selectedDate = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedMealType = Meal.MealType.breakfast
    @Published var showingAddMeal = false
    @Published var availableFoods = Food.sampleFoods
    
    init() {
        loadMeals()
        updateTodaysMeals()
    }
    
    // MARK: - Data Management
    
    func loadMeals() {
        isLoading = true
        
        // Load meals from UserDefaults (in a real app, you'd use Core Data)
        if let mealsData = UserDefaults.standard.data(forKey: "mealsData"),
           let loadedMeals = try? JSONDecoder().decode([Meal].self, from: mealsData) {
            meals = loadedMeals
        } else {
            // Create some demo meals for the first time
            createDemoMeals()
        }
        
        updateTodaysMeals()
        isLoading = false
    }
    
    func saveMeals() {
        do {
            let mealsData = try JSONEncoder().encode(meals)
            UserDefaults.standard.set(mealsData, forKey: "mealsData")
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save meals: \(error.localizedDescription)"
        }
    }
    
    func addMeal(_ meal: Meal) {
        meals.append(meal)
        saveMeals()
        updateTodaysMeals()
    }
    
    func updateMeal(_ updatedMeal: Meal) {
        if let index = meals.firstIndex(where: { $0.id == updatedMeal.id }) {
            meals[index] = updatedMeal
            saveMeals()
            updateTodaysMeals()
        }
    }
    
    func deleteMeal(mealId: UUID) {
        meals.removeAll { $0.id == mealId }
        saveMeals()
        updateTodaysMeals()
    }
    
    func updateTodaysMeals() {
        todaysMeals = meals.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date < $1.date }
    }
    
    // MARK: - Nutrition Calculations
    
    var todaysTotalCalories: Int {
        todaysMeals.reduce(0) { $0 + $1.totalCalories }
    }
    
    var todaysTotalProtein: Double {
        todaysMeals.reduce(0) { $0 + $1.totalProtein }
    }
    
    var todaysTotalCarbs: Double {
        todaysMeals.reduce(0) { $0 + $1.totalCarbs }
    }
    
    var todaysTotalFat: Double {
        todaysMeals.reduce(0) { $0 + $1.totalFat }
    }
    
    var todaysTotalFiber: Double {
        todaysMeals.reduce(0) { $0 + $1.totalFiber }
    }
    
    var todaysTotalSugar: Double {
        todaysMeals.reduce(0) { $0 + $1.totalSugar }
    }
    
    func calorieProgress(goal: Int) -> Double {
        guard goal > 0 else { return 0 }
        return min(Double(todaysTotalCalories) / Double(goal), 1.0)
    }
    
    func proteinProgress(goal: Double) -> Double {
        guard goal > 0 else { return 0 }
        return min(todaysTotalProtein / goal, 1.0)
    }
    
    func carbsProgress(goal: Double) -> Double {
        guard goal > 0 else { return 0 }
        return min(todaysTotalCarbs / goal, 1.0)
    }
    
    func fatProgress(goal: Double) -> Double {
        guard goal > 0 else { return 0 }
        return min(todaysTotalFat / goal, 1.0)
    }
    
    // MARK: - Food Search & Filtering
    
    var filteredFoods: [Food] {
        if searchText.isEmpty {
            return availableFoods
        } else {
            return availableFoods.filter { food in
                food.name.localizedCaseInsensitiveContains(searchText) ||
                food.brand?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    func mealsByType(_ mealType: Meal.MealType) -> [Meal] {
        todaysMeals.filter { $0.mealType == mealType }
    }
    
    func caloriesForMealType(_ mealType: Meal.MealType) -> Int {
        mealsByType(mealType).reduce(0) { $0 + $1.totalCalories }
    }
    
    // MARK: - Date Navigation
    
    func selectPreviousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        updateTodaysMeals()
    }
    
    func selectNextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        updateTodaysMeals()
    }
    
    func selectToday() {
        selectedDate = Date()
        updateTodaysMeals()
    }
    
    // MARK: - Quick Actions
    
    func addQuickMeal(name: String, foods: [Food], mealType: Meal.MealType) {
        let meal = Meal(
            name: name,
            foods: foods,
            mealType: mealType,
            date: selectedDate
        )
        addMeal(meal)
    }
    
    func duplicateMeal(_ meal: Meal) {
        let duplicatedMeal = Meal(
            name: "\(meal.name) (Copy)",
            foods: meal.foods,
            mealType: meal.mealType,
            date: selectedDate,
            notes: meal.notes
        )
        addMeal(duplicatedMeal)
    }
    
    // MARK: - Weekly/Monthly Analytics
    
    func weeklyCalorieAverage() -> Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate) ?? selectedDate
        let weekMeals = meals.filter { $0.date >= weekAgo && $0.date <= selectedDate }
        
        let dailyTotals = Dictionary(grouping: weekMeals) { meal in
            Calendar.current.startOfDay(for: meal.date)
        }.mapValues { mealsForDay in
            mealsForDay.reduce(0) { $0 + $1.totalCalories }
        }
        
        let totalCalories = dailyTotals.values.reduce(0, +)
        return dailyTotals.count > 0 ? Double(totalCalories) / Double(dailyTotals.count) : 0
    }
    
    func monthlyNutritionSummary() -> (calories: Int, protein: Double, carbs: Double, fat: Double) {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        let monthMeals = meals.filter { $0.date >= monthAgo && $0.date <= selectedDate }
        
        return monthMeals.reduce((0, 0.0, 0.0, 0.0)) { result, meal in
            (
                result.0 + meal.totalCalories,
                result.1 + meal.totalProtein,
                result.2 + meal.totalCarbs,
                result.3 + meal.totalFat
            )
        }
    }
    
    // MARK: - Demo Data
    
    private func createDemoMeals() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        
        let demoMeals = [
            Meal(name: "Healthy Breakfast", foods: [
                Food.sampleFoods[0], // Apple
                Food.sampleFoods[6]  // Greek Yogurt
            ], mealType: .breakfast, date: today),
            
            Meal(name: "Power Lunch", foods: [
                Food.sampleFoods[2], // Chicken Breast
                Food.sampleFoods[3], // Brown Rice
                Food.sampleFoods[4]  // Broccoli
            ], mealType: .lunch, date: today),
            
            Meal(name: "Yesterday's Dinner", foods: [
                Food.sampleFoods[5], // Salmon
                Food.sampleFoods[3]  // Brown Rice
            ], mealType: .dinner, date: yesterday)
        ]
        
        meals = demoMeals
        saveMeals()
    }
    
    // MARK: - Reset & Clear
    
    func clearAllMeals() {
        meals = []
        saveMeals()
        updateTodaysMeals()
    }
    
    func resetToDefaults() {
        clearAllMeals()
        createDemoMeals()
        updateTodaysMeals()
        selectedDate = Date()
        searchText = ""
        errorMessage = nil
    }
} 