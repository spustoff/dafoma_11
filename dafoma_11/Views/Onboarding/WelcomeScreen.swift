import SwiftUI

struct WelcomeScreen: View {
    @State private var name = ""
    @State private var age = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var selectedActivityLevel = User.ActivityLevel.moderatelyActive
    @State private var selectedDietaryGoal = User.DietaryGoal.maintainWeight
    @State private var showingMainApp = false
    @State private var currentStep = 0
    
    private let totalSteps = 3
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.nutriTrackBackground, Color.nutriTrackBackground.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    // Progress bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Step \(currentStep + 1) of \(totalSteps)")
                                .font(.caption)
                                .foregroundColor(Color.white.opacity(0.8))
                            Spacer()
                        }
                        
                        SwiftUI.ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryYellow))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)
                    
                    // Content
                    TabView(selection: $currentStep) {
                        personalInfoStep
                            .tag(0)
                        
                        activityLevelStep
                            .tag(1)
                        
                        goalSelectionStep
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                    
                    // Navigation buttons
                    VStack(spacing: 16) {
                        if currentStep == totalSteps - 1 {
                            Button(action: completeSetup) {
                                Text("Complete Setup")
                                    .font(.headline)
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity)
                            }
                            .nutriTrackButton(style: .secondary)
                            .disabled(!isFormValid)
                        } else {
                            Button(action: nextStep) {
                                Text("Continue")
                                    .font(.headline)
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity)
                            }
                            .nutriTrackButton(style: .primary)
                            .disabled(!isCurrentStepValid)
                        }
                        
                        if currentStep > 0 {
                                            Button(action: previousStep) {
                    Text("Back")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
                }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingMainApp) {
            ContentView()
        }
    }
    
    // MARK: - Step Views
    
    private var personalInfoStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Let's get to know you!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                
                Text("Tell us a bit about yourself to personalize your experience")
                    .font(.body)
                    .foregroundColor(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.headline)
                        .foregroundColor(Color.white)
                    
                    TextField("Enter your name", text: $name)
                        .foregroundColor(Color.white)
                        .nutriTrackTextField()
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(.headline)
                            .foregroundColor(Color.white)
                        
                        TextField("25", text: $age)
                            .keyboardType(.numberPad)
                            .foregroundColor(Color.white)
                            .nutriTrackTextField()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height (cm)")
                            .font(.headline)
                            .foregroundColor(Color.white)
                        
                        TextField("170", text: $height)
                            .keyboardType(.decimalPad)
                            .foregroundColor(Color.white)
                            .nutriTrackTextField()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight (kg)")
                            .font(.headline)
                            .foregroundColor(Color.white)
                        
                        TextField("70", text: $weight)
                            .keyboardType(.decimalPad)
                            .foregroundColor(Color.white)
                            .nutriTrackTextField()
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private var activityLevelStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("How active are you?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                
                Text("This helps us calculate your daily calorie needs")
                    .font(.body)
                    .foregroundColor(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                ForEach(User.ActivityLevel.allCases, id: \.self) { level in
                    Button(action: {
                        selectedActivityLevel = level
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.rawValue)
                                    .font(.headline)
                                    .foregroundColor(Color.white)
                                
                                Text(level.description)
                                    .font(.caption)
                                    .foregroundColor(Color.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            if selectedActivityLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.primaryGreen)
                                    .font(.title2)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(Color.white.opacity(0.2))
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedActivityLevel == level ? Color.white.opacity(0.15) : Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedActivityLevel == level ? Color.primaryGreen : Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private var goalSelectionStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What's your goal?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                
                Text("Choose your primary health and fitness objective")
                    .font(.body)
                    .foregroundColor(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                ForEach(User.DietaryGoal.allCases, id: \.self) { goal in
                    Button(action: {
                        selectedDietaryGoal = goal
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(goal.rawValue)
                                    .font(.headline)
                                    .foregroundColor(Color.white)
                                
                                Text(goal.description)
                                    .font(.caption)
                                    .foregroundColor(Color.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            if selectedDietaryGoal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.primaryGreen)
                                    .font(.title2)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(Color.white.opacity(0.2))
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedDietaryGoal == goal ? Color.white.opacity(0.15) : Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedDietaryGoal == goal ? Color.primaryGreen : Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Validation & Navigation
    
    private var isCurrentStepValid: Bool {
        switch currentStep {
        case 0:
            return !name.isEmpty && !age.isEmpty && !height.isEmpty && !weight.isEmpty
        case 1, 2:
            return true
        default:
            return false
        }
    }
    
    private var isFormValid: Bool {
        return !name.isEmpty && !age.isEmpty && !height.isEmpty && !weight.isEmpty &&
               Int(age) != nil && Double(height) != nil && Double(weight) != nil
    }
    
    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep < totalSteps - 1 {
                currentStep += 1
            }
        }
    }
    
    private func previousStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep > 0 {
                currentStep -= 1
            }
        }
    }
    
    private func completeSetup() {
        // Create user profile and save it
        if let ageInt = Int(age),
           let heightDouble = Double(height),
           let weightDouble = Double(weight) {
            
            let user = User(
                name: name,
                age: ageInt,
                height: heightDouble,
                weight: weightDouble,
                activityLevel: selectedActivityLevel,
                dietaryGoal: selectedDietaryGoal
            )
            
            // Save user data (in a real app, you'd use Core Data or similar)
            // UserDefaults is used here for simplicity
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: "userData")
            }
            
            showingMainApp = true
        }
    }
}

// Extensions for descriptions
extension User.ActivityLevel {
    var description: String {
        switch self {
        case .sedentary:
            return "Little or no exercise"
        case .lightlyActive:
            return "Light exercise/sports 1-3 days/week"
        case .moderatelyActive:
            return "Moderate exercise/sports 3-5 days/week"
        case .veryActive:
            return "Hard exercise/sports 6-7 days a week"
        case .extraActive:
            return "Very hard exercise & physical job"
        }
    }
}

extension User.DietaryGoal {
    var description: String {
        switch self {
        case .maintainWeight:
            return "Keep your current weight"
        case .loseWeight:
            return "Reduce body weight gradually"
        case .gainWeight:
            return "Increase body weight healthily"
        case .buildMuscle:
            return "Focus on muscle development"
        }
    }
}

#Preview {
    WelcomeScreen()
} 