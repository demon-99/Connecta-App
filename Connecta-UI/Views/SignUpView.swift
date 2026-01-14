//
//  SignUpView.swift
//  Connecta-UI
//
//  Created by Nikhil on 12/01/26.
//
import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var fullName: String = ""
    @State private var userName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToLogin = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                // Tinder-style big title
                Text("Create your account")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.red)
                    .padding(.top, 40)
                
                Text("Please complete all information to create an account.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Input fields
                VStack(spacing: 16) {
                    InputView(placeholder: "Email or Phone Number", text: $email)
                    InputView(placeholder: "Full Name", text: $fullName)
                    InputView(placeholder: "User Name", text: $userName)
                    InputView(placeholder: "Password", isSecureField: true, text: $password)
                    
                    ZStack(alignment: .trailing) {
                        InputView(
                            placeholder: "Confirm your password",
                            isSecureField: true,
                            text: $confirmPassword
                        )
                        
                        if !password.isEmpty && !confirmPassword.isEmpty {
                            Image(systemName: isValidPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(isValidPassword ? .green : .red)
                                .padding(.trailing, 40)
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .animation(.easeInOut, value: confirmPassword)
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                // Create Account button
                Button {
                    createAccount()
                } label: {
                    Text("Create Account")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .clipShape(Capsule())
                        .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Spacer()
                
                // Bottom Login prompt
                HStack(spacing: 5) {
                    Text("Already a member?")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    
                    NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                        Text("Login")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                            .font(.footnote)
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Sign Up"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertMessage == "User created successfully!" {
                            navigateToLogin = true // auto navigate to login
                        }
                    }
                )
            }
        }
    }
    
    var isValidPassword: Bool {
        confirmPassword == password
    }
    
    private func createAccount() {
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill all fields"
            showAlert = true
            return
        }
        
        let names = fullName.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        let firstName = names.first.map(String.init) ?? ""
        let lastName = names.count > 1 ? String(names[1]) : ""
        
        let user = SignUpRequest(
            firstName: firstName,
            lastName: lastName,
            username: userName,
            email: email,
            password: password
        )
        
        AuthService.shared.signUp(user: user) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    alertMessage = message
                    showAlert = true
                case .failure(let error):
                    alertMessage = "Sign up failed: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}
