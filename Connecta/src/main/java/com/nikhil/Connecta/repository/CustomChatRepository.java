package com.nikhil.Connecta.repository;

import com.nikhil.Connecta.dto.MessageListResponseDto;

import java.util.List;

public interface CustomChatRepository {
    List<MessageListResponseDto> findChatListByUserName(String userName);
}
