
//
//  LoginView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.

import SwiftUI


struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var usernameOrEmail = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationView { // <-- Wrap in NavigationView
            VStack(spacing: 20) {
                // Title
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)

                // Username/Email field
                TextField("Username or Email", text: $usernameOrEmail)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)

                // Password field
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)

                // Error message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                }

                // Loading indicator
                if authVM.isLoading {
                    ProgressView()
                        .padding()
                }

                // Login button
                Button(action: login) {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                }
                .disabled(authVM.isLoading)

                Spacer()

                // Sign Up button like Tinder
                NavigationLink(destination: SignUpView()) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 30)

            }
            .padding(.top, 40)
            .navigationBarHidden(true)
        }
    }

    private func login() {
        guard !usernameOrEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        errorMessage = ""
        authVM.isLoading = true

        AuthService.shared.login(usernameOrEmail: usernameOrEmail, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let userId = response.userId, !userId.isEmpty {
                        authVM.login(userId: userId)
                    } else {
                        authVM.isLoading = false
                        errorMessage = "Invalid server response"
                    }

                case .failure(let error):
                    authVM.isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
