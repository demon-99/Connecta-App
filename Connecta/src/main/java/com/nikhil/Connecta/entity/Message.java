package com.nikhil.Connecta.entity;

import com.nikhil.Connecta.dto.MessageDto;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
@Getter
@Setter
@Document(collection = "messages")
@AllArgsConstructor
@RequiredArgsConstructor
public class Message {
    @Id
    private String id;
    private String authorName;
    private String message;
    private String receiverName;
    private Instant timestamp;
    private MessageDto.MessageStatus status;
    public  Message(MessageDto messageDto){
        this.authorName = messageDto.getAuthorName();
        this.message = messageDto.getMessage();
        this.receiverName = messageDto.getReceiverName();
        this.timestamp = messageDto.getTimestamp();
        this.status = messageDto.getStatus();
    }

    @Override
    public String toString() {
        return "Id: "+this.id+" Author Name: "+this.authorName+" Receiver Name: "+this.receiverName+" Message"+this.message;
    }
}
