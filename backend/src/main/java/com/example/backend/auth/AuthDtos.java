package com.example.backend.auth;

import com.example.backend.user.User;
import com.example.backend.user.UserRole;
import com.example.backend.user.UserStatus;
import java.time.Instant;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public final class AuthDtos {
    private AuthDtos() { }

    public record RegisterRequest(
            @NotBlank @Email @Size(max = 254) String email,
            @NotBlank @Size(min = 8, max = 72) String password,
            @NotBlank @Size(max = 100) String displayName) { }

    public record LoginRequest(@NotBlank @Email String email, @NotBlank String password) { }

    public record GoogleAuthRequest(
            @NotBlank @Email @Size(max = 254) String email,
            @Size(max = 100) String displayName) { }

    public record GoogleAuthResponse(UserResponse user, String sessionToken) { }

    public record UserResponse(Long id, String email, String displayName, UserRole role, UserStatus status, Instant createdAt) {
        public static UserResponse from(User user) {
            return new UserResponse(user.getId(), user.getEmail(), user.getDisplayName(), user.getRole(), user.getStatus(), user.getCreatedAt());
        }
    }
}
