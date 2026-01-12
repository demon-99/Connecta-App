//
//  ChatService.swift
//  Connecta-UI
//
//  Created by Nikhil on 08/01/26.
//
import Foundation

class ChatService {
    
    private let baseURL = "http://192.168.172.101:8080/api/chat"
    
    // MARK: - Get Chat History
    func getChatHistory(
        authorName: String,
        receiverName: String,
        completion: @escaping (Result<[Message], Error>) -> Void
    ) {
        let urlString = "\(baseURL)/chatHistory?authorName=\(authorName)&receiverName=\(receiverName)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else { return }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON from backend:\n\(jsonString)")
            }
            
            do {
                let messages = try JSONDecoder().decode([Message].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(messages))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Send Message
    func sendMessage(
        _ message: Message,
        completion: @escaping (Result<Message, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/send") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let bodyData = try JSONEncoder().encode(message)
            request.httpBody = bodyData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let sentMessage = try JSONDecoder().decode(Message.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(sentMessage))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
