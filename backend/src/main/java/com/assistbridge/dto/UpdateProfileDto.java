package com.assistbridge.dto;

import lombok.Data;

@Data
public class UpdateProfileDto {
    private String name;
    private String email;
    private String fcmToken;
    private Double latitude;
    private Double longitude;
}
