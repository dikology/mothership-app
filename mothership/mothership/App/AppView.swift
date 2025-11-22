//
//  AppView.swift
//  mothership
//
//  Main app view with navigation
//

import SwiftUI

struct AppView: View {
    @Bindable var model: AppModel
    @Environment(\.localization) private var localization
    @Environment(\.charterStore) private var charterStore
    @State private var selectedTab: MainTab = .home
    
    enum MainTab: String, CaseIterable {
        case home
        case learn
        case practice
        // case profile
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .learn: return "book.fill"
            case .practice: return "checklist"
            // case .profile: return "person.fill"  
            }
        }
        
        func localizedName(_ key: String) -> String {
            return key
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
        case .learn:
            LearnView()
        case .practice:
            PracticeView()
        // case .profile:
        //     ProfileView()
        }
    }
    
    @ViewBuilder
    private func destinationView(for path: AppPath) -> some View {
        switch path {
        case .charterDetail(let id):
            if let charter = charterStore.charters.first(where: { $0.id == id }) {
                CharterDetailView(charter: charter)
            }
        case .charterEdit(let id):
            if let charter = charterStore.charters.first(where: { $0.id == id }) {
                CharterEditView(charter: charter)
            }
        case .charterCreation:
            CharterCreationView()
        case .checkInChecklist(let charterId):
            CheckInChecklistView(charterId: charterId)
        case .practiceModule(let moduleID):
            if let uuid = UUID(uuidString: moduleID) {
                PracticeModuleDetailView(moduleID: uuid)
            } else {
                Text(localization.localized(L10n.Common.comingSoon))
                    .font(AppTypography.title1)
            }
        case .flashcardDeck(let deckID):
            FlashcardReviewView(deckID: deckID)
        }
    }
}

// Custom Tab Bar Component
struct CustomTabBar: View {
    @Binding var selectedTab: AppView.MainTab
    @Environment(\.localization) private var localization
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppView.MainTab.allCases, id: \.self) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    localization: localization
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
    let localization: LocalizationService
    let action: () -> Void
    
    private func localizedTabName(for tab: AppView.MainTab) -> String {
        switch tab {
        case .home: return localization.localized(L10n.Tab.home)
        case .learn: return localization.localized(L10n.Tab.learn)
        case .practice: return localization.localized(L10n.Tab.practice)
        }
    }
    
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
                Text(localizedTabName(for: tab))
                    .font(AppTypography.tabBar)
                    .foregroundColor(isSelected ? AppColors.tabBarSelected : AppColors.tabBarUnselected)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AppView(model: AppModel())
        .environment(\.localization, LocalizationService())
        .environment(\.charterStore, CharterStore())
        .environment(\.checklistStore, ChecklistStore())
        .environment(\.flashcardStore, FlashcardStore())
}

