//
//  AppLogger.swift
//  mothership
//
//  Centralized logging that works reliably in Xcode console
//

import Foundation
import os.log

/// Centralized logger that ensures logs appear in Xcode console
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.mothership"
    private static let logger = Logger(subsystem: subsystem, category: "RateLimit")
    
    /// Log rate limit related messages (always visible in Xcode console)
    static func rateLimit(_ message: String) {
        logger.info("\(message)")
        // Also use NSLog for maximum visibility
        NSLog("📊 RateLimit: %@", message)
    }
    
    /// Log HTTP response details
    static func httpResponse(_ message: String) {
        logger.info("\(message)")
        NSLog("📡 HTTP: %@", message)
    }
    
    /// Log errors
    static func error(_ message: String) {
        logger.error("\(message)")
        NSLog("❌ Error: %@", message)
    }
    
    /// Log warnings
    static func warning(_ message: String) {
        logger.warning("\(message)")
        NSLog("⚠️ Warning: %@", message)
    }
    
    /// Log general info
    static func info(_ message: String) {
        logger.info("\(message)")
        NSLog("ℹ️ Info: %@", message)
    }
    
    /// Log debug info
    static func debug(_ message: String) {
        logger.debug("\(message)")
        NSLog("🔍 Debug: %@", message)
    }
}

