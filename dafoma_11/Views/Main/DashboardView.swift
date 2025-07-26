import SwiftUI

struct DashboardView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var nutritionViewModel: NutritionTrackerViewModel
    @ObservedObject var fitnessViewModel: FitnessTrackerViewModel
    @State private var showingProfile = false
    @State private var showingTips = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.nutriTrackBackground, Color.nutriTrackBackground.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        headerSection
                        
                        // Quick Stats Cards
                        quickStatsSection
                        
                        // Today's Overview
                        todaysOverviewSection
                        
                        // Quick Actions
                        quickActionsSection
                        
                        // Recent Activity
                        recentActivitySection
                        
                        // Weekly Summary
                        weeklySummarySection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
                .refreshable {
                    refreshData()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(userViewModel.currentUser?.name ?? "User")!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                
                Text(Date().nutriTrackFullFormatted)
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: { showingProfile = true }) {
                ZStack {
                                    Circle()
                    .fill(LinearGradient(
                        colors: [Color.primaryYellow, Color.primaryGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                        .frame(width: 50, height: 50)
                    
                    Text(userViewModel.currentUser?.name.prefix(1).uppercased() ?? "U")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Quick Stats Section
    
    private var quickStatsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Calories Today",
                value: "\(nutritionViewModel.todaysTotalCalories)",
                subtitle: "of \(userViewModel.dailyCalorieGoal)",
                progress: nutritionViewModel.calorieProgress(goal: userViewModel.dailyCalorieGoal),
                color: .caloriesColor,
                icon: "flame.fill"
            )
            
            StatCard(
                title: "Workouts",
                value: "\(fitnessViewModel.todaysWorkoutCount)",
                subtitle: "today",
                progress: min(Double(fitnessViewModel.todaysWorkoutCount) / 2.0, 1.0),
                color: .strengthColor,
                icon: "figure.run"
            )
            
            StatCard(
                title: "Calories Burned",
                value: "\(fitnessViewModel.todaysTotalCaloriesBurned)",
                subtitle: "today",
                progress: min(Double(fitnessViewModel.todaysTotalCaloriesBurned) / 500.0, 1.0),
                color: .cardioColor,
                icon: "flame"
            )
            
            StatCard(
                title: "BMI",
                value: String(format: "%.1f", userViewModel.bmi ?? 0),
                subtitle: userViewModel.bmiCategory,
                progress: nil,
                color: .proteinColor,
                icon: "person.fill"
            )
        }
    }
    
    // MARK: - Today's Overview Section
    
    private var todaysOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Overview")
                    .font(.headline)
                    .foregroundColor(Color.white)
                
                Spacer()
                
                Button(action: { showingTips = true }) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(Color.primaryYellow)
                }
            }
            
            NutritionOverviewCard(nutritionViewModel: nutritionViewModel, userViewModel: userViewModel)
            
            FitnessOverviewCard(fitnessViewModel: fitnessViewModel)
        }
    }
    
    // MARK: - Quick Actions Section
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(Color.white)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Log Meal",
                    icon: "fork.knife",
                    color: Color.primaryYellow
                ) {
                    nutritionViewModel.showingAddMeal = true
                    selectedTab = 1
                }
                
                QuickActionButton(
                    title: "Start Workout",
                    icon: "figure.run",
                    color: Color.primaryGreen
                ) {
                    fitnessViewModel.showingAddWorkout = true
                    selectedTab = 2
                }
                
                QuickActionButton(
                    title: "View Progress",
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color(hex: "007aff")
                ) {
                    // Switch to analytics view
                    selectedTab = 3
                }
            }
        }
    }
    
    // MARK: - Recent Activity Section
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(Color.white)
            
            VStack(spacing: 12) {
                ForEach(Array(recentActivities.prefix(5)), id: \.id) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
    }
    
    // MARK: - Weekly Summary Section
    
    private var weeklySummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.headline)
                .foregroundColor(Color.white)
            
            VStack(spacing: 12) {
                WeeklySummaryRow(
                    title: "Average Calories",
                    value: String(format: "%.0f", nutritionViewModel.weeklyCalorieAverage()),
                    icon: "flame.fill",
                    color: .caloriesColor
                )
                
                WeeklySummaryRow(
                    title: "Workouts Completed",
                    value: "\(fitnessViewModel.weeklyWorkoutCount())",
                    icon: "figure.run",
                    color: .strengthColor
                )
                
                WeeklySummaryRow(
                    title: "Calories Burned",
                    value: "\(fitnessViewModel.weeklyCaloriesBurned())",
                    icon: "flame",
                    color: .cardioColor
                )
                
                WeeklySummaryRow(
                    title: "Workout Time",
                    value: formatDuration(fitnessViewModel.weeklyWorkoutTime()),
                    icon: "clock.fill",
                    color: .flexibilityColor
                )
            }
            .nutriTrackCard()
        }
    }
    
    // MARK: - Helper Properties
    
    private var recentActivities: [ActivityItem] {
        var activities: [ActivityItem] = []
        
        // Add recent meals
        for meal in nutritionViewModel.todaysMeals.suffix(3) {
            activities.append(ActivityItem(
                id: meal.id,
                title: meal.name,
                subtitle: "\(meal.totalCalories) calories",
                time: meal.date,
                icon: "fork.knife",
                color: .caloriesColor
            ))
        }
        
        // Add recent workouts
        for workout in fitnessViewModel.todaysWorkouts.suffix(2) {
            activities.append(ActivityItem(
                id: workout.id,
                title: workout.name,
                subtitle: "\(workout.totalCaloriesBurned) calories burned",
                time: workout.date,
                icon: "figure.run",
                color: .strengthColor
            ))
        }
        
        return activities.sorted { $0.time > $1.time }
    }
    
    // MARK: - Helper Methods
    
    private func refreshData() {
        nutritionViewModel.updateTodaysMeals()
        fitnessViewModel.updateTodaysWorkouts()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let progress: Double?
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
                
                if let progress = progress {
                    CircularProgressView(progress: progress, color: color)
                        .frame(width: 30, height: 30)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.8))
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(Color.white.opacity(0.6))
            }
        }
        .padding()
        .nutriTrackCard()
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}

struct NutritionOverviewCard: View {
    @ObservedObject var nutritionViewModel: NutritionTrackerViewModel
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrition")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.white)
            
            HStack(spacing: 16) {
                MacroProgressView(
                    title: "Protein",
                    current: nutritionViewModel.todaysTotalProtein,
                    goal: Double(userViewModel.dailyCalorieGoal) * 0.3 / 4, // 30% of calories from protein
                    unit: "g",
                    color: .proteinColor
                )
                
                MacroProgressView(
                    title: "Carbs",
                    current: nutritionViewModel.todaysTotalCarbs,
                    goal: Double(userViewModel.dailyCalorieGoal) * 0.45 / 4, // 45% of calories from carbs
                    unit: "g",
                    color: .carbsColor
                )
                
                MacroProgressView(
                    title: "Fat",
                    current: nutritionViewModel.todaysTotalFat,
                    goal: Double(userViewModel.dailyCalorieGoal) * 0.25 / 9, // 25% of calories from fat
                    unit: "g",
                    color: .fatColor
                )
            }
        }
        .padding()
        .nutriTrackCard()
    }
}

struct FitnessOverviewCard: View {
    @ObservedObject var fitnessViewModel: FitnessTrackerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fitness")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.white)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Workout Streak")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                    
                    Text("\(fitnessViewModel.currentWorkoutStreak())")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryGreen)
                    
                    Text("days")
                        .font(.caption2)
                        .foregroundColor(Color.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Workout Time")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                    
                    Text(formatWorkoutTime(fitnessViewModel.todaysTotalWorkoutTime))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryYellow)
                    
                    Text("today")
                        .font(.caption2)
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }
        }
        .padding()
        .nutriTrackCard()
    }
    
    private func formatWorkoutTime(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct MacroProgressView: View {
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
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.8))
            
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
            
            VStack(spacing: 2) {
                Text(String(format: "%.0f", current))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(Color.white.opacity(0.6))
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .nutriTrackCard()
    }
}

struct ActivityRow: View {
    let activity: ActivityItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.icon)
                .foregroundColor(activity.color)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.white)
                
                Text(activity.subtitle)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.8))
            }
            
            Spacer()
            
            Text(activity.time.nutriTrackTimeFormatted)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.6))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct WeeklySummaryRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.white)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.white)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Supporting Models

struct ActivityItem: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let time: Date
    let icon: String
    let color: Color
}

#Preview {
    DashboardView(
        userViewModel: UserViewModel(),
        nutritionViewModel: NutritionTrackerViewModel(),
        fitnessViewModel: FitnessTrackerViewModel()
    )
} 