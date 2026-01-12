package com.nikhil.Connecta.repository;

import com.nikhil.Connecta.dto.MessageListResponseDto;
import com.nikhil.Connecta.service.ChatService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationResults;
import org.springframework.data.mongodb.core.aggregation.ConditionalOperators;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.stereotype.Repository;


import java.util.List;


@Repository
public class CustomChatRepositoryImpl implements CustomChatRepository {

    @Autowired
    private MongoTemplate mongoTemplate;

    private static final Logger logger = LoggerFactory.getLogger(CustomChatRepositoryImpl.class);

    @Override
    public List<MessageListResponseDto> findChatListByUserName(String userName) {
        // Remove any surrounding quotes from userName
        userName = userName.replaceAll("^\"|\"$", "");
        logger.info("Executing aggregation for user: {}", userName);

        Aggregation aggregation = Aggregation.newAggregation(
                // Match messages where the user is either the author or receiver
                Aggregation.match(new Criteria().orOperator(
                        Criteria.where("authorName").is(userName),
                        Criteria.where("receiverName").is(userName)
                )),

                // Sort by timestamp descending to get latest messages first
                Aggregation.sort(org.springframework.data.domain.Sort.Direction.DESC, "timestamp"),

                // Add a computed field for the "other person" (the chat partner)
                Aggregation.project()
                        .and(ConditionalOperators.when(Criteria.where("authorName").is(userName))
                                .then("$receiverName")
                                .otherwise("$authorName"))
                        .as("chatPartner")
                        .andInclude("message", "status", "timestamp"),

                // Group by chat partner to get the latest message for each conversation
                Aggregation.group("chatPartner")
                        .first("message").as("lastMessage")
                        .first("status").as("messageStatus")
                        .first("timestamp").as("lastMessageTimestamp"),

                // Project to match MessageListResponseDto field names exactly
                Aggregation.project()
                        .and("_id").as("receiverName")  // _id contains chatPartner after grouping
                        .andInclude("lastMessage", "messageStatus", "lastMessageTimestamp"),

                // Sort by last message timestamp descending (most recent first)
                Aggregation.sort(org.springframework.data.domain.Sort.Direction.DESC, "lastMessageTimestamp")
        );

        // Execute the aggregation query
        AggregationResults<MessageListResponseDto> result =
                mongoTemplate.aggregate(aggregation, "messages", MessageListResponseDto.class);

        List<MessageListResponseDto> results = result.getMappedResults();
        logger.info("Found {} chat conversations for user: {}", results.size(), userName);

        // Debug: Print results
        if (!results.isEmpty()) {
            for (MessageListResponseDto dto : results) {
                logger.info("Chat with: {}, Last message: {}, Status: {}, Time: {}",
                        dto.getReceiverName(), dto.getLastMessage(),
                        dto.getMessageStatus(), dto.getLastMessageTimestamp());
            }
        }

        return results;
    }
}