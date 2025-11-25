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
        // Only use NSLog to avoid duplicate logs
        // Remove emoji from message since NSLog format already includes it
        NSLog("❌ %@", message.replacingOccurrences(of: "❌ ", with: ""))
    }
    
    /// Log warnings
    static func warning(_ message: String) {
        // Only use NSLog to avoid duplicate logs
        NSLog("⚠️ %@", message.replacingOccurrences(of: "⚠️ ", with: ""))
    }
    
    /// Log general info
    static func info(_ message: String) {
        // Only use NSLog to avoid duplicate logs
        // Remove emoji from message since NSLog format already includes it
        NSLog("ℹ️ %@", message.replacingOccurrences(of: "ℹ️ ", with: ""))
    }
    
    /// Log debug info
    static func debug(_ message: String) {
        // Only use NSLog to avoid duplicate logs
        NSLog("🔍 %@", message.replacingOccurrences(of: "🔍 ", with: ""))
    }
}

