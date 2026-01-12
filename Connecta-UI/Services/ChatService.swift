//
//  ChatService.swift
//  Connecta-UI
//
//  Created by Nikhil on 08/01/26.
//  Updated with chat list functionality
//

import Foundation

class ChatService {
    
    static let shared = ChatService() // Singleton
    
    private let baseURL = "http://172.20.10.3:8080/api/chat"
    
    // MARK: - Get Chat List
    func getChatList(
        userName: String,
        completion: @escaping (Result<[ChatListItem], Error>) -> Void
    ) {
        let urlString = "\(baseURL)/chats?userName=\(userName)"
        
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            // Debug: Print raw JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Chat List Raw JSON:\n\(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let chatList = try decoder.decode([ChatListItem].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(chatList))
                }
            } catch {
                print("Chat List decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: - Get Chat History
    func getChatHistory(
        authorName: String,
        receiverName: String,
        completion: @escaping (Result<[Message], Error>) -> Void
    ) {
        let urlString = "\(baseURL)/chatHistory?authorName=\(authorName)&receiverName=\(receiverName)"
        
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Chat History Raw JSON:\n\(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let messages = try decoder.decode([Message].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(messages))
                }
            } catch {
                print("Chat History decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: - Send Message
    func sendMessage(
        _ message: Message,
        completion: @escaping (Result<Message, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/send") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            let bodyData = try encoder.encode(message)
            request.httpBody = bodyData
            
            // Debug: Print request body
            if let jsonString = String(data: bodyData, encoding: .utf8) {
                print("Send Message Request Body:\n\(jsonString)")
            }
        } catch {
            completion(.failure(NetworkError.encodingError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let sentMessage = try decoder.decode(Message.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(sentMessage))
                }
            } catch {
                print("Send Message decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingError))
                }
            }
        }.resume()
    }
}
