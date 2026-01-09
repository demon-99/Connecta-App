//
//  AuthViewModel.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//
import SwiftUI
import Combine



final class AuthViewModel: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("currentUser") private var currentUserData: Data = Data()
    
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false

    init() {
        // REMOVE OLD LOGIN DATA DURING DEV
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "currentUser")
        }
        
        loadUserFromStorage()
    }
    
    func login(userId: String) {
        self.isLoading = true
        AuthService.shared.fetchUserProfile(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.currentUser = user
                    self?.saveUserToStorage()
                    self?.isLoggedIn = true
                case .failure(let error):
                    print("Profile fetch failed: \(error)")
                }
                self?.isLoading = false   // ✅ Always stop spinner
            }
        }
    }

    
    func logout() {
        currentUser = nil
        currentUserData = Data()
        isLoggedIn = false
    }
    
    private func saveUserToStorage() {
        guard let user = currentUser else { return }
        if let data = try? JSONEncoder().encode(user) {
            currentUserData = data
        }
    }
    
    private func loadUserFromStorage() {
        if let user = try? JSONDecoder().decode(User.self, from: currentUserData) {
            self.currentUser = user
        }
    }
}
