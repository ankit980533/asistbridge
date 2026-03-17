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
@Document(collection = "notifications")
public class Notification {
    @Id
    private String id;
    
    private String userId;
    
    private String title;
    
    private String body;
    
    private NotificationType type;
    
    private String referenceId;
    
    private boolean read;
    
    private LocalDateTime createdAt;
    
    public enum NotificationType {
        REQUEST_CREATED,
        REQUEST_ASSIGNED,
        VOLUNTEER_ACCEPTED,
        REQUEST_IN_PROGRESS,
        REQUEST_COMPLETED,
        REQUEST_CANCELLED
    }
}
