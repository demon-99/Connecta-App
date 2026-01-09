//
//  LoginView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//
//
//  LoginView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

//
//  LoginView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

//
//  LoginView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var usernameOrEmail = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .padding(.top, 50)

            TextField("Username or Email", text: $usernameOrEmail)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 20)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 20)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
            }

            if authVM.isLoading {
                ProgressView()
                    .padding()
            }

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
        }
        .padding(.top, 40)
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
                    // Safely unwrap the optional userId
                    if let userId = response.userId, !userId.isEmpty {
                        // Fetch user profile
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
