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
}

