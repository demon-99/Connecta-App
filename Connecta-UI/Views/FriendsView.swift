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
            .refreshable {
                loadFriends()
            }
        }
    }
    
    private func loadFriends() {
        isLoading = true
        errorMessage = ""
        
        AuthService.shared.fetchUsers { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let userProfiles):
                    // Convert UserProfileResponseDto to User objects
                    self.friends = userProfiles.map { profile in
                        User(
                            userId: profile.userId,
                            username: profile.username,
                            firstName: profile.firstName,
                            lastName: profile.lastName,
                            email: "", // Not provided in UserProfileResponseDto
                            // Check if profilePicture is non-empty, else set it as nil
                            profilePicture: profile.profilePicture?.isEmpty ?? true ? nil : profile.profilePicture,
                            // Check if bio is non-empty, else set it as nil
                            bio: (profile.bio?.isEmpty ?? true) ? nil : profile.bio,
                            isVerified: profile.isVerified,
                            phoneNumber: profile.phoneNumber,
                            language: nil, // Not provided in UserProfileResponseDto
                            theme: nil, // Not provided in UserProfileResponseDto
                            createdAt: ISO8601DateFormatter().string(from: Date()),
                            updatedAt: ISO8601DateFormatter().string(from: Date())
                        )
                    }
                    
                    // Optionally filter out the current user
                    if let currentUserId = authVM.currentUser?.userId {
                        self.friends = self.friends.filter { $0.userId != currentUserId }
                    }
                    
                case .failure(let error):
                    self.errorMessage = "Failed to load friends: \(error.localizedDescription)"
                    print("Error fetching users: \(error)")
                }
            }
        }
    }

}

