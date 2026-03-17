package com.assistbridge.repository;

import com.assistbridge.model.OtpVerification;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface OtpVerificationRepository extends MongoRepository<OtpVerification, String> {
    Optional<OtpVerification> findByPhoneAndVerifiedFalse(String phone);
    void deleteByPhone(String phone);
}
