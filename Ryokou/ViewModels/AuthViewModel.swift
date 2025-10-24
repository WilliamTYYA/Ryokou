//
//  AuthViewModel.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/24/25.
//

import SwiftUI
import Observation
import Security

// MARK: - Keychain (tiny helper)
enum Keychain {
    static func set(_ value: Data, for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func get(_ key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var out: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &out)
        return out as? Data
    }
    
    static func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

@MainActor
@Observable
final class AuthViewModel {
    // UI state
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    // Mirrored state from storage (read-only for views)
    private(set) var isLoggedIn: Bool = false
    private(set) var username: String = ""
    
    // Basic validation
    var canSubmit: Bool {
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return !isLoading && e.contains("@") && password.count >= 6
    }
    
    // Called by the view on appear with values from AppStorage
    func bootstrap(isLoggedIn: Bool, username: String) {
        self.isLoggedIn = isLoggedIn
        self.username = username
    }
    
    // Keep VM in sync if AppStorage changes (e.g. other screens)
    func update(isLoggedIn: Bool) { self.isLoggedIn = isLoggedIn }
    func update(username: String)  { self.username   = username }
    
    // Sign in, then ask the caller to persist to AppStorage via commit
    func signIn(commit: (_ isLoggedIn: Bool, _ username: String) -> Void) async {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // TODO: Replace with a real network call
        try? await Task.sleep(nanoseconds: 450_000_000)
        
        // Example failure:
        // if email.lowercased().hasSuffix("@blocked.com") { errorMessage = "Access denied"; return }
        
        // Success
        let cleanUser = email.trimmingCharacters(in: .whitespacesAndNewlines)
        commit(true, cleanUser)            // writes to @AppStorage
        self.isLoggedIn = true             // mirror in VM
        self.username = cleanUser
        self.password = ""                 // clear sensitive input
    }
    
    // Sign out, caller removes AppStorage values in commit
    func signOut(commit: () -> Void) {
        commit()                           // writes to @AppStorage
        self.isLoggedIn = false            // mirror in VM
        self.username = ""
        self.email = ""
        self.password = ""
        self.errorMessage = nil
    }
}
