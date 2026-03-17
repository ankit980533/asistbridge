package com.assistbridge.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AssignVolunteerRequest {
    @NotBlank(message = "Request ID is required")
    private String requestId;
    
    @NotBlank(message = "Volunteer ID is required")
    private String volunteerId;
}
