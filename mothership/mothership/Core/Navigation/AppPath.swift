//
//  AppPath.swift
//  mothership
//
//  Type-safe navigation paths
//

import Foundation

enum AppPath: Hashable {
    
    // Charter paths
    case charterCreation
    case charterDetail(Charter.ID)
    case charterEdit(Charter.ID)
    case checkInChecklist(Charter.ID)
    
    // Practice paths
    case practiceModule(String)
    
    // Learn paths
    case flashcardDeck(FlashcardDeck.ID)
}

