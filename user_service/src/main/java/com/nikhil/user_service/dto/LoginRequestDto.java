package com.nikhil.user_service.dto;


import lombok.Data;

@Data
public class LoginRequestDto {
    private String usernameOrEmail;
    private String password;
}
