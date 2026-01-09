package com.nikhil.user_service.controller;

import com.nikhil.user_service.dto.LoginRequestDto;
import com.nikhil.user_service.dto.UserRequestDto;
import com.nikhil.user_service.entity.User;
import com.nikhil.user_service.service.UserService;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@AllArgsConstructor
@RestController
@RequestMapping("/api/user")
public class UserController {
    private final UserService userService;
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);
    @PostMapping("/create")
    public ResponseEntity<Map<String, String>> createUser(@RequestBody  UserRequestDto userRequestDto){
        try {
            // Call the service layer to create the user
            userService.createUser(userRequestDto);

            // If user created successfully, return a 201 Created response
            Map<String, String> response = new HashMap<>();
            response.put("message", "User created successfully");
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (DuplicateKeyException e) {
            // If a duplicate username or email is found, return a 409 Conflict response
            Map<String, String> response = new HashMap<>();
            response.put("message", e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.CONFLICT);
        } catch (Exception e) {
            // Catch all other unexpected errors and return a 500 Internal Server Error
            Map<String, String> response = new HashMap<>();
            response.put("message", "Internal Server Error");
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }

    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> loginUser(@RequestBody LoginRequestDto loginRequestDto) {
        try {
            // Call the service to authenticate the user
            User loggedInUser = userService.loginUser(loginRequestDto);

            // You may want to return a JWT or some kind of session token here for maintaining the user session
            Map<String, String> response = new HashMap<>();
            response.put("message", "Login successful");
            response.put("userId", loggedInUser.getUserId());
            response.put("username", loggedInUser.getUsername());

            return new ResponseEntity<>(response, HttpStatus.OK);

        } catch (Exception e) {
            // Return an error if login fails
            Map<String, String> response = new HashMap<>();
            response.put("message", e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.UNAUTHORIZED);
        }
    }

    @GetMapping("/profile")
    public ResponseEntity<Map<String, Object>> getUserProfile(@RequestParam String userId) {
        logger.info("User ID: {}", userId);
        try {
            // Fetch the user profile from the service using the provided userId
            User userProfile = userService.getUserProfile(userId);

            // Prepare the response payload
            Map<String, Object> response = new HashMap<>();
            response.put("userId", userProfile.getUserId());
            response.put("username", userProfile.getUsername());
            response.put("firstName", userProfile.getFirstName());
            response.put("lastName", userProfile.getLastName());
            response.put("email", userProfile.getEmail());
            response.put("profilePicture", userProfile.getProfilePicture());
            response.put("bio", userProfile.getBio());
            response.put("isVerified", userProfile.isVerified());
            response.put("phoneNumber", userProfile.getPhoneNumber());
            response.put("language", userProfile.getLanguage());
            response.put("theme", userProfile.getTheme());
            response.put("createdAt", userProfile.getCreatedAt());
            response.put("updatedAt", userProfile.getUpdatedAt());
            logger.info(response.toString());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (Exception e) {
            // Handle user not found case
            return new ResponseEntity<>(Map.of("message", "User not found"), HttpStatus.NOT_FOUND);
        }
    }

}
