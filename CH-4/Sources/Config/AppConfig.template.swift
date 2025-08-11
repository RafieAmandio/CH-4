//
//  AppConfig.swift
//  CH-4
//
//  Created by Dwiki on 11/08/25.
//

import Foundation

public enum AppConfig {
    // MARK: - Supabase Configuration
    static let supabaseURL = "YOUR_SUPABASE_URL"
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
    
    // MARK: - App Configuration
    static let appName = "CH-4"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
}
