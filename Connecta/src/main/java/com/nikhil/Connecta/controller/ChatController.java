package com.nikhil.Connecta.controller;

import com.nikhil.Connecta.dto.MessageDto;
import com.nikhil.Connecta.dto.MessageListResponseDto;
import com.nikhil.Connecta.entity.Message;
import com.nikhil.Connecta.service.ChatService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@AllArgsConstructor
public class ChatController {
    private final ChatService chatService;

    @PostMapping("/send")
    public Message send(@RequestBody MessageDto messageDto)
    {
        return chatService.send(messageDto);
    }

    @GetMapping("/chatHistory")
    public List<Message> getChatHistory(@RequestParam String authorName,@RequestParam String receiverName) {
        authorName = authorName.trim();
        receiverName = receiverName.trim();
        return chatService.getChatHistory(authorName,receiverName);
    }

    @GetMapping("/chats")
    public List<MessageListResponseDto> getChatList(@RequestParam String userName){
            return chatService.getChatList(userName);
    }
}
