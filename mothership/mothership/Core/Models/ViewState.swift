//
//  ViewState.swift
//  mothership
//
//  Generic UI state container for async data flows
//

import Foundation

enum ViewState<Value> {
    case idle
    case loading
    case loaded(Value)
    case empty
    case error(AppError)
    
    var data: Value? {
        if case .loaded(let value) = self {
            return value
        }
        return nil
    }
    
    var errorValue: AppError? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var isEmpty: Bool {
        if case .empty = self {
            return true
        }
        return false
    }
}

