import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showMainApp = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    let pages = OnboardingPage.allPages
    
    var body: some View {
        if showMainApp {
            ContentView()
        } else {
            ZStack {
                LinearGradient(
                    colors: [Color.nutriTrackBackground, Color.nutriTrackBackground.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    // Progress indicator
                    HStack {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.primaryYellow : Color.white.opacity(0.2))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(pages.indices, id: \.self) { index in
                            OnboardingPageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.5), value: currentPage)
                    
                    // Navigation buttons
                    VStack(spacing: 16) {
                        if currentPage == pages.count - 1 {
                            Button(action: completeOnboarding) {
                                Text("Get Started")
                                    .font(.headline)
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity)
                            }
                            .nutriTrackButton(style: .primary)
                        } else {
                            Button(action: nextPage) {
                                Text("Continue")
                                    .font(.headline)
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity)
                            }
                            .nutriTrackButton(style: .primary)
                        }
                        
                        if currentPage > 0 {
                                                    Button(action: previousPage) {
                            Text("Back")
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                    }
                    
                    Button(action: skipOnboarding) {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private func nextPage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentPage < pages.count - 1 {
                currentPage += 1
            }
        }
    }
    
    private func previousPage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentPage > 0 {
                currentPage -= 1
            }
        }
    }
    
    private func skipOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
            showMainApp = true
        }
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
            showMainApp = true
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.primaryYellow, Color.primaryGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.primaryYellow.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Image(systemName: page.iconName)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let iconName: String
    
    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to NutriTrack",
            description: "Your personal companion for achieving optimal health through smart nutrition and fitness tracking.",
            iconName: "heart.fill"
        ),
        OnboardingPage(
            title: "Track Your Nutrition",
            description: "Log meals, monitor calories, and get detailed insights into your nutritional intake with our comprehensive food database.",
            iconName: "fork.knife"
        ),
        OnboardingPage(
            title: "Monitor Your Fitness",
            description: "Record workouts, track progress, and stay motivated with personalized fitness goals and achievements.",
            iconName: "figure.run"
        ),
        OnboardingPage(
            title: "Achieve Your Goals",
            description: "Get personalized recommendations, daily tips, and insights to help you maintain a healthy lifestyle.",
            iconName: "target"
        ),
        OnboardingPage(
            title: "Ready to Start?",
            description: "Join thousands of users who have transformed their health journey with NutriTrack. Let's begin yours today!",
            iconName: "star.fill"
        )
    ]
}

#Preview {
    OnboardingView()
} 