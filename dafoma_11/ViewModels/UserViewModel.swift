import SwiftUI
import Foundation

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadUser()
    }
    
    // MARK: - User Management
    
    func loadUser() {
        isLoading = true
        
        // Load user from UserDefaults (in a real app, you'd use Core Data or CloudKit)
        if let userData = UserDefaults.standard.data(forKey: "userData"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
        
        isLoading = false
    }
    
    func saveUser(_ user: User) {
        isLoading = true
        
        do {
            let userData = try JSONEncoder().encode(user)
            UserDefaults.standard.set(userData, forKey: "userData")
            currentUser = user
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save user data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateUser(_ updatedUser: User) {
        saveUser(updatedUser)
    }
    
    func addFitnessGoal(_ goal: User.FitnessGoal) {
        guard var user = currentUser else { return }
        user.fitnessGoals.append(goal)
        saveUser(user)
    }
    
    func removeFitnessGoal(goalId: UUID) {
        guard var user = currentUser else { return }
        user.fitnessGoals.removeAll { $0.id == goalId }
        saveUser(user)
    }
    
    func updateFitnessGoal(_ updatedGoal: User.FitnessGoal) {
        guard var user = currentUser else { return }
        
        if let index = user.fitnessGoals.firstIndex(where: { $0.id == updatedGoal.id }) {
            user.fitnessGoals[index] = updatedGoal
            saveUser(user)
        }
    }
    
    func addDietaryRestriction(_ restriction: String) {
        guard var user = currentUser else { return }
        
        if !user.dietaryRestrictions.contains(restriction) {
            user.dietaryRestrictions.append(restriction)
            saveUser(user)
        }
    }
    
    func removeDietaryRestriction(_ restriction: String) {
        guard var user = currentUser else { return }
        user.dietaryRestrictions.removeAll { $0 == restriction }
        saveUser(user)
    }
    
    // MARK: - Calculated Properties
    
    var dailyCalorieGoal: Int {
        currentUser?.dailyCalorieGoal ?? 2000
    }
    
    var bmi: Double? {
        guard let user = currentUser else { return nil }
        let heightInMeters = user.height / 100
        return user.weight / (heightInMeters * heightInMeters)
    }
    
    var bmiCategory: String {
        guard let bmi = bmi else { return "Unknown" }
        
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
    
    var isUserSetup: Bool {
        currentUser != nil
    }
    
    // MARK: - Helper Methods
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "userData")
        currentUser = nil
    }
    
    func resetToDefaults() {
        clearUserData()
        errorMessage = nil
        isLoading = false
    }
    
    // MARK: - Demo Data
    
    func createDemoUser() {
        let demoUser = User(
            name: "Demo User",
            age: 28,
            height: 175,
            weight: 70,
            activityLevel: .moderatelyActive,
            dietaryGoal: .maintainWeight
        )
        saveUser(demoUser)
    }
} 