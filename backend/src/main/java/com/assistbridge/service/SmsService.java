package com.assistbridge.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.util.Base64;

@Service
@Slf4j
public class SmsService {
    
    @Value("${twilio.account-sid:}")
    private String accountSid;
    
    @Value("${twilio.auth-token:}")
    private String authToken;
    
    @Value("${twilio.phone-number:}")
    private String fromNumber;
    
    private final RestTemplate restTemplate = new RestTemplate();
    
    public boolean sendOtp(String toPhone, String otp) {
        // If Twilio not configured, just log (dev mode)
        if (accountSid == null || accountSid.isEmpty()) {
            log.info("DEV MODE - OTP for {}: {}", toPhone, otp);
            return true;
        }
        
        try {
            String url = "https://api.twilio.com/2010-04-01/Accounts/" + accountSid + "/Messages.json";
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            String auth = Base64.getEncoder().encodeToString((accountSid + ":" + authToken).getBytes());
            headers.set("Authorization", "Basic " + auth);
            
            String body = "To=" + toPhone + 
                         "&From=" + fromNumber + 
                         "&Body=Your AssistBridge OTP is: " + otp + ". Valid for 5 minutes.";
            
            HttpEntity<String> request = new HttpEntity<>(body, headers);
            restTemplate.postForEntity(url, request, String.class);
            
            log.info("OTP sent to {}", toPhone);
            return true;
        } catch (Exception e) {
            log.error("Failed to send SMS: {}", e.getMessage());
            // Fallback to logging in dev
            log.info("FALLBACK - OTP for {}: {}", toPhone, otp);
            return true;
        }
    }
}
