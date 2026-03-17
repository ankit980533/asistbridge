package com.assistbridge.repository;

import com.assistbridge.model.User;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends MongoRepository<User, String> {
    Optional<User> findByPhone(String phone);
    List<User> findByRole(User.Role role);
    List<User> findByRoleAndActive(User.Role role, boolean active);
    boolean existsByPhone(String phone);
}
