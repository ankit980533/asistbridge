package com.assistbridge.service;

import com.assistbridge.dto.AuthResponse;
import com.assistbridge.dto.OtpVerifyRequest;
import com.assistbridge.model.OtpVerification;
import com.assistbridge.model.User;
import com.assistbridge.repository.OtpVerificationRepository;
import com.assistbridge.repository.UserRepository;
import com.assistbridge.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.security.SecureRandom;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {
    
    private final UserRepository userRepository;
    private final OtpVerificationRepository otpRepository;
    private final JwtTokenProvider tokenProvider;
    private final NotificationService notificationService;
    
    public String sendOtp(String phone) {
        // Delete any existing OTP for this phone
        otpRepository.deleteByPhone(phone);
        
        // Generate 6-digit OTP
        String otp = generateOtp();
        
        // Save OTP
        OtpVerification verification = OtpVerification.builder()
                .phone(phone)
                .otp(otp)
                .verified(false)
                .attempts(0)
                .createdAt(LocalDateTime.now())
                .build();
        otpRepository.save(verification);
        
        // In production, send OTP via SMS/Firebase
        // For development, log the OTP
        log.info("OTP for {}: {}", phone, otp);
        
        return "OTP sent successfully";
    }

    public AuthResponse verifyOtp(OtpVerifyRequest request) {
        OtpVerification verification = otpRepository
                .findByPhoneAndVerifiedFalse(request.getPhone())
                .orElseThrow(() -> new RuntimeException("OTP not found or expired"));
        
        if (verification.getAttempts() >= 3) {
            throw new RuntimeException("Too many attempts. Please request a new OTP");
        }
        
        if (!verification.getOtp().equals(request.getOtp())) {
            verification.setAttempts(verification.getAttempts() + 1);
            otpRepository.save(verification);
            throw new RuntimeException("Invalid OTP");
        }
        
        verification.setVerified(true);
        otpRepository.save(verification);
        
        // Check if user exists
        User user = userRepository.findByPhone(request.getPhone()).orElse(null);
        boolean isNewUser = user == null;
        
        if (isNewUser) {
            User.Role role = User.Role.VISUALLY_IMPAIRED;
            if (request.getRole() != null) {
                role = User.Role.valueOf(request.getRole());
            }
            
            user = User.builder()
                    .phone(request.getPhone())
                    .name(request.getName() != null ? request.getName() : "User")
                    .role(role)
                    .fcmToken(request.getFcmToken())
                    .active(true)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build();
            user = userRepository.save(user);
        } else if (request.getFcmToken() != null) {
            user.setFcmToken(request.getFcmToken());
            user.setUpdatedAt(LocalDateTime.now());
            user = userRepository.save(user);
        }
        
        String token = tokenProvider.generateToken(user.getId(), user.getRole().name());
        
        return AuthResponse.builder()
                .token(token)
                .userId(user.getId())
                .name(user.getName())
                .phone(user.getPhone())
                .role(user.getRole())
                .newUser(isNewUser)
                .build();
    }
    
    private String generateOtp() {
        SecureRandom random = new SecureRandom();
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }
}
