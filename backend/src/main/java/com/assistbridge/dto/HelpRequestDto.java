package com.assistbridge.dto;

import com.assistbridge.model.HelpRequest;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class HelpRequestDto {
    @NotNull(message = "Help type is required")
    private HelpRequest.HelpType type;
    
    @NotBlank(message = "Description is required")
    private String description;
    
    private Double latitude;
    
    private Double longitude;
    
    private String address;
}
