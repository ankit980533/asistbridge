package com.assistbridge.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.index.Indexed;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Document(collection = "otp_verifications")
public class OtpVerification {
    @Id
    private String id;
    
    @Indexed
    private String phone;
    
    private String otp;
    
    private boolean verified;
    
    private int attempts;
    
    @Indexed(expireAfterSeconds = 300) // Auto-delete after 5 minutes
    private LocalDateTime createdAt;
}
