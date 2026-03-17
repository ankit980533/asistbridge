package com.assistbridge.service;

import com.assistbridge.dto.AuthResponse;
import com.assistbridge.dto.OtpVerifyRequest;
import com.assistbridge.model.User;
import com.assistbridge.repository.UserRepository;
import com.assistbridge.security.JwtTokenProvider;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {
    
    private final UserRepository userRepository;
    private final JwtTokenProvider tokenProvider;
    
    public AuthResponse verifyOtp(OtpVerifyRequest request) {
        String phone = request.getPhone();
        
        // If Firebase token provided, verify it
        if (request.getFirebaseToken() != null && !request.getFirebaseToken().isEmpty()) {
            try {
                FirebaseToken decodedToken = FirebaseAuth.getInstance()
                        .verifyIdToken(request.getFirebaseToken());
                // Use phone from Firebase token if available
                if (decodedToken.getClaims().get("phone_number") != null) {
                    phone = (String) decodedToken.getClaims().get("phone_number");
                }
                log.info("Firebase token verified for: {}", phone);
            } catch (Exception e) {
                log.warn("Firebase verification failed, using phone from request: {}", e.getMessage());
                // Continue with phone from request (for dev/testing)
            }
        }
        
        // Check if user exists
        User user = userRepository.findByPhone(phone).orElse(null);
        boolean isNewUser = user == null;
        
        if (isNewUser) {
            User.Role role = User.Role.VISUALLY_IMPAIRED;
            if (request.getRole() != null && !request.getRole().isEmpty()) {
                role = User.Role.valueOf(request.getRole());
            }
            
            user = User.builder()
                    .phone(phone)
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
    
    // Keep for backward compatibility / testing
    public String sendOtp(String phone) {
        log.info("OTP requested for: {} (using Firebase Phone Auth)", phone);
        return "Use Firebase Phone Auth on mobile";
    }
    
    // Create admin token for web dashboard
    public AuthResponse createAdminToken() {
        String token = tokenProvider.generateToken("admin", "ADMIN");
        
        return AuthResponse.builder()
                .token(token)
                .userId("admin")
                .name("Admin")
                .phone("")
                .role(User.Role.ADMIN)
                .newUser(false)
                .build();
    }
}
