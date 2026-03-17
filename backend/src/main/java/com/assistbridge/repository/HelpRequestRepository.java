package com.assistbridge.repository;

import com.assistbridge.model.HelpRequest;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface HelpRequestRepository extends MongoRepository<HelpRequest, String> {
    List<HelpRequest> findByUserId(String userId);
    List<HelpRequest> findByAssignedVolunteerId(String volunteerId);
    List<HelpRequest> findByStatus(HelpRequest.Status status);
    List<HelpRequest> findByStatusIn(List<HelpRequest.Status> statuses);
    List<HelpRequest> findByUserIdAndStatus(String userId, HelpRequest.Status status);
    List<HelpRequest> findByAssignedVolunteerIdAndStatus(String volunteerId, HelpRequest.Status status);
    long countByStatus(HelpRequest.Status status);
    long countByAssignedVolunteerId(String volunteerId);
}
