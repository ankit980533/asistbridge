package com.assistbridge.service;

import com.assistbridge.dto.UpdateProfileDto;
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
public class UserService {
    
    private final UserRepository userRepository;
    private final HelpRequestRepository requestRepository;
    private final NotificationService notificationService;
    
    public User getUserById(String userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
    
    public User updateProfile(String userId, UpdateProfileDto dto) {
        User user = getUserById(userId);
        
        if (dto.getName() != null) user.setName(dto.getName());
        if (dto.getEmail() != null) user.setEmail(dto.getEmail());
        if (dto.getFcmToken() != null) user.setFcmToken(dto.getFcmToken());
        if (dto.getLatitude() != null) user.setLatitude(dto.getLatitude());
        if (dto.getLongitude() != null) user.setLongitude(dto.getLongitude());
        user.setUpdatedAt(LocalDateTime.now());
        
        return userRepository.save(user);
    }
    
    public User updateLocation(String userId, Double latitude, Double longitude) {
        User user = getUserById(userId);
        user.setLatitude(latitude);
        user.setLongitude(longitude);
        user.setUpdatedAt(LocalDateTime.now());
        return userRepository.save(user);
    }
    
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
    
    public List<User> getVolunteers() {
        return userRepository.findByRole(User.Role.VOLUNTEER);
    }
    
    public List<User> getActiveVolunteers() {
        return userRepository.findByRoleAndActive(User.Role.VOLUNTEER, true);
    }

    public User switchRole(String userId) {
        User user = getUserById(userId);

        if (user.getRole() == User.Role.ADMIN) {
            throw new RuntimeException("Admin cannot switch roles");
        }

        if (user.getRole() == User.Role.VOLUNTEER) {
            // Volunteer → User: unassign all active requests back to PENDING
            List<HelpRequest> assignedRequests = requestRepository
                    .findByAssignedVolunteerIdAndStatusIn(userId,
                            Arrays.asList(HelpRequest.Status.ASSIGNED, HelpRequest.Status.IN_PROGRESS));

            for (HelpRequest req : assignedRequests) {
                req.setAssignedVolunteerId(null);
                req.setAssignedVolunteerName(null);
                req.setAssignedAt(null);
                req.setStatus(HelpRequest.Status.PENDING);
                req.setUpdatedAt(LocalDateTime.now());
                requestRepository.save(req);

                // Notify the user that their request needs reassignment
                notificationService.sendNotification(req.getUserId(),
                        "Volunteer Unavailable",
                        "Your volunteer is no longer available. We are finding a new one.",
                        Notification.NotificationType.REQUEST_UPDATED, req.getId());
            }
        } else {
            // User → Volunteer: cancel all pending requests they created
            List<HelpRequest> pendingRequests = requestRepository
                    .findByUserIdAndStatusIn(userId,
                            Arrays.asList(HelpRequest.Status.PENDING, HelpRequest.Status.ADMIN_REVIEW));

            for (HelpRequest req : pendingRequests) {
                req.setStatus(HelpRequest.Status.CANCELLED);
                req.setUpdatedAt(LocalDateTime.now());
                requestRepository.save(req);
            }
        }

        User.Role newRole = user.getRole() == User.Role.VOLUNTEER
                ? User.Role.VISUALLY_IMPAIRED
                : User.Role.VOLUNTEER;

        user.setRole(newRole);
        user.setUpdatedAt(LocalDateTime.now());
        return userRepository.save(user);
    }
}
