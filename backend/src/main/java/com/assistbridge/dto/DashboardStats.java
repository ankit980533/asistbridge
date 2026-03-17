package com.assistbridge.dto;

import lombok.Data;
import lombok.Builder;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class DashboardStats {
    private long totalRequests;
    private long pendingRequests;
    private long assignedRequests;
    private long completedRequests;
    private long cancelledRequests;
    private long totalUsers;
    private long totalVolunteers;
    private long activeVolunteers;
}
