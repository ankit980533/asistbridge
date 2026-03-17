package com.assistbridge.service;

import com.assistbridge.dto.DashboardStats;
import com.assistbridge.model.HelpRequest;
import com.assistbridge.model.User;
import com.assistbridge.repository.HelpRequestRepository;
import com.assistbridge.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdminService {
    
    private final HelpRequestRepository requestRepository;
    private final UserRepository userRepository;
    
    public DashboardStats getDashboardStats() {
        long totalUsers = userRepository.findByRole(User.Role.VISUALLY_IMPAIRED).size();
        long totalVolunteers = userRepository.findByRole(User.Role.VOLUNTEER).size();
        long activeVolunteers = userRepository.findByRoleAndActive(User.Role.VOLUNTEER, true).size();
        
        return DashboardStats.builder()
                .totalRequests(requestRepository.count())
                .pendingRequests(requestRepository.countByStatus(HelpRequest.Status.PENDING))
                .assignedRequests(requestRepository.countByStatus(HelpRequest.Status.ASSIGNED))
                .completedRequests(requestRepository.countByStatus(HelpRequest.Status.COMPLETED))
                .cancelledRequests(requestRepository.countByStatus(HelpRequest.Status.CANCELLED))
                .totalUsers(totalUsers)
                .totalVolunteers(totalVolunteers)
                .activeVolunteers(activeVolunteers)
                .build();
    }
}
