package com.example.backend.auth;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService authService;
    private final OtpService otpService;

    public AuthController(AuthService authService, OtpService otpService) {
        this.authService = authService;
        this.otpService = otpService;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthDtos.UserResponse register(@Valid @RequestBody AuthDtos.RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public AuthDtos.UserResponse login(@Valid @RequestBody AuthDtos.LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/send-otp")
    public Map<String, String> sendOtp(@Valid @RequestBody AuthDtos.SendOtpRequest request) {
        otpService.sendOtp(request.email(), request.purpose());
        return Map.of("message", "Đã gửi mã xác thực OTP tới " + request.email());
    }

    @PostMapping("/verify-otp")
    public AuthDtos.GoogleAuthResponse verifyOtpAndLogin(@Valid @RequestBody AuthDtos.VerifyOtpRequest request) {
        otpService.verifyOtp(request.email(), request.code());
        return authService.loginWithGoogle(new AuthDtos.GoogleAuthRequest(request.email(), request.displayName()));
    }

    @PostMapping("/google")
    public AuthDtos.GoogleAuthResponse loginWithGoogle(@Valid @RequestBody AuthDtos.GoogleAuthRequest request) {
        return authService.loginWithGoogle(request);
    }

    @GetMapping("/me")
    public AuthDtos.UserResponse me(Authentication authentication) { return authService.currentUser(authentication.getName()); }
}
