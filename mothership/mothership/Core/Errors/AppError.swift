//
//  AppError.swift
//  mothership
//
//  Centralized error taxonomy for presenting user-friendly feedback
//

import Foundation

/// Common interface for errors that can be surfaced to the UI layer

/// Unified error that wraps domain-specific failures so views can react consistently
enum AppError: Error, Identifiable, @unchecked Sendable {
    case network(NetworkError)
    case auth(AuthError)
    case content(ContentError)
    case validation(ValidationError)
    case unknown(underlying: Error?)
    
    var id: String {
        switch self {
        case .network(let error):
            return "network.\(error.identifier)"
        case .auth(let error):
            return "auth.\(error.identifier)"
        case .content(let error):
            return "content.\(error.identifier)"
        case .validation(let error):
            return "validation.\(error.identifier)"
        case .unknown:
            return "unknown.\(localizationKey)"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .network(let error):
            return error.isRetryable
        case .auth(let error):
            return error.isRetryable
        case .content(let error):
            return error.isRetryable
        case .validation:
            return false
        case .unknown:
            return true
        }
    }
    
    var underlyingError: Error? {
        switch self {
        case .network(let error):
            return error.underlying
        case .auth(let error):
            return error.underlying
        case .content(let error):
            return error.underlying
        case .validation:
            return nil
        case .unknown(let error):
            return error
        }
    }
    
    private var localizationKey: String {
        switch self {
        case .network(let error):
            return error.localizationKey
        case .auth(let error):
            return error.localizationKey
        case .content(let error):
            return error.localizationKey
        case .validation(let error):
            return error.localizationKey
        case .unknown:
            return L10n.Error.generic
        }
    }
    
    private var localizationArguments: [CVarArg] {
        switch self {
        case .network(let error):
            return error.localizationArguments
        case .auth(let error):
            return error.localizationArguments
        case .content(let error):
            return error.localizationArguments
        case .validation(let error):
            return error.localizationArguments
        case .unknown(let error):
            guard let message = error?.localizedDescription, !message.isEmpty else {
                return []
            }
            return [message]
        }
    }

    /// Produce a localized message respecting the user-selected language
    func localizedDescription(using localization: LocalizationService) -> String {
        let format = localization.localized(localizationKey)
        let arguments = localizationArguments
        guard !arguments.isEmpty else {
            return format
        }
        let locale = Locale(identifier: localization.effectiveLanguage.code)
        return String(format: format, locale: locale, arguments: arguments)
    }
}

// MARK: - Sendable Conformance

extension NetworkError: @unchecked Sendable {}
extension AuthError: @unchecked Sendable {}
extension ContentError: @unchecked Sendable {}
extension ValidationError: @unchecked Sendable {}

// MARK: - Network Errors

enum NetworkError {
    case offline
    case timedOut
    case server(statusCode: Int)
    case rateLimited(timeUntilReset: TimeInterval?)
    case unreachableHost
    case unknown(underlying: Error? = nil)
    
    var identifier: String {
        switch self {
        case .offline: return "offline"
        case .timedOut: return "timeout"
        case .server(let code): return "server.\(code)"
        case .rateLimited: return "rateLimit"
        case .unreachableHost: return "unreachable"
        case .unknown: return "unknown"
        }
    }
    
    var underlying: Error? {
        if case let .unknown(error) = self {
            return error
        }
        return nil
    }
    
    var isRetryable: Bool {
        switch self {
        case .rateLimited:
            return false
        default:
            return true
        }
    }
    
    var localizationKey: String {
        switch self {
        case .offline, .unreachableHost:
            return L10n.Error.networkConnection
        case .timedOut:
            return L10n.Error.timeout
        case .server:
            return L10n.Error.server
        case .rateLimited:
            return L10n.Error.rateLimit
        case .unknown:
            return L10n.Error.generic
        }
    }
    
    var localizationArguments: [CVarArg] {
        switch self {
        case .server(let statusCode):
            return [statusCode]
        case .rateLimited(let timeUntilReset):
            if let timeUntilReset {
                return [AppErrorFormatter.format(timeInterval: timeUntilReset)]
            }
            return []
        default:
            return []
        }
    }
}

// MARK: - Auth Errors

enum AuthError {
    case unauthorized
    case sessionExpired
    case signInRequired
    case signInFailed
    case unknown(underlying: Error? = nil)
    
    var identifier: String {
        switch self {
        case .unauthorized: return "unauthorized"
        case .sessionExpired: return "sessionExpired"
        case .signInRequired: return "signInRequired"
        case .signInFailed: return "signInFailed"
        case .unknown: return "unknown"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .signInFailed:
            return true
        default:
            return false
        }
    }
    
    var underlying: Error? {
        if case let .unknown(error) = self {
            return error
        }
        return nil
    }
    
    var localizationKey: String {
        switch self {
        case .unauthorized, .sessionExpired, .signInRequired:
            return L10n.Error.unauthorized
        case .signInFailed:
            return L10n.Error.signInFailed
        case .unknown:
            return L10n.Error.generic
        }
    }
    
    var localizationArguments: [CVarArg] { [] }
}

// MARK: - Content Errors

enum ContentError {
    case notFound
    case invalidData
    case empty
    case malformed
    case cacheUnavailable
    case unknown(underlying: Error? = nil)
    
    var identifier: String {
        switch self {
        case .notFound: return "notFound"
        case .invalidData: return "invalidData"
        case .empty: return "empty"
        case .malformed: return "malformed"
        case .cacheUnavailable: return "cacheUnavailable"
        case .unknown: return "unknown"
        }
    }
    
    var underlying: Error? {
        if case let .unknown(error) = self {
            return error
        }
        return nil
    }
    
    var isRetryable: Bool {
        switch self {
        case .cacheUnavailable:
            return true
        default:
            return false
        }
    }
    
    var localizationKey: String {
        switch self {
        case .notFound:
            return L10n.Error.notFound
        case .invalidData:
            return L10n.Error.invalidData
        case .empty:
            return L10n.Error.emptyDeck
        case .malformed:
            return L10n.Error.malformedMarkdown
        case .cacheUnavailable:
            return L10n.Error.cacheUnavailable
        case .unknown:
            return L10n.Error.generic
        }
    }
    
    var localizationArguments: [CVarArg] { [] }
}

// MARK: - Validation Errors

enum ValidationError {
    case invalidInput
    case missingField(fieldName: String?)
    
    var identifier: String {
        switch self {
        case .invalidInput: return "invalidInput"
        case .missingField(let field):
            return "missingField.\(field ?? "unknown")"
        }
    }
    
    var localizationKey: String {
        switch self {
        case .invalidInput:
            return L10n.Error.validation
        case .missingField:
            return L10n.Error.validation
        }
    }
    
    var localizationArguments: [CVarArg] {
        switch self {
        case .missingField(let fieldName):
            if let fieldName, !fieldName.isEmpty {
                return [fieldName]
            }
            return []
        default:
            return []
        }
    }
    
    var isRetryable: Bool { false }
}

// MARK: - Formatter

private enum AppErrorFormatter {
    static func format(timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        
        let clamped = max(1, timeInterval)
        if let formatted = formatter.string(from: clamped) {
            return formatted
        }
        let minutes = Int(ceil(clamped / 60))
        return "\(minutes) min"
    }
}

// MARK: - Mapping Helpers

extension AppError {
    /// Convenience mapper that transforms arbitrary `Error` into `AppError`
    static func map(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        if let contentError = error as? ContentFetchError {
            return contentError.asAppError
        }
        
        if error is RetryError {
            return .network(.timedOut)
        }
        
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return .network(.offline)
            case NSURLErrorTimedOut:
                return .network(.timedOut)
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                return .network(.unreachableHost)
            default:
                return .network(.unknown(underlying: error))
            }
        }
        
        return .unknown(underlying: error)
    }
}

extension Error {
    var asAppError: AppError {
        AppError.map(self)
    }
}

extension ContentFetchError {
    var asAppError: AppError {
        switch self {
        case .invalidURL:
            return .content(.invalidData)
        case .fetchFailed(let statusCode, _):
            guard let statusCode else {
                return .network(.unknown())
            }
            
            switch statusCode {
            case 401, 403:
                return .auth(.unauthorized)
            case 404:
                return .content(.notFound)
            case 408:
                return .network(.timedOut)
            case 500...599:
                return .network(.server(statusCode: statusCode))
            default:
                return .network(.unknown())
            }
        case .invalidData:
            return .content(.invalidData)
        case .networkError(let error):
            return error.asAppError
        case .rateLimited(let timeUntilReset):
            return .network(.rateLimited(timeUntilReset: timeUntilReset))
        case .cacheUnavailable:
            return .content(.cacheUnavailable)
        }
    }
    
    func localizedMessage(using localization: LocalizationService) -> String {
        asAppError.localizedDescription(using: localization)
    }
}
