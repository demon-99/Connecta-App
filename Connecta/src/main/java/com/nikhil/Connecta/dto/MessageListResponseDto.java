package com.nikhil.Connecta.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
@Getter
@Setter
public class MessageListResponseDto {
    private String receiverName;
    private String lastMessage;
    private MessageDto.MessageStatus messageStatus;
    private Instant lastMessageTimestamp;
}
