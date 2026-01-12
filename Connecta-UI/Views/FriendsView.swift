//
//  FriendsView.swift
//  Connecta-UI
//
//  Friends list view
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var friends: [User] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var searchText = ""
    
    var filteredFriends: [User] {
        if searchText.isEmpty {
            return friends
        } else {
            return friends.filter { friend in
                friend.username.localizedCaseInsensitiveContains(searchText) ||
                friend.fullName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search friends", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                if isLoading {
                    ProgressView("Loading friends...")
                        .padding()
                } else if !errorMessage.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            loadFriends()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                } else if filteredFriends.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: searchText.isEmpty ? "person.2" : "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(searchText.isEmpty ? "No friends yet" : "No results found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        if searchText.isEmpty {
                            Text("Add friends to see them here")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                } else {
                    List(filteredFriends) { friend in
                        NavigationLink(destination: FriendDetailView(friend: friend)) {
                            FriendRowView(friend: friend)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Add friend action
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .onAppear {
                loadFriends()
            }
        }
    }
    
    private func loadFriends() {
        // TODO: Implement API call to fetch friends
        // For now, using mock data
        isLoading = true
        errorMessage = ""
        
        // Simulate API call
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            await MainActor.run {
                isLoading = false
                // Mock friends data
                friends = [
                    User(
                        userId: "1",
                        username: "alice",
                        firstName: "Alice",
                        lastName: "Johnson",
                        email: "alice@example.com",
                        profilePicture: nil,
                        bio: "Love coding and coffee ☕️",
                        isVerified: true,
                        phoneNumber: "+1234567890",
                        language: "English",
                        theme: "Light",
                        createdAt: ISO8601DateFormatter().string(from: Date()),
                        updatedAt: ISO8601DateFormatter().string(from: Date())
                    ),
                    User(
                        userId: "2",
                        username: "bob",
                        firstName: "Bob",
                        lastName: "Smith",
                        email: "bob@example.com",
                        profilePicture: nil,
                        bio: "Tech enthusiast",
                        isVerified: false,
                        phoneNumber: "+1234567891",
                        language: "English",
                        theme: "Dark",
                        createdAt: ISO8601DateFormatter().string(from: Date()),
                        updatedAt: ISO8601DateFormatter().string(from: Date())
                    )
                ]
            }
        }
    }
}

