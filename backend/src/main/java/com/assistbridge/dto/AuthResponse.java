package com.assistbridge.dto;

import com.assistbridge.model.User;
import lombok.Data;
import lombok.Builder;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponse {
    private String token;
    private String userId;
    private String name;
    private String phone;
    private User.Role role;
    private boolean newUser;
}
