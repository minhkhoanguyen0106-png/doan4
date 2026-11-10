package com.example.backend.auth;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import jakarta.mail.internet.MimeMessage;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class OtpService {
    private static final Logger log = LoggerFactory.getLogger(OtpService.class);
    private static final int OTP_EXPIRY_SECONDS = 300; // 5 minutes
    private static final int MAX_ATTEMPTS = 5;

    private final JavaMailSender mailSender;
    private final String senderEmail;
    private final String senderPassword;
    private final SecureRandom random = new SecureRandom();

    private final Map<String, OtpEntry> otpStorage = new ConcurrentHashMap<>();

    public OtpService(JavaMailSender mailSender,
                      @Value("${spring.mail.username:}") String senderEmail,
                      @Value("${spring.mail.password:}") String senderPassword) {
        this.mailSender = mailSender;
        this.senderEmail = senderEmail != null ? senderEmail.trim() : "";
        this.senderPassword = senderPassword != null ? senderPassword.trim() : "";
    }

    public record OtpEntry(String code, Instant expiresAt, int attempts) {
        public OtpEntry withIncrementedAttempts() {
            return new OtpEntry(code, expiresAt, attempts + 1);
        }
    }

    public void sendOtp(String toEmail, String purpose) {
        String email = normalizeEmail(toEmail);
        if (!email.contains("@")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Địa chỉ email không hợp lệ");
        }

        // Generate 6-digit code
        String code = String.format("%06d", random.nextInt(1_000_000));
        Instant expiresAt = Instant.now().plusSeconds(OTP_EXPIRY_SECONDS);
        otpStorage.put(email, new OtpEntry(code, expiresAt, 0));

        log.info("--------------------------------------------------");
        log.info("[PONDORA OTP] Generated OTP for [{}]: {}", email, code);
        log.info("--------------------------------------------------");

        if (senderEmail.isEmpty() || senderPassword.isEmpty()) {
            log.warn("[PONDORA OTP] spring.mail.username or password is not configured. Email not sent via SMTP. OTP code is: {}", code);
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Chưa cấu hình tài khoản gửi thư trong backend/src/main/resources/application.properties. Vui lòng điền 'spring.mail.username' (địa chỉ Gmail) và 'spring.mail.password' (Mật khẩu ứng dụng 16 số của Google) để gửi email thật.");
        }

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(senderEmail, "PONDORA Aquaculture System");
            helper.setTo(email);
            helper.setSubject("[PONDORA] Mã xác thực OTP của bạn là: " + code);

            String html = """
                <!DOCTYPE html>
                <html>
                <body style="font-family: Arial, sans-serif; background-color: #f8fafc; padding: 24px; margin: 0;">
                    <div style="max-width: 500px; margin: 0 auto; background-color: #ffffff; border-radius: 16px; border: 1px solid #e2e8f0; padding: 32px; box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05);">
                        <div style="display: flex; align-items: center; margin-bottom: 20px;">
                            <h2 style="color: #0f172a; margin: 0; font-size: 20px; font-weight: 800; letter-spacing: 0.5px;">PONDORA SMART AQUACULTURE</h2>
                        </div>
                        <p style="color: #475569; font-size: 14px; line-height: 1.6; margin-bottom: 18px;">
                            Xin chào,<br>
                            Bạn vừa yêu cầu mã xác thực để <b>%s</b> vào hệ thống giám sát môi trường nước ao nuôi Pondora.
                        </p>
                        <div style="background-color: #eff6ff; border: 1.5px dashed #0f62fe; border-radius: 12px; padding: 18px; text-align: center; margin: 24px 0;">
                            <span style="font-size: 32px; font-weight: 900; color: #0f62fe; letter-spacing: 6px;">%s</span>
                        </div>
                        <p style="color: #64748b; font-size: 12.5px; line-height: 1.5; margin-bottom: 20px;">
                            ⏱️ Mã xác thực này có hiệu lực trong <b>5 phút</b>.<br>
                            🔒 Vì lý do bảo mật, vui lòng không cung cấp mã này cho người khác.
                        </p>
                        <hr style="border: none; border-top: 1px solid #f1f5f9; margin: 20px 0;" />
                        <p style="color: #94a3b8; font-size: 11px; margin: 0;">
                            Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này. Hệ thống PONDORA tự động gửi, không cần phản hồi.
                        </p>
                    </div>
                </body>
                </html>
                """.formatted(purpose != null && !purpose.isBlank() ? purpose : "đăng nhập / đăng ký", code);

            helper.setText(html, true);
            mailSender.send(message);
            log.info("[PONDORA OTP] Sent OTP email successfully to {}", email);
        } catch (Exception e) {
            log.error("[PONDORA OTP] Failed to send email via SMTP to {}: {}", email, e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Không thể gửi email OTP qua máy chủ SMTP: " + e.getMessage());
        }
    }

    public boolean verifyOtp(String toEmail, String code) {
        String email = normalizeEmail(toEmail);
        OtpEntry entry = otpStorage.get(email);

        if (entry == null || Instant.now().isAfter(entry.expiresAt())) {
            otpStorage.remove(email);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Mã OTP đã hết hạn hoặc chưa được tạo. Vui lòng gửi lại mã mới.");
        }

        if (entry.attempts() >= MAX_ATTEMPTS) {
            otpStorage.remove(email);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Bạn đã nhập sai mã quá 5 lần. Vui lòng yêu cầu mã OTP mới.");
        }

        if (!entry.code().equals(code != null ? code.trim() : "")) {
            otpStorage.put(email, entry.withIncrementedAttempts());
            int remaining = MAX_ATTEMPTS - (entry.attempts() + 1);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Mã xác thực OTP không chính xác. Bạn còn " + remaining + " lần thử.");
        }

        // Successfully verified
        otpStorage.remove(email);
        return true;
    }

    public static String normalizeEmail(String email) {
        return email != null ? email.trim().toLowerCase(Locale.ROOT) : "";
    }
}

