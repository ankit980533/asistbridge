package com.assistbridge.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class OtpVerifyRequest {
    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^\\+?[1-9]\\d{9,14}$", message = "Invalid phone number")
    private String phone;
    
    private String otp; // Optional when using Firebase
    
    private String firebaseToken; // Firebase ID token
    
    private String name;
    
    private String role; // VOLUNTEER or VISUALLY_IMPAIRED
    
    private String fcmToken;
}
