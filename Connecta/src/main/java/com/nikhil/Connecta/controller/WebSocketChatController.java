package com.nikhil.Connecta.controller;

import com.nikhil.Connecta.dto.MessageDto;
import com.nikhil.Connecta.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class WebSocketChatController {
    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;
    private static final Logger logger = LoggerFactory.getLogger(WebSocketChatController.class);

    @MessageMapping("/private-message")
    public void sendPrivateMessage(@Payload MessageDto messageDto){
        logger.info("Private Message received: {}",messageDto);
        chatService.send(messageDto);
        messagingTemplate.convertAndSendToUser(messageDto.getReceiverName(),
                "queue/messages",
                messageDto);
    }
}
