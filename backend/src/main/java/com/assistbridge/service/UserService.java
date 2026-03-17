package com.assistbridge.service;

import com.assistbridge.dto.UpdateProfileDto;
import com.assistbridge.model.User;
import com.assistbridge.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;
    
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
}
