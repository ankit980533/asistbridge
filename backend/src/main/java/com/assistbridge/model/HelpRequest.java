package com.assistbridge.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Document(collection = "requests")
public class HelpRequest {
    @Id
    private String id;
    
    private String userId;
    
    private String userName;
    
    private String userPhone;
    
    private HelpType type;
    
    private String description;
    
    private Double latitude;
    
    private Double longitude;
    
    private String address;
    
    private Status status;
    
    private String assignedVolunteerId;
    
    private String assignedVolunteerName;
    
    private LocalDateTime assignedAt;
    
    private LocalDateTime completedAt;
    
    private String completionNotes;
    
    private Integer rating;
    
    private String feedback;
    
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
    
    public enum HelpType {
        ONLINE_HELP,
        WRITER_HELP,
        NAVIGATION_ASSISTANCE,
        DOCUMENT_READING
    }
    
    public enum Status {
        PENDING,
        ADMIN_REVIEW,
        ASSIGNED,
        IN_PROGRESS,
        COMPLETED,
        CANCELLED
    }
}
