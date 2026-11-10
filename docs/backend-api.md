# Backend API — giám sát nước IoT

Backend giữ API đăng ký/đăng nhập hiện tại và bổ sung luồng quan trắc nước. Migration V2, V3 và V4 đã được áp dụng cho database phát triển; V4 bổ sung bảng lưu trữ cảnh báo (`water_alerts`). Chạy local bằng `backend/run-local.ps1`; script lấy credential từ Windows user environment và không lưu mật khẩu trong source.

## API ứng dụng (HTTP Basic)

| Method | Path | Mục đích |
|---|---|---|
| `GET/POST` | `/api/sites` | Liệt kê/tạo điểm quan trắc của người dùng |
| `GET/POST` | `/api/sites/{siteId}/devices` | Liệt kê/đăng ký thiết bị cho điểm đo |
| `GET` | `/api/sites/{siteId}/measurements/latest` | Số đo gần nhất |
| `GET` | `/api/sites/{siteId}/measurements?from=&to=&limit=` | Lịch sử theo khoảng ISO-8601, tối đa 1000 mẫu |
| `GET` | `/api/sites/{siteId}/daily-summary?date=YYYY-MM-DD` | Báo cáo theo ngày địa phương của điểm đo |
| `GET` | `/api/sites/{siteId}/alerts?status=` | Danh sách cảnh báo của điểm quan trắc (ACTIVE/RESOLVED) |
| `GET` | `/api/sites/{siteId}/alerts/stats` | Thống kê số lượng cảnh báo theo mức độ |
| `PATCH` | `/api/sites/{siteId}/alerts/{alertId}/resolve` | Đánh dấu xử lý / giải quyết cảnh báo |
| `GET` | `/api/auth/me` | Hồ sơ tài khoản hiện tại, role và trạng thái |
| `GET` | `/api/admin/users` | Danh sách tài khoản (chỉ role `ADMIN`) |
| `PATCH` | `/api/admin/users/{id}/status` | Kích hoạt/tạm khóa tài khoản (chỉ role `ADMIN`) |
| `PATCH` | `/api/admin/users/{id}/role` | Cấp/gỡ role quản trị (chỉ role `ADMIN`) |

Các API đều xác minh site thuộc người dùng đang đăng nhập. Khi đăng ký thiết bị, response trả `deviceToken` đúng một lần; cần lưu tại thiết bị an toàn. Database chỉ lưu BCrypt hash.

Mọi tài khoản đăng ký mới mặc định có role `USER`. Để cấp quyền quản trị đầu tiên, đăng ký tài khoản trước rồi chạy lệnh SQL cấp quyền trong `database/README.md`; sau đó admin có thể quản lý role qua giao diện. Admin không thể tự khóa/đổi role; hệ thống cũng giữ lại ít nhất một admin đang hoạt động.

Mỗi thiết bị trong API liệt kê có `online`, tính từ `lastSeenAt` và `monitoring.device-offline-timeout` (mặc định 300 giây). Thiết bị chưa gửi mẫu lần nào được xem là offline; trạng thái này chỉ phản ánh thời điểm backend nhận mẫu gần nhất.

Tạo điểm đo:

```json
{"name":"Kênh thử nghiệm","location":"Khu A","timezone":"Asia/Ho_Chi_Minh","notes":""}
```

## Gửi số đo thiết bị

`POST /api/device-ingest/{deviceCode}/measurements` với header `X-Device-Token`:

```json
{
  "messageId":"node-01-000001",
  "measuredAt":"2026-10-10T03:42:00Z",
  "readings":{"temperatureC":28.1,"ph":7.4,"dissolvedOxygenMgL":5.2,"turbidityNtu":12.0,"tdsMgL":null}
}
```

Mã gói trùng trên cùng thiết bị bị từ chối. Thời gian tương lai quá 5 phút và dữ liệu ngoài miền kiểm tra cũng bị từ chối. Token dùng đường truyền HTTPS khi triển khai.

## Mô phỏng thiết bị local

Khởi động backend, sau đó chạy trong PowerShell từ thư mục gốc:

```powershell
.\backend\simulate-device.ps1 -DeviceCode WM-0123456789ABCDEF -IntervalSeconds 30
```

Script hỏi device token dưới dạng nhập ẩn, sinh `messageId` mới cùng các chỉ số mẫu trong miền hợp lệ, rồi gửi lặp lại đến backend local. Dừng bằng `Ctrl+C`. Có thể đổi địa chỉ backend bằng `-BaseUrl`; không truyền token qua tham số dòng lệnh.

## Cảnh báo và Tiến trình nền tự động (Scheduler)

1. **Kích hoạt cảnh báo:**
   - Khi thiết bị gửi số đo có mức đánh giá `WATCH`, `HIGH` hoặc `CRITICAL`, hệ thống tự động ghi nhận cảnh báo `WATER_QUALITY`. Nếu số đo quay về `GOOD`, cảnh báo chất lượng nước sẽ tự động giải quyết (`RESOLVED`).
   - Tiến trình nền `DailyAggregationScheduler` chạy mỗi 60 giây để rà soát các thiết bị. Nếu thiết bị không gửi mẫu quá timeout (mặc định 300 giây), cảnh báo `DEVICE_OFFLINE` sẽ được tạo tự động. Khi thiết bị gửi số đo trở lại, cảnh báo offline tự động chuyển sang `RESOLVED`.
2. **Tổng hợp ngày tự động:**
   - Mỗi ngày lúc 00:05, scheduler tự động chốt và lưu `DailyWaterSummary` cho ngày hôm trước của tất cả các điểm đo hoạt động theo đúng múi giờ địa phương.
   - Mỗi 30 phút, scheduler làm mới bản ghi tổng hợp của ngày hôm nay để luôn sẵn sàng dữ liệu nhanh chóng.

## Đánh giá và giới hạn

Mỗi phép đo được gắn `GOOD`, `WATCH`, `HIGH` hoặc `CRITICAL` dựa trên pH, DO, độ đục và TDS (khi có). Báo cáo ngày trả min/trung bình/max từng chỉ số, số mẫu và mức cao nhất trong ngày; ngày không có mẫu là `INSUFFICIENT_DATA`. Ngưỡng mặc định cấu hình trong `application.properties`, phiên bản hiện tại là 1. Chúng là ngưỡng sàng lọc thử nghiệm, không phải quy chuẩn pháp lý. Mặc định cần ít nhất 24 mẫu/ngày (`monitoring.minimum-daily-samples`) mới gán mức sàng lọc; đặt giá trị theo chu kỳ lấy mẫu và mục tiêu quan trắc.

Flutter gọi API lịch sử theo khoảng để vẽ biểu đồ 24 giờ và cho phép chọn pH, oxy hòa tan, độ đục hoặc nhiệt độ. Dữ liệu chỉ có `qualityStatus=VALID` mới được đưa vào biểu đồ.

API cũ `/api/ponds`, nhật ký chăm sóc và nhập tay vẫn còn để tương thích với dữ liệu cũ; màn hình và mô hình chính mới nên dùng `/api/sites`.
