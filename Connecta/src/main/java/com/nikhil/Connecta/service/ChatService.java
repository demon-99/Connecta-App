package com.nikhil.Connecta.service;

import com.nikhil.Connecta.dto.MessageDto;
import com.nikhil.Connecta.dto.MessageListResponseDto;
import com.nikhil.Connecta.entity.Message;
import com.nikhil.Connecta.repository.MessageRepository;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.sound.midi.Receiver;
import java.util.List;


@Service
@AllArgsConstructor
public class ChatService {
    private final MessageRepository messageRepository;
    private static final Logger logger = LoggerFactory.getLogger(ChatService.class);

    public void send(MessageDto messageDto){
        Message message = new Message(messageDto);
        logger.info(message.toString());
        messageRepository.save(message);
    }
    public List<Message> getChatHistory(String authorName,String receiverName){
        logger.info(authorName+" "+receiverName);
        List <Message> messageList = messageRepository.findChat(authorName, receiverName);
        for(Message msg:messageList){
            logger.info(msg.toString());
        }
        return messageList;

    }
    public List<MessageListResponseDto> getChatList(String userName){
        logger.info("userName {}",userName);
        List <MessageListResponseDto> messageListResponseDtos = messageRepository.findChatListByUserName(userName);
        return messageListResponseDtos;
    }
}
