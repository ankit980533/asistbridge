package com.assistbridge.controller;

import com.assistbridge.dto.ApiResponse;
import com.assistbridge.dto.CompleteRequestDto;
import com.assistbridge.model.HelpRequest;
import com.assistbridge.model.User;
import com.assistbridge.service.HelpRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/volunteer")
@RequiredArgsConstructor
@PreAuthorize("hasRole('VOLUNTEER')")
public class VolunteerController {
    
    private final HelpRequestService requestService;
    
    @GetMapping("/requests")
    public ResponseEntity<ApiResponse<List<HelpRequest>>> getAssignedRequests(
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.success(
                requestService.getVolunteerRequests(user.getId())));
    }
    
    @GetMapping("/requests/active")
    public ResponseEntity<ApiResponse<List<HelpRequest>>> getActiveRequests(
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.success(
                requestService.getActiveVolunteerRequests(user.getId())));
    }
    
    @PutMapping("/requests/{id}/accept")
    public ResponseEntity<ApiResponse<HelpRequest>> acceptRequest(
            @PathVariable String id,
            @AuthenticationPrincipal User user) {
        HelpRequest request = requestService.acceptRequest(id, user.getId());
        return ResponseEntity.ok(ApiResponse.success("Request accepted", request));
    }
    
    @PutMapping("/requests/{id}/complete")
    public ResponseEntity<ApiResponse<HelpRequest>> completeRequest(
            @PathVariable String id,
            @AuthenticationPrincipal User user,
            @RequestBody(required = false) CompleteRequestDto dto) {
        String notes = dto != null ? dto.getNotes() : null;
        HelpRequest request = requestService.completeRequest(id, user.getId(), notes);
        return ResponseEntity.ok(ApiResponse.success("Request completed", request));
    }
}
