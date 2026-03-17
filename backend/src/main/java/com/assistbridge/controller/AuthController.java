package com.assistbridge.controller;

import com.assistbridge.dto.ApiResponse;
import com.assistbridge.dto.AuthRequest;
import com.assistbridge.dto.AuthResponse;
import com.assistbridge.dto.OtpVerifyRequest;
import com.assistbridge.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthService authService;
    
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
}
