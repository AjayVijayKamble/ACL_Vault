//
//  MainTabView.swift
//  ACLVault
//
//  Root Tab Bar Navigation Architecture
//

import SwiftUI
import SwiftData

public struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    
    @State private var selectedTab: TabItem = .home
    
    public enum TabItem: Int, CaseIterable, Identifiable {
        case home = 0
        case romStudio = 1
        case exercises = 2
        case progression = 3
        case profile = 4
        
        public var id: Int { rawValue }
        
        public var title: String {
            switch self {
            case .home: return "Today"
            case .romStudio: return "ROM Studio"
            case .exercises: return "Exercises"
            case .progression: return "Progression"
            case .profile: return "Clinical Log"
            }
        }
        
        public var icon: String {
            switch self {
            case .home: return "house.fill"
            case .romStudio: return "ruler.fill"
            case .exercises: return "figure.run"
            case .progression: return "chart.bar.xaxis"
            case .profile: return "person.text.rectangle.fill"
            }
        }
    }
    
    private var profile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    public init() {}
    
    public var body: some View {
        Group {
            if !profile.hasCompletedOnboarding {
                OnboardingView()
            } else {
                TabView(selection: $selectedTab) {
                    HomeDashboardView()
                        .tabItem {
                            Label(TabItem.home.title, systemImage: TabItem.home.icon)
                        }
                        .tag(TabItem.home)
                    
                    ROMStudioView()
                        .tabItem {
                            Label(TabItem.romStudio.title, systemImage: TabItem.romStudio.icon)
                        }
                        .tag(TabItem.romStudio)
                    
                    ExerciseLibraryView()
                        .tabItem {
                            Label(TabItem.exercises.title, systemImage: TabItem.exercises.icon)
                        }
                        .tag(TabItem.exercises)
                    
                    ProgressionMapView()
                        .tabItem {
                            Label(TabItem.progression.title, systemImage: TabItem.progression.icon)
                        }
                        .tag(TabItem.progression)
                    
                    ProfileAndReportView()
                        .tabItem {
                            Label(TabItem.profile.title, systemImage: TabItem.profile.icon)
                        }
                        .tag(TabItem.profile)
                }
                .tint(Color.recoveryTeal)
                .onAppear {
                    configureTabBarAppearance()
                }
            }
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.vaultCardSurface)
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.vaultTextMuted)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.vaultTextMuted)
        ]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.recoveryTeal)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.recoveryTeal)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

