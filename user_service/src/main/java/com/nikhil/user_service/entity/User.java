package com.nikhil.user_service.entity;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;
import java.util.List;
@Getter
@Setter
@RequiredArgsConstructor
@Document(collection = "users")
public class User {

    @Id
    private String userId;  // MongoDB generates ObjectId automatically

    @Field("username")
    @Indexed(unique = true)
    private String username;

    @Field("email")
    @Indexed(unique = true)
    private String email;

    @Field("passwordHash")
    private String passwordHash;

    @Field("firstName")
    private String firstName;

    @Field("lastName")
    private String lastName;

    @Field("profilePicture")
    private String profilePicture;

    @Field("bio")
    private String bio;

    @Field("isVerified")
    private boolean isVerified;

    @Field("phoneNumber")
    private String phoneNumber;

    @Field("lastLogin")
    private Date lastLogin;

    @Field("isActive")
    private boolean isActive;

    @Field("isOnline")
    private boolean isOnline;

    @Field("isPrivate")
    private boolean isPrivate;

    @Field("blockedUsers")
    private List<String> blockedUsers;

    @Field("mutedUsers")
    private List<String> mutedUsers;

    @Field("friends")
    private List<String> friends;

    @Field("theme")
    private String theme = "light";

    @Field("language")
    private String language = "en";

    @Field("notificationSettings")
    private NotificationSettings notificationSettings;

    @Field("createdAt")
    private Date createdAt = new Date();

    @Field("updatedAt")
    private Date updatedAt = new Date();


    public static class NotificationSettings {
        private boolean chatNotifications = true;
        private boolean groupNotifications = true;
        private boolean sound = true;

        // Getters and Setters...
    }

    @Override
    public String toString() {
        return "User{" +
                "bio='" + bio + '\'' +
                ", blockedUsers=" + blockedUsers +
                ", createdAt=" + createdAt +
                ", email='" + email + '\'' +
                ", firstName='" + firstName + '\'' +
                ", friends=" + friends +
                ", isActive=" + isActive +
                ", isOnline=" + isOnline +
                ", isPrivate=" + isPrivate +
                ", language='" + language + '\'' +
                ", isVerified=" + isVerified +
                ", lastLogin=" + lastLogin +
                ", lastName='" + lastName + '\'' +
                ", mutedUsers=" + mutedUsers +
                ", notificationSettings=" + notificationSettings +
                ", passwordHash='" + passwordHash + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", profilePicture='" + profilePicture + '\'' +
                ", theme='" + theme + '\'' +
                ", updatedAt=" + updatedAt +
                ", userId='" + userId + '\'' +
                ", username='" + username + '\'' +
                '}';
    }
}
