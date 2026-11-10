package com.example.backend.auth;

import com.example.backend.user.User;
import com.example.backend.user.UserRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.Locale;
import java.util.UUID;

@Service
public class AuthService {
    private final UserRepository users;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;

    public AuthService(UserRepository users, PasswordEncoder passwordEncoder,
                      AuthenticationManager authenticationManager) {
        this.users = users;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
    }

    @Transactional
    public AuthDtos.UserResponse register(AuthDtos.RegisterRequest request) {
        String email = normalizeEmail(request.email());
        if (users.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email is already registered");
        }
        try {
            User saved = users.saveAndFlush(new User(email, passwordEncoder.encode(request.password()),
                    request.displayName().trim()));
            return AuthDtos.UserResponse.from(saved);
        } catch (DataIntegrityViolationException exception) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email is already registered");
        }
    }

    public AuthDtos.UserResponse login(AuthDtos.LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken.unauthenticated(normalizeEmail(request.email()), request.password()));
        User user = users.findByEmail(authentication.getName())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password"));
        return AuthDtos.UserResponse.from(user);
    }

    @Transactional
    public AuthDtos.GoogleAuthResponse loginWithGoogle(AuthDtos.GoogleAuthRequest request) {
        String email = normalizeEmail(request.email());
        if (!email.contains("@")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email không hợp lệ");
        }
        String sessionToken = UUID.randomUUID().toString().replace("-", "");
        String encoded = passwordEncoder.encode(sessionToken);

        User user = users.findByEmail(email).orElse(null);
        if (user == null) {
            String name = request.displayName();
            if (name == null || name.isBlank()) {
                name = email.split("@")[0];
            }
            user = new User(email, encoded, name.trim());
        } else {
            if (user.getStatus() != com.example.backend.user.UserStatus.ACTIVE) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Tài khoản đang bị vô hiệu hóa");
            }
            user.setPasswordHash(encoded);
            if (request.displayName() != null && !request.displayName().isBlank()) {
                user.setDisplayName(request.displayName().trim());
            }
        }
        User saved = users.saveAndFlush(user);
        return new AuthDtos.GoogleAuthResponse(AuthDtos.UserResponse.from(saved), sessionToken);
    }

    @Transactional(readOnly = true)
    public AuthDtos.UserResponse currentUser(String email) {
        User user = users.findByEmail(email).filter(value -> value.getStatus() == com.example.backend.user.UserStatus.ACTIVE)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Account is disabled"));
        return AuthDtos.UserResponse.from(user);
    }

    public static String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
