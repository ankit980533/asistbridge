package com.assistbridge.controller;

import com.assistbridge.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class HealthController {
    
    private final UserRepository userRepository;
    
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        boolean dbConnected = false;
        try {
            // Simple query to warm up MongoDB connection
            userRepository.count();
            dbConnected = true;
        } catch (Exception e) {
            // DB not connected
        }
        
        return ResponseEntity.ok(Map.of(
            "status", "UP",
            "service", "AssistBridge Backend",
            "database", dbConnected ? "connected" : "disconnected"
        ));
    }
    
    @GetMapping("/")
    public ResponseEntity<Map<String, String>> root() {
        return ResponseEntity.ok(Map.of(
            "message", "AssistBridge API",
            "version", "1.0.0",
            "docs", "/api"
        ));
    }
}
