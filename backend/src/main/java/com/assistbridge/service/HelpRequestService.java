package com.assistbridge.service;

import com.assistbridge.dto.HelpRequestDto;
import com.assistbridge.dto.RatingDto;
import com.assistbridge.model.HelpRequest;
import com.assistbridge.model.Notification;
import com.assistbridge.model.User;
import com.assistbridge.repository.HelpRequestRepository;
import com.assistbridge.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
public class HelpRequestService {
    
    private final HelpRequestRepository requestRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    
    public HelpRequest createRequest(String userId, HelpRequestDto dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        HelpRequest request = HelpRequest.builder()
                .userId(userId)
                .userName(user.getName())
                .userPhone(user.getPhone())
                .type(dto.getType())
                .description(dto.getDescription())
                .latitude(dto.getLatitude())
                .longitude(dto.getLongitude())
                .address(dto.getAddress())
                .status(HelpRequest.Status.PENDING)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        
        request = requestRepository.save(request);
        
        // Notify admins
        notifyAdmins("New Help Request", 
                "New " + dto.getType() + " request from " + user.getName(),
                Notification.NotificationType.REQUEST_CREATED, request.getId());
        
        return request;
    }

    public HelpRequest assignVolunteer(String requestId, String volunteerId) {
        HelpRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));
        
        User volunteer = userRepository.findById(volunteerId)
                .orElseThrow(() -> new RuntimeException("Volunteer not found"));
        
        if (volunteer.getRole() != User.Role.VOLUNTEER) {
            throw new RuntimeException("User is not a volunteer");
        }
        
        request.setAssignedVolunteerId(volunteerId);
        request.setAssignedVolunteerName(volunteer.getName());
        request.setStatus(HelpRequest.Status.ASSIGNED);
        request.setAssignedAt(LocalDateTime.now());
        request.setUpdatedAt(LocalDateTime.now());
        
        request = requestRepository.save(request);
        
        // Notify volunteer
        notificationService.sendNotification(volunteerId, "New Assignment",
                "You have been assigned a new help request",
                Notification.NotificationType.REQUEST_ASSIGNED, requestId);
        
        // Notify user
        notificationService.sendNotification(request.getUserId(), "Volunteer Assigned",
                "A volunteer has been assigned to help you",
                Notification.NotificationType.REQUEST_ASSIGNED, requestId);
        
        return request;
    }
    
    public HelpRequest acceptRequest(String requestId, String volunteerId) {
        HelpRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));
        
        if (!volunteerId.equals(request.getAssignedVolunteerId())) {
            throw new RuntimeException("You are not assigned to this request");
        }
        
        request.setStatus(HelpRequest.Status.IN_PROGRESS);
        request.setUpdatedAt(LocalDateTime.now());
        request = requestRepository.save(request);
        
        notificationService.sendNotification(request.getUserId(), "Help On The Way",
                "Volunteer has accepted and is on the way",
                Notification.NotificationType.VOLUNTEER_ACCEPTED, requestId);
        
        return request;
    }

    public HelpRequest completeRequest(String requestId, String volunteerId, String notes) {
        HelpRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));
        
        if (!volunteerId.equals(request.getAssignedVolunteerId())) {
            throw new RuntimeException("You are not assigned to this request");
        }
        
        request.setStatus(HelpRequest.Status.COMPLETED);
        request.setCompletedAt(LocalDateTime.now());
        request.setCompletionNotes(notes);
        request.setUpdatedAt(LocalDateTime.now());
        request = requestRepository.save(request);
        
        notificationService.sendNotification(request.getUserId(), "Request Completed",
                "Your help request has been completed",
                Notification.NotificationType.REQUEST_COMPLETED, requestId);
        
        return request;
    }
    
    public HelpRequest cancelRequest(String requestId, String userId) {
        HelpRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));
        
        if (!userId.equals(request.getUserId())) {
            throw new RuntimeException("You can only cancel your own requests");
        }
        
        request.setStatus(HelpRequest.Status.CANCELLED);
        request.setUpdatedAt(LocalDateTime.now());
        request = requestRepository.save(request);
        
        if (request.getAssignedVolunteerId() != null) {
            notificationService.sendNotification(request.getAssignedVolunteerId(),
                    "Request Cancelled", "The help request has been cancelled",
                    Notification.NotificationType.REQUEST_CANCELLED, requestId);
        }
        
        return request;
    }
    
    public HelpRequest rateRequest(String requestId, String userId, RatingDto dto) {
        HelpRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));
        
        if (!userId.equals(request.getUserId())) {
            throw new RuntimeException("You can only rate your own requests");
        }
        
        request.setRating(dto.getRating());
        request.setFeedback(dto.getFeedback());
        request.setUpdatedAt(LocalDateTime.now());
        
        return requestRepository.save(request);
    }

    public List<HelpRequest> getUserRequests(String userId) {
        return requestRepository.findByUserId(userId);
    }
    
    public List<HelpRequest> getVolunteerRequests(String volunteerId) {
        return requestRepository.findByAssignedVolunteerId(volunteerId);
    }
    
    public List<HelpRequest> getActiveVolunteerRequests(String volunteerId) {
        return requestRepository.findByAssignedVolunteerIdAndStatus(
                volunteerId, HelpRequest.Status.ASSIGNED);
    }
    
    public List<HelpRequest> getAllRequests() {
        return requestRepository.findAll();
    }
    
    public List<HelpRequest> getPendingRequests() {
        return requestRepository.findByStatusIn(
                Arrays.asList(HelpRequest.Status.PENDING, HelpRequest.Status.ADMIN_REVIEW));
    }
    
    public HelpRequest getRequestById(String requestId) {
        return requestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));
    }
    
    private void notifyAdmins(String title, String body, 
            Notification.NotificationType type, String referenceId) {
        List<User> admins = userRepository.findByRole(User.Role.ADMIN);
        for (User admin : admins) {
            notificationService.sendNotification(admin.getId(), title, body, type, referenceId);
        }
    }
}
