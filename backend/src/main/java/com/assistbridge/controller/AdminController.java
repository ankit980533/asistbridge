package com.assistbridge.controller;

import com.assistbridge.dto.*;
import com.assistbridge.model.HelpRequest;
import com.assistbridge.model.User;
import com.assistbridge.service.AdminService;
import com.assistbridge.service.HelpRequestService;
import com.assistbridge.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {
    
    private final AdminService adminService;
    private final HelpRequestService requestService;
    private final UserService userService;
    
    @GetMapping("/dashboard")
    public ResponseEntity<ApiResponse<DashboardStats>> getDashboardStats() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getDashboardStats()));
    }
    
    @GetMapping("/requests")
    public ResponseEntity<ApiResponse<List<HelpRequest>>> getAllRequests() {
        return ResponseEntity.ok(ApiResponse.success(requestService.getAllRequests()));
    }
    
    @GetMapping("/requests/pending")
    public ResponseEntity<ApiResponse<List<HelpRequest>>> getPendingRequests() {
        return ResponseEntity.ok(ApiResponse.success(requestService.getPendingRequests()));
    }
    
    @PostMapping("/assign")
    public ResponseEntity<ApiResponse<HelpRequest>> assignVolunteer(
            @Valid @RequestBody AssignVolunteerRequest request) {
        HelpRequest updated = requestService.assignVolunteer(
                request.getRequestId(), request.getVolunteerId());
        return ResponseEntity.ok(ApiResponse.success("Volunteer assigned", updated));
    }
    
    @GetMapping("/users")
    public ResponseEntity<ApiResponse<List<User>>> getAllUsers() {
        return ResponseEntity.ok(ApiResponse.success(userService.getAllUsers()));
    }
    
    @GetMapping("/volunteers")
    public ResponseEntity<ApiResponse<List<User>>> getVolunteers() {
        return ResponseEntity.ok(ApiResponse.success(userService.getVolunteers()));
    }
    
    @GetMapping("/volunteers/active")
    public ResponseEntity<ApiResponse<List<User>>> getActiveVolunteers() {
        return ResponseEntity.ok(ApiResponse.success(userService.getActiveVolunteers()));
    }
}
