package com.assistbridge.controller;

import com.assistbridge.dto.ApiResponse;
import com.assistbridge.dto.UpdateProfileDto;
import com.assistbridge.model.User;
import com.assistbridge.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<User>> getCurrentUser(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.success(user));
    }
    
    @PutMapping("/me")
    public ResponseEntity<ApiResponse<User>> updateProfile(
            @AuthenticationPrincipal User user,
            @RequestBody UpdateProfileDto dto) {
        User updated = userService.updateProfile(user.getId(), dto);
        return ResponseEntity.ok(ApiResponse.success("Profile updated", updated));
    }
    
    @PutMapping("/me/location")
    public ResponseEntity<ApiResponse<User>> updateLocation(
            @AuthenticationPrincipal User user,
            @RequestParam Double latitude,
            @RequestParam Double longitude) {
        User updated = userService.updateLocation(user.getId(), latitude, longitude);
        return ResponseEntity.ok(ApiResponse.success(updated));
    }
}
