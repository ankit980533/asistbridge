package com.assistbridge.controller;

import com.assistbridge.dto.ApiResponse;
import com.assistbridge.dto.AuthRequest;
import com.assistbridge.dto.AuthResponse;
import com.assistbridge.dto.OtpVerifyRequest;
import com.assistbridge.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthService authService;
    
    @Value("${admin.username:admin}")
    private String adminUsername;
    
    @Value("${admin.password:AssistBridge@2024}")
    private String adminPassword;
    
    @PostMapping("/send-otp")
    public ResponseEntity<ApiResponse<String>> sendOtp(@Valid @RequestBody AuthRequest request) {
        String result = authService.sendOtp(request.getPhone());
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    @PostMapping("/verify-otp")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyOtp(
            @Valid @RequestBody OtpVerifyRequest request) {
        AuthResponse response = authService.verifyOtp(request);
        return ResponseEntity.ok(ApiResponse.success("Login successful", response));
    }
    
    @PostMapping("/admin-login")
    public ResponseEntity<ApiResponse<AuthResponse>> adminLogin(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String password = request.get("password");
        
        if (adminUsername.equals(username) && adminPassword.equals(password)) {
            AuthResponse response = authService.createAdminToken();
            return ResponseEntity.ok(ApiResponse.success("Login successful", response));
        }
        
        return ResponseEntity.status(401).body(ApiResponse.error("Invalid credentials"));
    }

    @PostMapping("/lookup")
    public ResponseEntity<ApiResponse<Map<String, String>>> lookupPhone(@RequestBody Map<String, String> request) {
        String phone = request.get("phone");
        if (phone == null || phone.isEmpty()) {
            return ResponseEntity.ok(ApiResponse.success(Map.of()));
        }
        Map<String, String> result = authService.lookupByPhone(phone);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

}
