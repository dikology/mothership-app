//
//  AppView.swift
//  mothership
//
//  Main app view with navigation
//

import SwiftUI

struct AppView: View {
    @Bindable var model: AppModel
    @State private var selectedTab: MainTab = .home
    
    enum MainTab: String, CaseIterable {
        case home = "Home"
        // case learn = "Learn"
        // case practice = "Practice"
        // case profile = "Profile"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            // case .learn: return "book.fill"
            // case .practice: return "checklist"
            // case .profile: return "person.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $model.path) {
            ZStack(alignment: .bottom) {
                // Content view
                selectedTabView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, AppSpacing.tabBarHeight)
                
                // Custom tab bar
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .navigationDestination(for: AppPath.self) { path in
                destinationView(for: path)
            }
        }
    }
    
    @ViewBuilder
    private var selectedTabView: some View {
        switch selectedTab {
        case .home:
            HomeView()
        // case .learn:
        //     LearnView()
        // case .practice:
        //     PracticeView()
        // case .profile:
        //     ProfileView()
        }
    }
    
    @ViewBuilder
    private func destinationView(for path: AppPath) -> some View {
        switch path {
        default:
            Text("Coming soon")
                .font(AppTypography.title1)
        }
    }
}

// Custom Tab Bar Component
struct CustomTabBar: View {
    @Binding var selectedTab: AppView.MainTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppView.MainTab.allCases, id: \.self) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    selectedTab = tab
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: AppSpacing.tabBarHeight)
        .background(AppColors.tabBarBackground)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .top
        )
    }
}

struct TabBarItem: View {
    let tab: AppView.MainTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Icon with optional background for selected state
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.tabBarSelected)
                            .frame(width: 46, height: 46)
                    }
                    
                    // Icon - use SF Symbol
                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(isSelected ? .white : AppColors.tabBarUnselected)
                }
                .frame(width: 46, height: 46)
                
                // Text label
                Text(tab.rawValue)
                    .font(AppTypography.tabBar)
                    .foregroundColor(isSelected ? AppColors.tabBarSelected : AppColors.tabBarUnselected)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AppView(model: AppModel())
}

