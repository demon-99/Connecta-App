package com.nikhil.Connecta.controller;

import com.nikhil.Connecta.dto.MessageDto;
import com.nikhil.Connecta.entity.Message;
import com.nikhil.Connecta.service.ChatService;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@AllArgsConstructor
public class ChatController {
    private final ChatService chatService;
    private static final Logger logger = LoggerFactory.getLogger(ChatController.class);

    @PostMapping("/send")
    public void send(@RequestBody MessageDto messageDto)
    {
        logger.info(messageDto.toString());
        chatService.send(messageDto);
    }

    @GetMapping("/chatHistory")
    public List<Message> getChatHistory(@RequestParam String authorName,@RequestParam String receiverName) {
        authorName = authorName.trim();
        receiverName = receiverName.trim();
        logger.info(authorName+" "+receiverName);
        return chatService.getChatHistory(authorName,receiverName);
    }


    @GetMapping("/**")
    public String debugAll() {
        System.out.println("ANY GET called!");
        return "debug";
    }


}
