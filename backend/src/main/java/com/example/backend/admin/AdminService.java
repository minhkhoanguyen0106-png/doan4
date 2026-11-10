package com.example.backend.admin;

import com.example.backend.auth.AuthDtos;
import com.example.backend.user.User;
import com.example.backend.user.UserRepository;
import com.example.backend.user.UserRole;
import com.example.backend.user.UserStatus;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class AdminService {
    private final UserRepository users;
    public AdminService(UserRepository users) { this.users = users; }

    @Transactional(readOnly = true)
    public List<AuthDtos.UserResponse> users() {
        return users.findAllByOrderByCreatedAtDesc().stream().map(AuthDtos.UserResponse::from).toList();
    }

    @Transactional
    public AuthDtos.UserResponse setStatus(String actorEmail, Long id, UserStatus status) {
        User target = users.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        if (target.getEmail().equals(actorEmail) && status == UserStatus.DISABLED)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You cannot disable your own account");
        if (target.getRole() == UserRole.ADMIN && target.getStatus() == UserStatus.ACTIVE
                && status == UserStatus.DISABLED
                && users.countByRoleAndStatus(UserRole.ADMIN, UserStatus.ACTIVE) <= 1)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "At least one active administrator is required");
        target.setStatus(status);
        return AuthDtos.UserResponse.from(users.save(target));
    }

    @Transactional
    public AuthDtos.UserResponse setRole(String actorEmail, Long id, UserRole role) {
        User target = users.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        if (target.getEmail().equals(actorEmail) && role != target.getRole())
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You cannot change your own role");
        if (target.getRole() == UserRole.ADMIN && target.getStatus() == UserStatus.ACTIVE
                && role != UserRole.ADMIN
                && users.countByRoleAndStatus(UserRole.ADMIN, UserStatus.ACTIVE) <= 1)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "At least one active administrator is required");
        target.setRole(role);
        return AuthDtos.UserResponse.from(users.save(target));
    }
}
