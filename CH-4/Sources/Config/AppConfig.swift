//
//  AppConfig.swift
//  CH-4
//
//  Created by Rafie Amandio F on 24/08/25.
//

import Foundation

    public enum AppConfig {
        // MARK: - Supabase Configuration
        static let supabaseURL = "https://tzmpjbvopjlreyyxffdl.supabase.co"
        static let supabaseAnonKey = "sb_publishable_Xiy53BohXAynDGjChTKeHg_q8pBG6BO"
        
        // MARK: - Backend Configuration
        static let backendBaseURL = "https://minecraft-server-ch4-be.dgrttk.easypanel.host/api"
        static let developmentURL = "http://localhost:3000"
        
        // MARK: - App Configuration
        static let appName = "CH-4"
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        
        static let isDebug = false
    }
