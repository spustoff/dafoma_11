//
//  dafoma_11App.swift
//  dafoma_11
//
//  Created by Вячеслав on 7/26/25.
//

import SwiftUI

@main
struct dafoma_11App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    setupAppearance()
                }
        }
    }
    
    private func setupAppearance() {
        // Configure navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(Color.nutriTrackBackground)
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.white)
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.white)
        ]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // Configure status bar style
        UIApplication.shared.statusBarStyle = .lightContent
    }
}
