package com.example.backend.admin;

import com.example.backend.auth.AuthDtos;
import com.example.backend.user.UserStatus;
import com.example.backend.user.UserRole;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private final AdminService admin;
    public AdminController(AdminService admin) { this.admin = admin; }

    @GetMapping("/users")
    public List<AuthDtos.UserResponse> users() { return admin.users(); }

    @PatchMapping("/users/{id}/status")
    public AuthDtos.UserResponse setStatus(Authentication auth, @PathVariable Long id,
                                           @Valid @RequestBody StatusRequest request) {
        return admin.setStatus(auth.getName(), id, request.status());
    }

    @PatchMapping("/users/{id}/role")
    public AuthDtos.UserResponse setRole(Authentication auth, @PathVariable Long id,
                                         @Valid @RequestBody RoleRequest request) {
        return admin.setRole(auth.getName(), id, request.role());
    }

    public record StatusRequest(@NotNull UserStatus status) { }
    public record RoleRequest(@NotNull UserRole role) { }
}
