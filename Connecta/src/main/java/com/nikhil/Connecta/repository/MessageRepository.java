package com.nikhil.Connecta.repository;

import com.nikhil.Connecta.entity.Message;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import java.util.List;

public interface MessageRepository extends MongoRepository<Message, String>,CustomChatRepository {

        @Query("""
        {       
          $or: [
            { authorName: ?0, receiverName: ?1 },
            { authorName: ?1, receiverName: ?0 }
          ]
        }
        """)
        List<Message> findChat(String userA, String userB);



}

