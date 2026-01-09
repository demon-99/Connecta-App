package com.nikhil.Connecta.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Setter
@Getter
@AllArgsConstructor
public class MessageDto {
    String authorName;
    String message;
    String receiverName;
    Instant timestamp;
    MessageStatus status;
    public enum MessageStatus {
        SENT,DELIVERED,READ;
    }
    @Override
    public String toString() {
        return "Author Name: "+this.authorName+" Receiver Name: "+this.receiverName+" Message"+this.message+" Status: "+this.status;
    }
}
