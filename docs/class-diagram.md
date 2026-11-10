# Sơ đồ lớp hệ thống quan trắc chất lượng nước

Sơ đồ được đối chiếu với cấu trúc hiện tại trong `backend/src/main/java/com/example/backend`. Phần thứ nhất mô tả lớp dữ liệu và quan hệ lưu trữ; phần thứ hai mô tả các lớp Flutter/API/service/repository thực hiện các UC. Các lớp DTO được rút gọn để sơ đồ dễ đọc.

## 1. Lớp nghiệp vụ và quan hệ dữ liệu

```mermaid
classDiagram
    direction LR

    class User {
        -Long id
        -String email
        -String passwordHash
        -String displayName
        -UserStatus status
        -UserRole role
        -Instant createdAt
        -Instant updatedAt
        +setStatus(status)
        +setRole(role)
    }

    class UserRole {
        <<enumeration>>
        USER
        ADMIN
    }

    class UserStatus {
        <<enumeration>>
        ACTIVE
        DISABLED
    }

    class MonitoringSite {
        -Long id
        -User owner
        -String name
        -String location
        -String timezone
        -String notes
        -String status
        -Instant createdAt
    }

    class IotDevice {
        -Long id
        -MonitoringSite site
        -String deviceCode
        -String name
        -String tokenHash
        -String status
        -Instant lastSeenAt
        +markSeen(at)
    }

    class WaterMeasurement {
        -Long id
        -IotDevice device
        -String messageId
        -Instant measuredAt
        -Instant receivedAt
        -BigDecimal temperatureC
        -BigDecimal ph
        -BigDecimal dissolvedOxygenMgL
        -BigDecimal turbidityNtu
        -BigDecimal tdsMgL
        -String qualityStatus
        -String assessmentLevel
        -int thresholdVersion
    }

    class DailyWaterSummary {
        -Long id
        -MonitoringSite site
        -LocalDate localDate
        -long validSampleCount
        -String screeningLevel
        -int thresholdVersion
        -String aggregatesJson
        -Instant updatedAt
        +refresh(count, level, json)
    }

    class WaterAlert {
        -Long id
        -MonitoringSite site
        -IotDevice device
        -String alertType
        -String severity
        -String title
        -String message
        -String status
        -Instant triggeredAt
        -Instant resolvedAt
        -Instant createdAt
        +resolve(at)
    }

    User --> UserRole : role
    User --> UserStatus : status
    User "1" --> "0..*" MonitoringSite : owns
    MonitoringSite "1" --> "0..*" IotDevice : contains
    IotDevice "1" --> "0..*" WaterMeasurement : sends
    MonitoringSite "1" --> "0..*" DailyWaterSummary : summarized by
    MonitoringSite "1" --> "0..*" WaterAlert : raises
    IotDevice "1" --> "0..*" WaterAlert : relates to
```

Các quan hệ trên phản ánh khóa ngoại trong database: site thuộc một User; thiết bị thuộc một site; phép đo thuộc một thiết bị; bản tổng hợp ngày thuộc một site. Mã nguồn JPA khai báo các liên kết từ phía lớp con (`ManyToOne`); các bội số phía `0..*` được suy ra từ khóa ngoại, không phải danh sách collection được khai báo trên lớp cha. `MonitoringSite.status` và `IotDevice.status` hiện là `String`; chỉ role và trạng thái User là enum.

`WaterMeasurement` có ràng buộc duy nhất theo cặp `(device_id, message_id)` để chống nhận trùng gói trên cùng thiết bị. `DailyWaterSummary` có ràng buộc duy nhất theo `(site_id, local_date, threshold_version)`.

## 2. Lớp giao tiếp và xử lý nghiệp vụ

```mermaid
classDiagram
    direction LR

    class ApiClient {
        <<Flutter>>
        +register(name, email, password)
        +login(email, password)
        +adminUsers()
        +setUserStatus(id, status)
        +setUserRole(id, role)
        +sites()
        +createSite(name, location, timezone, notes)
        +devices(siteId)
        +createDevice(siteId, name)
        +latest(siteId)
        +history(siteId, from, to, limit)
        +dailySummary(siteId, day)
    }
    class FlutterSecureStorage {
        <<Flutter plugin>>
        +read(key)
        +write(key, value)
        +delete(key)
    }
    class DeviceActor {
        <<external actor>>
        +sendMeasurement(payload)
    }

    class AuthController {
        +register(request)
        +login(request)
        +me()
    }
    class AuthService {
        +register(request)
        +login(request)
        +currentUser(email)
        +normalizeEmail(email)
    }

    class AdminController {
        +users()
        +setStatus(auth, id, request)
        +setRole(auth, id, request)
    }
    class AdminService {
        +users()
        +setStatus(actorEmail, id, status)
        +setRole(actorEmail, id, role)
    }

    class MonitoringController {
        +listSites(auth)
        +createSite(auth, request)
        +devices(auth, siteId)
        +createDevice(auth, siteId, request)
        +latest(auth, siteId)
        +history(auth, siteId, from, to, limit)
        +daily(auth, siteId, date)
    }
    class DeviceIngestController {
        +ingest(deviceCode, token, request)
    }
    class AlertController {
        +listAlerts(auth, siteId, status)
        +getStats(auth, siteId)
        +resolveAlert(auth, siteId, alertId)
    }
    class ThingSpeakSyncService {
        -long channelId
        -String readApiKey
        +syncFromThingSpeak()
    }
    class MonitoringService {
        +listSites(email)
        +createSite(email, request)
        +listDevices(email, siteId)
        +createDevice(email, siteId, request)
        +ownedSite(email, siteId)
        +activeDevice(deviceCode)
    }
    class MeasurementService {
        +ingest(deviceCode, token, request)
        +latest(email, siteId)
        +history(email, siteId, from, to, limit)
        +daily(email, siteId, date)
    }
    class AlertService {
        +listAlerts(email, siteId, status)
        +getStats(email, siteId)
        +resolveAlert(email, siteId, alertId)
        +recordQualityAlert(site, device, level, readings, at)
        +recordDeviceOffline(device, at)
        +resolveDeviceOffline(device)
    }
    class WaterAssessmentService {
        +assess(readings)
        +worst(levelA, levelB)
    }

    class SecurityConfig {
        +securityFilterChain()
        +userDetailsService()
        +passwordEncoder()
    }
    class AuthenticationManager {
        <<Spring Security>>
    }
    class PasswordEncoder {
        <<interface>>
    }

    class UserRepository {
        <<interface>>
    }
    class MonitoringSiteRepository {
        <<interface>>
    }
    class IotDeviceRepository {
        <<interface>>
    }
    class WaterMeasurementRepository {
        <<interface>>
    }
    class DailyWaterSummaryRepository {
        <<interface>>
    }
    class WaterAlertRepository {
        <<interface>>
    }

    class AuthDtos {
        <<DTO container>>
        RegisterRequest
        LoginRequest
        UserResponse
    }
    class MonitoringDtos {
        <<DTO container>>
        SiteRequest, SiteResponse
        DeviceRequest, DeviceResponse
        DeviceCreatedResponse
    }
    class MeasurementDtos {
        <<DTO container>>
        Readings, IngestRequest
        MeasurementResponse
        MetricStats, DailySummary
    }
    class AlertDtos {
        <<DTO container>>
        AlertResponse
        AlertStatsResponse
    }

    ApiClient ..> AuthController : HTTP /api/auth
    ApiClient ..> AdminController : HTTP /api/admin
    ApiClient ..> MonitoringController : HTTP /api/sites
    ApiClient ..> AlertController : HTTP /api/sites/{id}/alerts
    ApiClient --> FlutterSecureStorage : stores login credentials
    DeviceActor ..> DeviceIngestController : HTTP POST + X-Device-Token
    AuthController --> AuthService
    AdminController --> AdminService
    MonitoringController --> MonitoringService
    MonitoringController --> MeasurementService
    AlertController --> AlertService
    DeviceIngestController --> MeasurementService

    AuthService --> UserRepository
    AdminService --> UserRepository
    MonitoringService --> UserRepository
    MonitoringService --> MonitoringSiteRepository
    MonitoringService --> IotDeviceRepository
    MeasurementService --> MonitoringService
    MeasurementService --> WaterMeasurementRepository
    MeasurementService --> DailyWaterSummaryRepository
    MeasurementService --> WaterAssessmentService
    AlertService --> WaterAlertRepository
    AlertService --> MonitoringService
    ThingSpeakSyncService --> MonitoringSiteRepository
    ThingSpeakSyncService --> IotDeviceRepository
    ThingSpeakSyncService --> WaterMeasurementRepository
    ThingSpeakSyncService --> WaterAssessmentService
    ThingSpeakSyncService --> AlertService

    AuthService --> AuthenticationManager
    AuthService --> PasswordEncoder
    MonitoringService --> PasswordEncoder
    MeasurementService --> PasswordEncoder
    SecurityConfig ..> UserRepository : loads active accounts
    SecurityConfig ..> PasswordEncoder : BCrypt

    AuthController ..> AuthDtos
    AuthService ..> AuthDtos
    AdminController ..> AuthDtos
    AdminService ..> AuthDtos
    MonitoringController ..> MonitoringDtos
    MonitoringController ..> MeasurementDtos
    AlertController ..> AlertDtos
    AlertService ..> AlertDtos
    DeviceIngestController ..> MeasurementDtos
    MeasurementService ..> MeasurementDtos
    WaterAssessmentService ..> MeasurementDtos : reads Readings

    UserRepository ..> User : persists
    MonitoringSiteRepository ..> MonitoringSite : persists
    IotDeviceRepository ..> IotDevice : persists
    WaterMeasurementRepository ..> WaterMeasurement : persists
    DailyWaterSummaryRepository ..> DailyWaterSummary : persists
    WaterAlertRepository ..> WaterAlert : persists
```

Các repository trong sơ đồ là interface Spring Data JPA kế thừa `JpaRepository` cho entity tương ứng; các phương thức truy vấn thực tế nằm trong từng interface repository của mã nguồn.

## 3. Cách đọc sơ đồ theo các UC (Use Case Realization)

- **Administration (Quản trị tài khoản):** `AdminController` → `AdminService` → `UserRepository` → `User`.
- **Site Management (Quản lý điểm đo):** `MonitoringController` → `MonitoringService` → `MonitoringSiteRepository` → `MonitoringSite`.
- **Device Management (Quản lý thiết bị IoT):** `MonitoringController` → `MonitoringService` → `IotDeviceRepository` → `IotDevice`.
- **Water Quality Summary (Theo dõi chất lượng & Lịch sử số đo):** `MonitoringController` → `MeasurementService` → `WaterMeasurementRepository` / `DailyWaterSummaryRepository`; `WaterAssessmentService` đánh giá mức độ ô nhiễm theo ngưỡng quy chuẩn.
- **Measurement Ingestion (Tiếp nhận số đo từ cảm biến):** `DeviceIngestController` → `MeasurementService` → xác thực token qua `MonitoringService`, lưu `WaterMeasurement`, cập nhật `lastSeenAt` trên `IotDevice`, rồi chuyển `WaterAssessmentService` đánh giá.
- **ThingSpeak Cloud Integration (Tự động thu thập từ ThingSpeak):** `ThingSpeakSyncService` (chạy nền định kỳ `@Scheduled`) tự động lấy số đo mới từ API ThingSpeak, nạp vào `WaterMeasurementRepository`, cập nhật trạng thái online cho `IotDevice`, đồng thời kích hoạt `AlertService`.
- **Early Warning & Alert System (Trung tâm cảnh báo tự động):** `AlertController` → `AlertService` → `WaterAlertRepository` → `WaterAlert`. Khi phát hiện chỉ số nước vượt ngưỡng (WATCH, HIGH, CRITICAL) hoặc thiết bị mất kết nối, cảnh báo sẽ được kích hoạt tự động.
- `ApiClient` là lớp phía Flutter Client gọi các API RESTful qua giao thức HTTP; dữ liệu phản hồi được map thành các Model tương ứng trong ứng dụng.
