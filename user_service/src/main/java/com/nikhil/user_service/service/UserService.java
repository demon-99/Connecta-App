package com.nikhil.user_service.service;

import com.nikhil.user_service.dto.LoginRequestDto;
import com.nikhil.user_service.dto.UserRequestDto;
import com.nikhil.user_service.entity.User;
import com.nikhil.user_service.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Optional;

@Service
@AllArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    public void createUser(UserRequestDto userRequestDto){
        if(userRepository.existsByUsername(userRequestDto.getUsername())){
            logger.info("Username Taken");
            throw new DuplicateKeyException("Username already taken.");
        }
        if(userRepository.existsByEmail(userRequestDto.getEmail())){
            logger.info("Email already in use.");
            throw new DuplicateKeyException("Email already in use.");
        }
        User user = new User();
        logger.info(userRequestDto.toString());

        user.setFirstName(userRequestDto.getFirstName());
        user.setLastName(userRequestDto.getLastName());
        user.setUsername(userRequestDto.getUsername());
        user.setEmail(userRequestDto.getEmail());
        user.setPasswordHash(userRequestDto.getPassword());
        logger.info(user.toString());
        userRepository.save(user);
    }
    public User loginUser(LoginRequestDto loginRequestDto) throws Exception{
        User user = userRepository.findByUsernameOrEmail(loginRequestDto.getUsernameOrEmail(),loginRequestDto.getUsernameOrEmail());
        if(user==null){
            throw new Exception("User not found.");
        }
        if(!user.getPasswordHash().equals(loginRequestDto.getPassword())){
            throw new Exception("Incorrect Password");
        }
        logger.info(user.toString());
        user.setLastLogin(new Date());
        logger.info(user.toString());
        userRepository.save(user);
        return user;
    }

    public User getUserProfile(String userId) throws Exception{
        Optional<User> userOptional = userRepository.findById(userId);

        // Use orElseThrow to throw an exception if user is not present
        return userOptional.orElseThrow(() -> new Exception("User not found."));
    }
}
