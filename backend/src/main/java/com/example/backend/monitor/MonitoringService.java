package com.example.backend.monitor;

import com.example.backend.user.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.beans.factory.annotation.Value;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneId;
import java.util.Base64;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
public class MonitoringService {
    private final MonitoringSiteRepository sites;
    private final IotDeviceRepository devices;
    private final UserRepository users;
    private final PasswordEncoder encoder;
    private final long deviceOfflineTimeoutSeconds;
    public MonitoringService(MonitoringSiteRepository sites, IotDeviceRepository devices, UserRepository users,
                             PasswordEncoder encoder,
                             @Value("${monitoring.device-offline-timeout:300s}") Duration deviceOfflineTimeout) {
        this.sites = sites; this.devices = devices; this.users = users; this.encoder = encoder;
        this.deviceOfflineTimeoutSeconds = Math.max(1, deviceOfflineTimeout.toSeconds());
    }
    @Transactional(readOnly = true)
    public List<MonitoringDtos.SiteResponse> listSites(String email) {
        return sites.findAllByOwner_EmailOrderByIdDesc(email).stream().map(MonitoringDtos.SiteResponse::from).toList();
    }
    @Transactional
    public MonitoringDtos.SiteResponse createSite(String email, MonitoringDtos.SiteRequest request) {
        ZoneId zone;
        try { zone = ZoneId.of(request.timezone()); }
        catch (Exception e) { throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid timezone"); }
        var owner = users.findByEmail(email).orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED));
        return MonitoringDtos.SiteResponse.from(sites.save(new MonitoringSite(owner, request.name(), request.location(), zone.getId(), request.notes())));
    }
    @Transactional
    public MonitoringDtos.DeviceCreatedResponse createDevice(String email, Long siteId, MonitoringDtos.DeviceRequest request) {
        MonitoringSite site = ownedSite(email, siteId);
        String code = "WM-" + UUID.randomUUID().toString().replace("-", "").substring(0, 16).toUpperCase(Locale.ROOT);
        byte[] bytes = new byte[32]; new SecureRandom().nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        IotDevice device = devices.save(new IotDevice(site, code, request.name(), encoder.encode(token)));
        return new MonitoringDtos.DeviceCreatedResponse(device.getId(), code, device.getName(), device.getStatus(), token);
    }
    @Transactional(readOnly = true)
    public List<MonitoringDtos.DeviceResponse> listDevices(String email, Long siteId) {
        ownedSite(email, siteId);
        Instant now = Instant.now();
        return devices.findAllBySite_IdAndSite_Owner_EmailOrderByIdDesc(siteId, email).stream()
                .map(device -> MonitoringDtos.DeviceResponse.from(device, now, deviceOfflineTimeoutSeconds)).toList();
    }
    public MonitoringSite ownedSite(String email, Long siteId) {
        return sites.findByIdAndOwner_Email(siteId, email).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Monitoring site not found"));
    }
    public IotDevice activeDevice(String deviceCode) {
        return devices.findByDeviceCodeAndStatus(deviceCode, "ACTIVE").orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid device credentials"));
    }
}
