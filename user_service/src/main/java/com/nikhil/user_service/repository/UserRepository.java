package com.nikhil.user_service.repository;

import com.nikhil.user_service.entity.User;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;


public interface UserRepository extends MongoRepository<User,String> {
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    User findByUsernameOrEmail(String username,String email);
}
