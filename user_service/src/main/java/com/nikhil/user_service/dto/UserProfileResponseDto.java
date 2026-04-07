package com.nikhil.user_service.dto;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;
@Data
public class UserProfileResponseDto {
    @Id
    private String userId;  // MongoDB generates ObjectId automatically

    @Field("username")
    @Indexed(unique = true)
    private String username;

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

}
