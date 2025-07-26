import SwiftUI

struct FitnessTrackerView: View {
    @ObservedObject var fitnessViewModel: FitnessTrackerViewModel
    @State private var showingAddWorkout = false
    @State private var showingWorkoutDetail = false
    @State private var selectedWorkout: Workout?
    @State private var showingActiveWorkout = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.nutriTrackBackground, Color.nutriTrackBackground.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Today's fitness summary
                            dailyFitnessCard
                            
                            // Active workout indicator
                            if fitnessViewModel.isWorkoutActive {
                                activeWorkoutCard
                            }
                            
                            // Today's workouts
                            todaysWorkoutsSection
                            
                            // Quick workout options
                            quickWorkoutSection
                            
                            // Fitness stats
                            fitnessStatsSection
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                    }
                    .refreshable {
                        fitnessViewModel.updateTodaysWorkouts()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView(fitnessViewModel: fitnessViewModel)
            }
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout, fitnessViewModel: fitnessViewModel)
            }
            .sheet(isPresented: $showingActiveWorkout) {
                ActiveWorkoutView(fitnessViewModel: fitnessViewModel)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Fitness")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                
                Spacer()
                
                Button(action: { showingAddWorkout = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.primaryGreen)
                }
            }
            
            // Date Navigation
            HStack {
                Button(action: { fitnessViewModel.selectPreviousDay() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(fitnessViewModel.selectedDate.nutriTrackWeekdayFormatted)
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
                    
                    Text(fitnessViewModel.selectedDate.nutriTrackShortFormatted)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                }
                
                Spacer()
                
                Button(action: { fitnessViewModel.selectNextDay() }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20)
            
            // Today button
            if !fitnessViewModel.selectedDate.isToday {
                Button(action: { fitnessViewModel.selectToday() }) {
                    Text("Today")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
                .nutriTrackButton(style: .secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Daily Fitness Card
    
    private var dailyFitnessCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Calories burned
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "flame")
                            .foregroundColor(.cardioColor)
                        Text("Calories Burned")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    
                    Text("\(fitnessViewModel.todaysTotalCaloriesBurned)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.cardioColor)
                }
                
                Spacer()
                
                // Workout time
                VStack(alignment: .trailing, spacing: 8) {
                    HStack {
                        Text("Workout Time")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.8))
                        Image(systemName: "clock")
                            .foregroundColor(.strengthColor)
                    }
                    
                    Text(formatDuration(fitnessViewModel.todaysTotalWorkoutTime))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.strengthColor)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Progress indicators
            HStack(spacing: 20) {
                ProgressIndicator(
                    title: "Workouts",
                    current: fitnessViewModel.todaysWorkoutCount,
                    goal: 2,
                    color: .strengthColor
                )
                
                ProgressIndicator(
                    title: "Streak",
                    current: fitnessViewModel.currentWorkoutStreak(),
                    goal: 7,
                    color: .flexibilityColor
                )
                
                ProgressIndicator(
                    title: "Weekly Goal",
                    current: fitnessViewModel.weeklyWorkoutCount(),
                    goal: 5,
                    color: .cardioColor
                )
            }
        }
        .padding()
        .nutriTrackCard()
    }
    
    // MARK: - Active Workout Card
    
    private var activeWorkoutCard: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(), value: true)
                    
                    Text("Workout in Progress")
                        .font(.headline)
                        .foregroundColor(Color.white)
                }
                
                Spacer()
                
                Text(formatDuration(fitnessViewModel.currentWorkoutDuration))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.primaryYellow)
            }
            
            if let activeWorkout = fitnessViewModel.activeWorkout {
                HStack {
                    Text(activeWorkout.name)
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text(activeWorkout.workoutType.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.primaryGreen.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(Color.primaryGreen)
                }
            }
            
            HStack(spacing: 12) {
                Button(action: { showingActiveWorkout = true }) {
                    Text("View Workout")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .nutriTrackButton(style: .primary)
                
                Button(action: { fitnessViewModel.endWorkout() }) {
                    Text("End Workout")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .nutriTrackButton(style: .secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "ff9500").opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "ff9500"), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Today's Workouts Section
    
    private var todaysWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Workouts")
                    .font(.headline)
                    .foregroundColor(Color.white)
                
                Spacer()
                
                if !fitnessViewModel.todaysWorkouts.isEmpty {
                    Text("\(fitnessViewModel.todaysWorkouts.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.primaryGreen)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
            }
            
            if fitnessViewModel.todaysWorkouts.isEmpty {
                EmptyWorkoutView {
                    showingAddWorkout = true
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(fitnessViewModel.todaysWorkouts) { workout in
                        WorkoutRow(workout: workout) {
                            selectedWorkout = workout
                            showingWorkoutDetail = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Workout Section
    
    private var quickWorkoutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Start")
                .font(.headline)
                .foregroundColor(Color.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickWorkoutButton(
                    title: "Cardio",
                    icon: "heart.fill",
                    color: .cardioColor,
                    duration: "30 min"
                ) {
                    startQuickWorkout(type: .cardio, duration: 1800)
                }
                
                QuickWorkoutButton(
                    title: "Strength",
                    icon: "dumbbell.fill",
                    color: .strengthColor,
                    duration: "45 min"
                ) {
                    startQuickWorkout(type: .strength, duration: 2700)
                }
                
                QuickWorkoutButton(
                    title: "Yoga",
                    icon: "figure.mind.and.body",
                    color: .flexibilityColor,
                    duration: "60 min"
                ) {
                    startQuickWorkout(type: .yoga, duration: 3600)
                }
                
                QuickWorkoutButton(
                    title: "Running",
                    icon: "figure.run",
                    color: .orange,
                    duration: "30 min"
                ) {
                    startQuickWorkout(type: .running, duration: 1800)
                }
            }
        }
    }
    
    // MARK: - Fitness Stats Section
    
    private var fitnessStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.headline)
                .foregroundColor(Color.white)
            
            VStack(spacing: 12) {
                FitnessStatRow(
                    title: "Total Workouts",
                    value: "\(fitnessViewModel.weeklyWorkoutCount())",
                    icon: "figure.run",
                    color: .strengthColor
                )
                
                FitnessStatRow(
                    title: "Calories Burned",
                    value: "\(fitnessViewModel.weeklyCaloriesBurned())",
                    icon: "flame",
                    color: .cardioColor
                )
                
                FitnessStatRow(
                    title: "Total Time",
                    value: formatDuration(fitnessViewModel.weeklyWorkoutTime()),
                    icon: "clock",
                    color: .flexibilityColor
                )
                
                FitnessStatRow(
                    title: "Current Streak",
                    value: "\(fitnessViewModel.currentWorkoutStreak()) days",
                    icon: "flame.fill",
                    color: .primaryYellow
                )
            }
            .nutriTrackCard()
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func startQuickWorkout(type: Workout.WorkoutType, duration: TimeInterval) {
        let workoutName = "\(type.rawValue) Workout"
        fitnessViewModel.startWorkout(name: workoutName, type: type)
        showingActiveWorkout = true
    }
}

// MARK: - Supporting Views

struct ProgressIndicator: View {
    let title: String
    let current: Int
    let goal: Int
    let color: Color
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.8))
            
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                Text("\(current)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
            }
            
            Text("/ \(goal)")
                .font(.caption2)
                .foregroundColor(Color.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct WorkoutRow: View {
    let workout: Workout
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: workoutTypeIcon(workout.workoutType))
                    .foregroundColor(workoutTypeColor(workout.workoutType))
                    .font(.title3)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                    
                    HStack(spacing: 16) {
                        WorkoutLabel(value: workout.formattedDuration, icon: "clock", color: .flexibilityColor)
                        WorkoutLabel(value: "\(workout.totalCaloriesBurned) cal", icon: "flame", color: .cardioColor)
                        WorkoutLabel(value: workout.workoutType.rawValue, icon: "tag", color: .strengthColor)
                    }
                    .font(.caption)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(workout.date.nutriTrackTimeFormatted)
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.6))
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func workoutTypeIcon(_ workoutType: Workout.WorkoutType) -> String {
        switch workoutType {
        case .cardio: return "heart.fill"
        case .strength: return "dumbbell.fill"
        case .flexibility: return "figure.mind.and.body"
        case .sports: return "sportscourt.fill"
        case .yoga: return "figure.yoga"
        case .pilates: return "figure.pilates"
        case .hiking: return "mountain.2.fill"
        case .swimming: return "figure.pool.swim"
        case .cycling: return "bicycle"
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .other: return "figure.mixed.cardio"
        }
    }
    
    private func workoutTypeColor(_ workoutType: Workout.WorkoutType) -> Color {
        switch workoutType {
        case .cardio, .running, .cycling: return .cardioColor
        case .strength: return .strengthColor
        case .flexibility, .yoga, .pilates: return .flexibilityColor
        case .sports: return .orange
        case .hiking, .walking: return .green
        case .swimming: return .blue
        case .other: return .gray
        }
    }
}

struct WorkoutLabel: View {
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(value)
                .foregroundColor(Color.white.opacity(0.8))
        }
    }
}

struct EmptyWorkoutView: View {
    let onAddWorkout: () -> Void
    
    var body: some View {
        Button(action: onAddWorkout) {
            VStack(spacing: 12) {
                Image(systemName: "figure.run.circle.dashed")
                    .font(.system(size: 50))
                    .foregroundColor(Color.white.opacity(0.6))
                
                Text("No workouts today")
                    .font(.headline)
                    .foregroundColor(Color.white.opacity(0.8))
                
                Text("Tap to add your first workout")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
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

struct QuickWorkoutButton: View {
    let title: String
    let icon: String
    let color: Color
    let duration: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.white)
                
                Text(duration)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .nutriTrackCard()
    }
}

struct FitnessStatRow: View {
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

// MARK: - Add Workout View

struct AddWorkoutView: View {
    @ObservedObject var fitnessViewModel: FitnessTrackerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var workoutName = ""
    @State private var selectedType = Workout.WorkoutType.cardio
    @State private var duration: Double = 30
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.nutriTrackBackground, Color.nutriTrackBackground.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Workout name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workout Name")
                            .font(.headline)
                            .foregroundColor(Color.white)
                        
                        TextField("Enter workout name", text: $workoutName)
                            .foregroundColor(Color.white)
                            .nutriTrackTextField()
                    }
                    
                    // Workout type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workout Type")
                            .font(.headline)
                            .foregroundColor(Color.white)
                        
                        Picker("Workout Type", selection: $selectedType) {
                            ForEach(Workout.WorkoutType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 150)
                    }
                    
                    // Duration
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration: \(Int(duration)) minutes")
                            .font(.headline)
                            .foregroundColor(Color.white)
                        
                        Slider(value: $duration, in: 5...120, step: 5)
                            .accentColor(Color.primaryGreen)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: saveWorkout) {
                            Text("Log Completed Workout")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .nutriTrackButton(style: .primary)
                        .disabled(workoutName.isEmpty)
                        
                        Button(action: startLiveWorkout) {
                            Text("Start Live Workout")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .nutriTrackButton(style: .secondary)
                        .disabled(workoutName.isEmpty)
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Add Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveWorkout() {
        fitnessViewModel.addQuickWorkout(
            name: workoutName,
            type: selectedType,
            duration: duration * 60
        )
        dismiss()
    }
    
    private func startLiveWorkout() {
        fitnessViewModel.startWorkout(name: workoutName, type: selectedType)
        dismiss()
    }
}

// MARK: - Active Workout View

struct ActiveWorkoutView: View {
    @ObservedObject var fitnessViewModel: FitnessTrackerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.nutriTrackBackground, Color.nutriTrackBackground.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Timer display
                    VStack(spacing: 8) {
                        Text("Workout Time")
                            .font(.headline)
                            .foregroundColor(Color.white.opacity(0.8))
                        
                        Text(formatDuration(fitnessViewModel.currentWorkoutDuration))
                            .font(.system(size: 60, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.primaryYellow)
                    }
                    
                    // Workout info
                    if let activeWorkout = fitnessViewModel.activeWorkout {
                        VStack(spacing: 12) {
                            Text(activeWorkout.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
                            
                            Text(activeWorkout.workoutType.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.primaryGreen.opacity(0.2))
                                .cornerRadius(16)
                                .foregroundColor(Color.primaryGreen)
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: pauseWorkout) {
                            Text("Pause Workout")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .nutriTrackButton(style: .warning)
                        
                        Button(action: endWorkout) {
                            Text("End Workout")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .nutriTrackButton(style: .secondary)
                        
                        Button(action: cancelWorkout) {
                            Text("Cancel Workout")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .nutriTrackButton(style: .danger)
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Active Workout")
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
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func pauseWorkout() {
        // Pause functionality would be implemented here
        dismiss()
    }
    
    private func endWorkout() {
        fitnessViewModel.endWorkout()
        dismiss()
    }
    
    private func cancelWorkout() {
        fitnessViewModel.cancelWorkout()
        dismiss()
    }
}

// MARK: - Workout Detail View

struct WorkoutDetailView: View {
    let workout: Workout
    @ObservedObject var fitnessViewModel: FitnessTrackerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.nutriTrackBackground, Color.nutriTrackBackground.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Workout overview
                        workoutOverviewCard
                        
                        // Exercises
                        if !workout.exercises.isEmpty {
                            exercisesCard
                        }
                        
                        // Notes
                        if let notes = workout.notes, !notes.isEmpty {
                            notesCard(notes)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle(workout.name)
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
    
    private var workoutOverviewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Overview")
                    .font(.headline)
                    .foregroundColor(Color.white)
                
                Spacer()
                
                Text(workout.date.nutriTrackDateTimeFormatted)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.8))
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.formattedDuration)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.flexibilityColor)
                    
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(workout.totalCaloriesBurned)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.cardioColor)
                    
                    Text("Calories")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.workoutType.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.strengthColor)
                    
                    Text("Type")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                }
            }
        }
        .padding()
        .nutriTrackCard()
    }
    
    private var exercisesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercises")
                .font(.headline)
                .foregroundColor(Color.white)
            
            VStack(spacing: 8) {
                ForEach(workout.exercises) { exercise in
                    ExerciseDetailRow(exercise: exercise)
                }
            }
        }
        .padding()
        .nutriTrackCard()
    }
    
    private func notesCard(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
                .foregroundColor(Color.white)
            
            Text(notes)
                .font(.body)
                .foregroundColor(Color.white.opacity(0.8))
        }
        .padding()
        .nutriTrackCard()
    }
}

struct ExerciseDetailRow: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.white)
                
                Spacer()
                
                Text(exercise.exerciseType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primaryGreen.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(Color.primaryGreen)
            }
            
            if !exercise.sets.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sets:")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                    
                    ForEach(Array(exercise.sets.enumerated()), id: \.offset) { index, set in
                        HStack {
                            Text("Set \(index + 1):")
                                .font(.caption)
                                .foregroundColor(Color.white.opacity(0.6))
                            
                            if set.weight > 0 {
                                Text("\(set.reps) reps × \(String(format: "%.1f", set.weight)) kg")
                                    .font(.caption)
                                    .foregroundColor(Color.white.opacity(0.8))
                            } else if let duration = set.duration {
                                Text("\(Int(duration / 60)):\(String(format: "%02d", Int(duration) % 60))")
                                    .font(.caption)
                                    .foregroundColor(Color.white.opacity(0.8))
                            } else {
                                Text("\(set.reps) reps")
                                    .font(.caption)
                                    .foregroundColor(Color.white.opacity(0.8))
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    FitnessTrackerView(fitnessViewModel: FitnessTrackerViewModel())
} 