package com.nikhil.user_service.repository;

import com.nikhil.user_service.dto.UserProfileResponseDto;
import com.nikhil.user_service.entity.User;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;


public interface UserRepository extends MongoRepository<User,String> {
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    User findByUsernameOrEmail(String username,String email);

    @Query(value = "{}", fields = "{'userId': 1, 'username': 1, 'firstName': 1, 'lastName': 1, 'profilePicture': 1, 'bio': 1, 'isVerified': 1, 'phoneNumber': 1, 'lastLogin': 1, 'isActive': 1, 'isOnline': 1, 'isPrivate': 1}")
    List<UserProfileResponseDto> findUserProfileData();
}
