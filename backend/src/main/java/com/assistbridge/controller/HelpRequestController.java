package com.assistbridge.controller;

import com.assistbridge.dto.*;
import com.assistbridge.model.HelpRequest;
import com.assistbridge.model.User;
import com.assistbridge.service.HelpRequestService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/requests")
@RequiredArgsConstructor
public class HelpRequestController {
    
    private final HelpRequestService requestService;
    
    @PostMapping
    public ResponseEntity<ApiResponse<HelpRequest>> createRequest(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody HelpRequestDto dto) {
        HelpRequest request = requestService.createRequest(user.getId(), dto);
        return ResponseEntity.ok(ApiResponse.success("Request created", request));
    }
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<HelpRequest>>> getMyRequests(
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.success(
                requestService.getUserRequests(user.getId())));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<HelpRequest>> getRequest(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(requestService.getRequestById(id)));
    }
    
    @PutMapping("/{id}/cancel")
    public ResponseEntity<ApiResponse<HelpRequest>> cancelRequest(
            @PathVariable String id,
            @AuthenticationPrincipal User user) {
        HelpRequest request = requestService.cancelRequest(id, user.getId());
        return ResponseEntity.ok(ApiResponse.success("Request cancelled", request));
    }
    
    @PostMapping("/{id}/rate")
    public ResponseEntity<ApiResponse<HelpRequest>> rateRequest(
            @PathVariable String id,
            @AuthenticationPrincipal User user,
            @Valid @RequestBody RatingDto dto) {
        HelpRequest request = requestService.rateRequest(id, user.getId(), dto);
        return ResponseEntity.ok(ApiResponse.success("Rating submitted", request));
    }
}
