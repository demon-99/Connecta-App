//
//  AuthService.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//


// Define the AuthService to handle the simple login request
import Foundation

class AuthService {
    static let shared = AuthService() // Singleton
    
    private let loginURL = "http://172.20.10.3:8081/api/user/login"
    private let profileURL = "http://172.20.10.3:8081/api/user/profile"
    private let signUpURL = "http://172.20.10.3:8081/api/user/create"

    // MARK: - Login
    func login(usernameOrEmail: String, password: String, completion: @escaping (Result<LoginResponseDto, Error>) -> Void) {
        let loginRequest = LoginRequest(usernameOrEmail: usernameOrEmail, password: password)
        
        guard let url = URL(string: loginURL) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(loginRequest)
        } catch {
            completion(.failure(NetworkError.encodingError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            Task { @MainActor in
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponseDto.self, from: data)
                    completion(.success(loginResponse))
                } catch {
                    print("Login decoding error: \(error)")
                    if let json = String(data: data, encoding: .utf8) {
                        print("Raw login response JSON: \(json)")
                    }
                    completion(.failure(NetworkError.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch User Profile
    func fetchUserProfile(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: profileURL) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: userId)]
        
        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            Task { @MainActor in
                do {
                    // Decode strictly only the fields returned by Spring
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(User.self, from: data)
                    completion(.success(user))
                } catch {
                    print("Profile decoding error: \(error)")
                    if let json = String(data: data, encoding: .utf8) {
                        print("Raw profile JSON: \(json)")
                    }
                    completion(.failure(NetworkError.decodingError))
                }
            }
        }.resume()
    }
    
    func signUp(user: SignUpRequest, completion: @escaping (Result<String, Error>) -> Void) {
            guard let url = URL(string: signUpURL) else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONEncoder().encode(user)
            } catch {
                completion(.failure(NetworkError.encodingError))
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          200..<300 ~= httpResponse.statusCode else {
                        completion(.failure(NetworkError.noData))
                        return
                    }
                    
                    completion(.success("User created successfully"))
                }
            }.resume()
        }
}

// MARK: - Network Errors
enum NetworkError: Error {
    case invalidURL
    case encodingError
    case noData
    case decodingError
}
