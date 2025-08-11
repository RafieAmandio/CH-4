//
//  SupabaseClientProvider.swift
//  CH-4
//
//  Created by Dwiki on 11/08/25.
//

import Foundation
import Supabase

public protocol SupabaseClientProvider {
    var client: SupabaseClient { get }
}

public final class DefaultSupabaseClientProvider: SupabaseClientProvider {
    public let client: SupabaseClient

    public init(url: URL, anonKey: String) {
        self.client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
    }
}
