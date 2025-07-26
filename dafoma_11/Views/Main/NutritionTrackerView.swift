import SwiftUI

struct NutritionTrackerView: View {
    @ObservedObject var nutritionViewModel: NutritionTrackerViewModel
    @ObservedObject var userViewModel: UserViewModel
    @State private var showingAddMeal = false
    @State private var showingMealDetail = false
    @State private var selectedMeal: Meal?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.nutriTrackBackground, Color.nutriTrackBackground.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with date navigation
                    headerSection
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Daily nutrition summary
                            dailyNutritionCard
                            
                            // Meals by type
                            mealsSection
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                    }
                    .refreshable {
                        nutritionViewModel.updateTodaysMeals()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddMeal) {
                AddMealView(nutritionViewModel: nutritionViewModel)
            }
            .sheet(item: $selectedMeal) { meal in
                MealDetailView(meal: meal, nutritionViewModel: nutritionViewModel)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Nutrition")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                
                Spacer()
                
                Button(action: { showingAddMeal = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.primaryYellow)
                }
            }
            
            // Date Navigation
            HStack {
                Button(action: { nutritionViewModel.selectPreviousDay() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(nutritionViewModel.selectedDate.nutriTrackWeekdayFormatted)
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
                    
                    Text(nutritionViewModel.selectedDate.nutriTrackShortFormatted)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                }
                
                Spacer()
                
                Button(action: { nutritionViewModel.selectNextDay() }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20)
            
            // Today button
            if !nutritionViewModel.selectedDate.isToday {
                Button(action: { nutritionViewModel.selectToday() }) {
                    Text("Today")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
                .nutriTrackButton(style: .primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Daily Nutrition Card
    
    private var dailyNutritionCard: some View {
        VStack(spacing: 16) {
            // Calorie progress
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calories")
                        .font(.headline)
                        .foregroundColor(Color.white)
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(nutritionViewModel.todaysTotalCalories)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primaryYellow)
                        
                        Text("/ \(userViewModel.dailyCalorieGoal)")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    
                    SwiftUI.ProgressView(value: nutritionViewModel.calorieProgress(goal: userViewModel.dailyCalorieGoal))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryYellow))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: nutritionViewModel.calorieProgress(goal: userViewModel.dailyCalorieGoal),
                    color: Color.primaryYellow
                )
                .frame(width: 60, height: 60)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Macronutrients
            HStack(spacing: 20) {
                MacroColumn(
                    title: "Protein",
                    current: nutritionViewModel.todaysTotalProtein,
                    goal: Double(userViewModel.dailyCalorieGoal) * 0.3 / 4,
                    unit: "g",
                    color: .proteinColor
                )
                
                MacroColumn(
                    title: "Carbs",
                    current: nutritionViewModel.todaysTotalCarbs,
                    goal: Double(userViewModel.dailyCalorieGoal) * 0.45 / 4,
                    unit: "g",
                    color: .carbsColor
                )
                
                MacroColumn(
                    title: "Fat",
                    current: nutritionViewModel.todaysTotalFat,
                    goal: Double(userViewModel.dailyCalorieGoal) * 0.25 / 9,
                    unit: "g",
                    color: .fatColor
                )
                
                MacroColumn(
                    title: "Fiber",
                    current: nutritionViewModel.todaysTotalFiber,
                    goal: 25.0,
                    unit: "g",
                    color: .fiberColor
                )
            }
        }
        .padding()
        .nutriTrackCard()
    }
    
    // MARK: - Meals Section
    
    private var mealsSection: some View {
        VStack(spacing: 16) {
            ForEach(Meal.MealType.allCases, id: \.self) { mealType in
                MealTypeSection(
                    mealType: mealType,
                    meals: nutritionViewModel.mealsByType(mealType),
                    totalCalories: nutritionViewModel.caloriesForMealType(mealType),
                    onAddMeal: {
                        nutritionViewModel.selectedMealType = mealType
                        showingAddMeal = true
                    },
                    onMealTap: { meal in
                        selectedMeal = meal
                        showingMealDetail = true
                    }
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct MacroColumn: View {
    let title: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.8))
            
            VStack(spacing: 4) {
                Text(String(format: "%.0f", current))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(Color.white.opacity(0.6))
            }
            
            SwiftUI.ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .frame(height: 4)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MealTypeSection: View {
    let mealType: Meal.MealType
    let meals: [Meal]
    let totalCalories: Int
    let onAddMeal: () -> Void
    let onMealTap: (Meal) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mealType.rawValue)
                        .font(.headline)
                        .foregroundColor(Color.white)
                    
                    if totalCalories > 0 {
                        Text("\(totalCalories) calories")
                            .font(.caption)
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                Button(action: onAddMeal) {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                        .foregroundColor(Color.primaryGreen)
                }
            }
            
            if meals.isEmpty {
                EmptyMealView(mealType: mealType, onAddMeal: onAddMeal)
            } else {
                VStack(spacing: 8) {
                    ForEach(meals) { meal in
                        MealRow(meal: meal, onTap: { onMealTap(meal) })
                    }
                }
            }
        }
        .padding()
        .nutriTrackCard()
    }
}

struct MealRow: View {
    let meal: Meal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: mealTypeIcon(meal.mealType))
                    .foregroundColor(mealTypeColor(meal.mealType))
                    .font(.title3)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                    
                    HStack(spacing: 16) {
                        NutritionLabel(value: "\(meal.totalCalories)", unit: "cal", color: .caloriesColor)
                        NutritionLabel(value: String(format: "%.0f", meal.totalProtein), unit: "g protein", color: .proteinColor)
                        NutritionLabel(value: String(format: "%.0f", meal.totalCarbs), unit: "g carbs", color: .carbsColor)
                    }
                    .font(.caption)
                }
                
                Spacer()
                
                Text(meal.date.nutriTrackTimeFormatted)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.6))
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.6))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func mealTypeIcon(_ mealType: Meal.MealType) -> String {
        switch mealType {
        case .breakfast: return "sun.rise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        case .drink: return "drop.fill"
        }
    }
    
    private func mealTypeColor(_ mealType: Meal.MealType) -> Color {
        switch mealType {
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .purple
        case .snack: return .green
        case .drink: return .blue
        }
    }
}

struct NutritionLabel: View {
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(unit)
                .foregroundColor(Color.white.opacity(0.6))
        }
    }
}

struct EmptyMealView: View {
    let mealType: Meal.MealType
    let onAddMeal: () -> Void
    
    var body: some View {
        Button(action: onAddMeal) {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.dashed")
                    .font(.title)
                    .foregroundColor(Color.white.opacity(0.6))
                
                Text("Add \(mealType.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Add Meal View

struct AddMealView: View {
    @ObservedObject var nutritionViewModel: NutritionTrackerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var mealName = ""
    @State private var selectedFoods: [Food] = []
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.nutriTrackBackground, Color.nutriTrackBackground.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Meal name input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meal Name")
                            .font(.headline)
                            .foregroundColor(Color.white)
                        
                        TextField("Enter meal name", text: $mealName)
                            .foregroundColor(Color.white)
                            .nutriTrackTextField()
                    }
                    
                    // Food search and selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Search Foods")
                            .font(.headline)
                            .foregroundColor(Color.white)
                        
                        TextField("Search for foods", text: $nutritionViewModel.searchText)
                            .foregroundColor(Color.white)
                            .nutriTrackTextField()
                    }
                    
                    // Food list
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(nutritionViewModel.filteredFoods) { food in
                                FoodSelectionRow(
                                    food: food,
                                    isSelected: selectedFoods.contains { $0.id == food.id }
                                ) {
                                    if selectedFoods.contains(where: { $0.id == food.id }) {
                                        selectedFoods.removeAll { $0.id == food.id }
                                    } else {
                                        selectedFoods.append(food)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMeal()
                    }
                    .disabled(mealName.isEmpty || selectedFoods.isEmpty)
                }
            }
        }
    }
    
    private func saveMeal() {
        let meal = Meal(
            name: mealName,
            foods: selectedFoods,
            mealType: nutritionViewModel.selectedMealType,
            date: nutritionViewModel.selectedDate,
            notes: notes.isEmpty ? nil : notes
        )
        
        nutritionViewModel.addMeal(meal)
        dismiss()
    }
}

struct FoodSelectionRow: View {
    let food: Food
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                    
                    if let brand = food.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    
                    HStack(spacing: 12) {
                        Text("\(food.calories) cal")
                            .font(.caption)
                            .foregroundColor(.caloriesColor)
                        
                        Text("\(String(format: "%.1f", food.protein))g protein")
                            .font(.caption)
                            .foregroundColor(.proteinColor)
                        
                        Text("\(String(format: "%.1f", food.carbs))g carbs")
                            .font(.caption)
                            .foregroundColor(.carbsColor)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color.primaryGreen : Color.white.opacity(0.2))
                    .font(.title3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.primaryGreen : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Meal Detail View

struct MealDetailView: View {
    let meal: Meal
    @ObservedObject var nutritionViewModel: NutritionTrackerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.nutriTrackBackground, Color.nutriTrackBackground.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Meal overview
                        mealOverviewCard
                        
                        // Foods in meal
                        foodsCard
                        
                        // Nutrition breakdown
                        nutritionBreakdownCard
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle(meal.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var mealOverviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Overview")
                    .font(.headline)
                    .foregroundColor(Color.white)
                
                Spacer()
                
                Text(meal.date.nutriTrackDateTimeFormatted)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.8))
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(meal.totalCalories)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.caloriesColor)
                    
                    Text("Calories")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f", meal.totalProtein))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.proteinColor)
                    
                    Text("Protein (g)")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f", meal.totalCarbs))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.carbsColor)
                    
                    Text("Carbs (g)")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f", meal.totalFat))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.fatColor)
                    
                    Text("Fat (g)")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                }
            }
        }
        .padding()
        .nutriTrackCard()
    }
    
    private var foodsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Foods")
                .font(.headline)
                .foregroundColor(Color.white)
            
            VStack(spacing: 8) {
                ForEach(meal.foods) { food in
                    FoodDetailRow(food: food)
                }
            }
        }
        .padding()
        .nutriTrackCard()
    }
    
    private var nutritionBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrition Breakdown")
                .font(.headline)
                .foregroundColor(Color.white)
            
            VStack(spacing: 8) {
                NutritionDetailRow(title: "Fiber", value: meal.totalFiber, unit: "g", color: .fiberColor)
                NutritionDetailRow(title: "Sugar", value: meal.totalSugar, unit: "g", color: .orange)
            }
        }
        .padding()
        .nutriTrackCard()
    }
}

struct FoodDetailRow: View {
    let food: Food
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(food.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.white)
                
                Spacer()
                
                Text("\(String(format: "%.0f", food.quantity)) \(food.unit)")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.8))
            }
            
            HStack(spacing: 16) {
                NutritionLabel(value: "\(food.calories)", unit: "cal", color: .caloriesColor)
                NutritionLabel(value: String(format: "%.1f", food.protein), unit: "g protein", color: .proteinColor)
                NutritionLabel(value: String(format: "%.1f", food.carbs), unit: "g carbs", color: .carbsColor)
                NutritionLabel(value: String(format: "%.1f", food.fat), unit: "g fat", color: .fatColor)
            }
            .font(.caption)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
}

struct NutritionDetailRow: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.white)
            
            Spacer()
            
            Text("\(String(format: "%.1f", value)) \(unit)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NutritionTrackerView(
        nutritionViewModel: NutritionTrackerViewModel(),
        userViewModel: UserViewModel()
    )
} 