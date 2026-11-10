# Sơ đồ tuần tự theo Use Case

Tài liệu này ánh xạ từng UC con trong `da-Trang-3.drawio (1).png` vào luồng đang có trong dự án, rồi bổ sung các luồng hệ thống cần để vận hành các UC đó. Các UC tổng quát Administration, Site Management, Device Management, Water Quality Summary và Measurement Ingestion được nhóm theo đúng quan hệ trong hình.

**Cơ chế xác thực thực tế:** Flutter gửi email/mật khẩu tới API đăng nhập; backend không phát JWT/session token. Flutter lưu thông tin đăng nhập trong secure storage và dùng HTTP Basic cho API cần tài khoản. Spring Security giới hạn `/api/admin/**` cho role `ADMIN`. Endpoint ingest được mở ở Spring Security nhưng service bắt buộc kiểm tra deviceCode đang ACTIVE và `X-Device-Token` bằng BCrypt hash.

## Chức năng hệ thống: Đăng ký và tự đăng nhập
```mermaid
sequenceDiagram
 actor User as Người dùng
 participant App as Flutter App / ApiClient
 participant AuthC as AuthController
 participant AuthS as AuthService
 participant UserRepo as UserRepository
 participant DB as Database
 participant Secure as FlutterSecureStorage
 User->>App: Nhập tên, email, mật khẩu
 App->>AuthC: POST /api/auth/register
 AuthC->>AuthS: register(request)
 AuthS->>UserRepo: existsByEmail(email đã chuẩn hóa)
 UserRepo->>DB: Kiểm tra email
 DB-->>UserRepo: Chưa tồn tại
 AuthS->>AuthS: BCrypt mã hóa mật khẩu
 AuthS->>UserRepo: saveAndFlush(User, role=USER)
 UserRepo->>DB: INSERT users
 DB-->>UserRepo: User đã lưu
 AuthS-->>AuthC: UserResponse
 AuthC-->>App: 201 Created
 App->>AuthC: POST /api/auth/login (ApiClient gọi tiếp)
 AuthC->>AuthS: login(credentials)
 AuthS->>AuthS: AuthenticationManager xác thực
 AuthS->>UserRepo: Tải User và đối chiếu BCrypt hash
 UserRepo->>DB: SELECT users WHERE email=?
 DB-->>UserRepo: User đang ACTIVE
 AuthS-->>AuthC: UserResponse
 AuthC-->>App: 200 OK
 App->>Secure: Lưu email và mật khẩu
 App-->>User: Mở ứng dụng
```

## Chức năng hệ thống: Đăng nhập
```mermaid
sequenceDiagram
 actor User as Người dùng
 participant App as Flutter App / ApiClient
 participant AuthC as AuthController
 participant AuthS as AuthService
 participant Manager as AuthenticationManager
 participant UserRepo as UserRepository
 participant DB as Database
 participant Secure as FlutterSecureStorage
 User->>App: Nhập email, mật khẩu
 App->>AuthC: POST /api/auth/login
 AuthC->>AuthS: login(request)
 AuthS->>Manager: authenticate(email chuẩn hóa, password)
 Manager->>UserRepo: Tải tài khoản và kiểm tra mật khẩu
 UserRepo->>DB: SELECT users WHERE email=?
 DB-->>UserRepo: User + BCrypt hash
 UserRepo-->>Manager: User đang ACTIVE
 Manager-->>AuthS: Authentication
 AuthS->>UserRepo: findByEmail(authentication.name)
 UserRepo-->>AuthS: User
 AuthS-->>AuthC: UserResponse
 AuthC-->>App: 200 OK (không phát access token)
 App->>Secure: Lưu email và mật khẩu
 Note over App: Các request sau gửi Authorization: Basic base64(email:password)
 App-->>User: Mở ứng dụng
```

## UC tổng quát: Water Quality Summary — Flutter tải dashboard

Trong Flutter, `_load()` tải danh sách điểm đo trước; khi đã chọn một site, bốn truy vấn thiết bị, số đo mới nhất, tổng hợp ngày và lịch sử được gọi song song. Các UC chi tiết tương ứng được mô tả riêng ở các mục sau.

```mermaid
sequenceDiagram
 actor User as Người dùng
 participant App as Flutter App
 participant API as Backend API
 User->>App: Mở dashboard
 App->>API: GET /api/sites (HTTP Basic)
 API-->>App: List<SiteResponse>
 par Tải thiết bị
  App->>API: GET /api/sites/{id}/devices
  API-->>App: DeviceResponses + online + lastSeenAt
 and Tải số đo mới nhất
  App->>API: GET /api/sites/{id}/measurements/latest
  API-->>App: MeasurementResponse hoặc null
 and Tải báo cáo ngày
  App->>API: GET /api/sites/{id}/daily-summary?date=...
  API-->>App: DailySummary
 and Tải lịch sử để vẽ biểu đồ
  App->>API: GET /api/sites/{id}/measurements?from=&to=&limit=500
  API-->>App: List<MeasurementResponse>
 end
 App-->>User: Hiển thị dashboard và biểu đồ
```

## UC tổng quát: Administration

Administration được thực hiện bằng ba UC con bên dưới. Tất cả endpoint `/api/admin/**` qua Spring Security và chỉ role `ADMIN` được gọi.

### UC: Xem danh sách tài khoản (View User Accounts)
```mermaid
sequenceDiagram
 actor Admin as Admin
 participant App as Flutter App
 participant C as AdminController
 participant S as AdminService
 participant R as UserRepository
 participant DB as Database
 Admin->>App: Mở danh sách tài khoản
 App->>C: GET /api/admin/users
 C->>S: listUsers()
 S->>R: Lấy danh sách user
 R->>DB: SELECT users
 DB-->>R: Users
 R-->>S: Users
 S-->>C: UserResponses
 C-->>App: 200 OK + danh sách
 App-->>Admin: Hiển thị tài khoản
```

### UC: Cập nhật trạng thái tài khoản (Update Account Status)
```mermaid
sequenceDiagram
 actor Admin as Admin
 participant App as Flutter App
 participant C as AdminController
 participant S as AdminService
 participant R as UserRepository
 participant DB as Database
 Admin->>App: Chọn trạng thái mới
 App->>C: PATCH /api/admin/users/{id}/status
 C->>S: updateStatus(id, status)
 S->>R: Tìm user theo id
 R->>DB: SELECT users WHERE id=?
 DB-->>R: User
 R-->>S: User
 S->>S: Kiểm tra quy tắc bảo vệ admin
 S->>R: Lưu trạng thái mới
 R->>DB: UPDATE users
 DB-->>R: User đã cập nhật
 S-->>C: UserResponse
 C-->>App: 200 OK
 App-->>Admin: Hiển thị trạng thái mới
```

### UC: Đổi vai trò người dùng (Change User Role)
```mermaid
sequenceDiagram
 actor Admin as Admin
 participant App as Flutter App
 participant C as AdminController
 participant S as AdminService
 participant R as UserRepository
 participant DB as Database
 Admin->>App: Chọn vai trò USER/ADMIN
 App->>C: PATCH /api/admin/users/{id}/role
 C->>S: updateRole(id, role)
 S->>R: Tìm user theo id
 R->>DB: SELECT users WHERE id=?
 DB-->>R: User
 S->>S: Kiểm tra quyền và quy tắc bảo vệ admin
 S->>R: Lưu vai trò mới
 R->>DB: UPDATE users
 DB-->>R: User đã cập nhật
 S-->>C: UserResponse
 C-->>App: 200 OK
 App-->>Admin: Hiển thị vai trò mới
```

## UC tổng quát: Site Management

Site Management trong hình gồm tạo site và xem danh sách site. Backend hiện có hai API tương ứng; không có API cập nhật hoặc xóa site.

### UC: Tạo điểm quan trắc (Create Monitoring Site)
```mermaid
sequenceDiagram
 actor User as User
 participant App as Flutter App
 participant C as MonitoringController
 participant S as MonitoringService
 participant UR as UserRepository
 participant SR as MonitoringSiteRepository
 participant DB as Database
 User->>App: Nhập tên, vị trí, timezone, ghi chú
 App->>C: POST /api/sites
 C->>S: createSite(email, request)
 S->>S: Kiểm tra timezone
 S->>UR: findByEmail(email)
 UR->>DB: SELECT users
 DB-->>UR: User
 S->>SR: save(site)
 SR->>DB: INSERT monitoring_sites
 DB-->>SR: Site
 S-->>C: SiteResponse
 C-->>App: 201 Created
 App-->>User: Hiển thị site mới
```

### UC: Xem danh sách điểm quan trắc (View Monitoring Sites)
```mermaid
sequenceDiagram
 actor User as User
 participant App as Flutter App
 participant C as MonitoringController
 participant S as MonitoringService
 participant R as MonitoringSiteRepository
 participant DB as Database
 User->>App: Mở danh sách site
 App->>C: GET /api/sites
 C->>S: listSites(email)
 S->>R: findAllByOwner_EmailOrderByIdDesc(email)
 R->>DB: SELECT monitoring_sites WHERE owner_email=?
 DB-->>R: Sites
 R-->>S: Sites
 S-->>C: List<SiteResponse>
 C-->>App: 200 OK + danh sách
 App-->>User: Hiển thị các site
```

## UC tổng quát: Device Management

Device Management trong hình gồm đăng ký thiết bị và xem danh sách cùng lần gửi gần nhất.

### UC: Đăng ký thiết bị IoT (Register IoT Device)
```mermaid
sequenceDiagram
 actor User as User
 participant App as Flutter App
 participant C as MonitoringController
 participant S as MonitoringService
 participant SR as MonitoringSiteRepository
 participant DR as IotDeviceRepository
 participant DB as Database
 User->>App: Chọn site, nhập tên thiết bị
 App->>C: POST /api/sites/{siteId}/devices
 C->>S: createDevice(email, siteId, request)
 S->>SR: Xác minh site thuộc user
 SR->>DB: SELECT site theo id và owner
 DB-->>SR: Site
 S->>S: Sinh deviceCode, token; băm token
 S->>DR: save(device)
 DR->>DB: INSERT iot_devices (token_hash)
 DB-->>DR: Device
 S-->>C: DeviceCreatedResponse (token trả một lần)
 C-->>App: 201 Created + deviceCode + token
 App-->>User: Hiển thị thông tin cấu hình
```

### UC: Xem thiết bị / lần gửi gần nhất (View Devices / Last Seen)
```mermaid
sequenceDiagram
 actor User as User
 participant App as Flutter App
 participant C as MonitoringController
 participant S as MonitoringService
 participant SR as MonitoringSiteRepository
 participant DR as IotDeviceRepository
 participant DB as Database
 User->>App: Mở thiết bị của site
 App->>C: GET /api/sites/{siteId}/devices
 C->>S: listDevices(email, siteId)
 S->>SR: Xác minh site thuộc user
 SR->>DB: SELECT monitoring_sites
 DB-->>SR: Site
 S->>DR: Tìm devices thuộc site và owner
 DR->>DB: SELECT iot_devices
 DB-->>DR: Devices + lastSeenAt
 S->>S: Tính online theo lastSeenAt và timeout
 S-->>C: List<DeviceResponse>
 C-->>App: 200 OK + danh sách
 App-->>User: Hiển thị trạng thái và lần gửi gần nhất
```

## UC tổng quát: Water Quality Summary

Nhóm này gồm bốn UC con. Flutter tải một số dữ liệu đồng thời cho dashboard; mỗi UC dưới đây mô tả endpoint/backend cụ thể.

### UC: Xem số đo mới nhất (View Latest Measurement)
```mermaid
sequenceDiagram
 actor User as User
 participant App as Flutter App
 participant C as MonitoringController
 participant S as MeasurementService
 participant MS as MonitoringService
 participant SR as MonitoringSiteRepository
 participant MR as WaterMeasurementRepository
 participant DB as Database
 User->>App: Mở số đo mới nhất
 App->>C: GET /api/sites/{siteId}/measurements/latest
 C->>S: latest(email, siteId)
 S->>MS: ownedSite(email, siteId)
 MS->>SR: Tìm site theo id và owner
 SR->>DB: SELECT monitoring_sites
 DB-->>SR: Site
 S->>MR: Tìm số đo mới nhất theo measuredAt
 MR->>DB: SELECT measurements ORDER BY measured_at DESC LIMIT 1
 DB-->>MR: Measurement + assessmentLevel
 S-->>C: MeasurementResponse
 C-->>App: 200 OK + số đo
 App-->>User: Hiển thị số đo mới nhất
```

### UC: Xem lịch sử số đo (View Measurement History)
```mermaid
sequenceDiagram
 actor User as User
 participant App as Flutter App
 participant C as MonitoringController
 participant S as MeasurementService
 participant MS as MonitoringService
 participant MR as WaterMeasurementRepository
 participant DB as Database
 User->>App: Chọn from, to, limit
 App->>C: GET /api/sites/{siteId}/measurements?from=&to=&limit=
 C->>S: history(email, siteId, from, to, limit)
 S->>MS: Xác minh site thuộc user
 S->>S: Kiểm tra khoảng thời gian và limit 1..1000
 S->>MR: Tìm số đo trong khoảng
 MR->>DB: SELECT measurements theo khoảng, mới nhất trước
 DB-->>MR: Measurements
 S-->>C: List<MeasurementResponse>
 C-->>App: 200 OK + lịch sử
 App-->>User: Hiển thị danh sách/biểu đồ
```

### UC: Xem tổng hợp chất lượng nước theo ngày (View Daily Water Quality Summary)
```mermaid
sequenceDiagram
 actor User as User
 participant App as Flutter App
 participant C as MonitoringController
 participant S as MeasurementService
 participant MS as MonitoringService
 participant MR as WaterMeasurementRepository
 participant SR as DailyWaterSummaryRepository
 participant DB as Database
 User->>App: Chọn site và ngày
 App->>C: GET /api/sites/{siteId}/daily-summary?date=YYYY-MM-DD
 C->>S: daily(email, siteId, date)
 S->>MS: ownedSite(email, siteId)
 MS-->>S: Site + timezone
 S->>S: Tính biên ngày theo timezone của site
 S->>MR: Lấy phép đo thuộc ngày
 MR->>DB: SELECT measurements theo khoảng thời gian
 DB-->>MR: Measurements
 S->>S: Tính min/avg/max, số mẫu, mức xấu nhất
 S->>S: Thiếu mẫu tối thiểu thì INSUFFICIENT_DATA
 S->>SR: Tạo/cập nhật summary
 SR->>DB: INSERT/UPDATE daily_water_summaries
 DB-->>SR: Summary đã lưu
 S-->>C: DailySummary
 C-->>App: 200 OK + báo cáo
 App-->>User: Hiển thị thống kê ngày
```

### UC: Xem đánh giá sàng lọc (View Screening Assessment)
```mermaid
sequenceDiagram
 actor User as User
 participant App as Flutter App
 participant C as MonitoringController
 participant S as MeasurementService
 participant MS as MonitoringService
 participant MR as WaterMeasurementRepository
 participant SR as DailyWaterSummaryRepository
 participant DB as Database
 User->>App: Chọn ngày/xem thẻ đánh giá tổng hợp
 App->>C: GET /api/sites/{siteId}/daily-summary?date=YYYY-MM-DD
 C->>S: daily(email, siteId, date)
 S->>MS: ownedSite(email, siteId)
 MS-->>S: Site + timezone
 S->>MR: Lấy measurements của site trong ngày
 MR->>DB: SELECT measurements theo khoảng ngày
 DB-->>MR: Measurements + assessmentLevel đã lưu
 S->>S: Gộp mức sàng lọc xấu nhất; kiểm tra số mẫu tối thiểu
 S->>SR: Lưu/cập nhật daily summary
 SR->>DB: INSERT/UPDATE daily_water_summaries
 DB-->>SR: Summary
 S-->>C: DailySummary (screeningLevel)
 C-->>App: 200 OK + summary
 App-->>User: Hiển thị mức sàng lọc trong ngày
```

UC “View Daily Water Quality Summary” và “View Screening Assessment” hiện cùng đọc endpoint `/daily-summary`: response chứa cả thống kê min/average/max và `screeningLevel`; Flutter dùng `screeningLevel` trên thẻ đánh giá. Backend yêu cầu đủ số mẫu tối thiểu (mặc định 24); nếu không đủ, trả `INSUFFICIENT_DATA`. Đánh giá từng phép đo được tạo lúc ingest. Các ngưỡng áp dụng cho pH, oxy hòa tan, độ đục và TDS; nhiệt độ được thống kê nhưng không dùng để xếp mức.

## UC tổng quát: Measurement Ingestion

Trong sơ đồ UC, ESP32/Water Sensor khởi tạo luồng ingest; User cũng có quan hệ với UC tổng quát. Luồng xử lý thực tế bắt đầu khi thiết bị POST số đo.

### UC: Gửi số đo qua HTTP API (Submit Measurement via HTTP API)
```mermaid
sequenceDiagram
 participant Device as ESP32 / Water Sensor
 participant C as DeviceIngestController
 participant S as MeasurementService
 participant MS as MonitoringService
 participant DR as IotDeviceRepository
 participant A as WaterAssessmentService
 participant MR as WaterMeasurementRepository
 participant DB as Database
 Device->>C: POST /api/device-ingest/{deviceCode}/measurements + X-Device-Token + payload
 C->>S: ingest(deviceCode, token, request)
 Note over S,DR: Include: Authenticate Device Code and Token
 S->>MS: activeDevice(deviceCode)
 MS->>DR: Tìm device ACTIVE
 DR->>DB: SELECT iot_devices
 DB-->>DR: Device + tokenHash
 S->>S: So khớp token với tokenHash
 Note over S,MR: Include: Validate and Store Reading
 S->>S: Validate DTO, readings không rỗng, timestamp không quá 5 phút tương lai
 S->>MR: Kiểm tra messageId trùng trên cùng thiết bị
 MR->>DB: SELECT theo device_id + message_id
 DB-->>MR: Chưa tồn tại
 Note over S,A: Include: Assess Reading Against Thresholds
 S->>A: assess(readings)
 A-->>S: GOOD / WATCH / HIGH / CRITICAL (pH, DO, độ đục, TDS)
 S->>MR: save(VALID measurement, assessmentLevel)
 MR->>DB: INSERT water_measurements
 DB-->>MR: Measurement đã lưu
 S->>DR: Cập nhật lastSeenAt
 DR->>DB: UPDATE iot_devices
 S-->>C: MeasurementResponse
 C-->>Device: 201 Created + kết quả tiếp nhận
```

Trong bước validate, DTO giới hạn nhiệt độ `-5..60`, pH `0..14`, oxy hòa tan `0..50`, độ đục và TDS không âm; request phải có ít nhất một giá trị đọc, `messageId` không được trùng trên cùng thiết bị, và `measuredAt` không được quá 5 phút trong tương lai. Dữ liệu hợp lệ được lưu với `qualityStatus=VALID`. `lastSeenAt` được cập nhật khi ingest thành công.
