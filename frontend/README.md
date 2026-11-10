# Thủy Quan — Flutter app

Ứng dụng Flutter đầu tiên của đồ án, kết nối REST API Spring Boot.

## Chạy local

Từ thư mục gốc repository, mở PowerShell và khởi động backend:

```powershell
cd backend
.\run-local.ps1
```

Mở terminal thứ hai tại thư mục gốc để chạy Flutter:

```powershell
cd frontend
flutter run -d chrome
```

Chrome dùng API `http://localhost:8080`. Android Emulator mặc định dùng `http://10.0.2.2:8080`.

Để dùng điện thoại thật hoặc địa chỉ backend khác:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

Thay IP ví dụ bằng địa chỉ máy chạy backend trong mạng LAN. Cleartext HTTP chỉ bật trong Android debug. Production cần HTTPS. Khi dùng Flutter Web, secure storage chỉ hoạt động trên localhost hoặc HTTPS.

## Luồng hiện có

- Đăng ký/đăng nhập; credential lưu trong secure storage của nền tảng để gọi HTTP Basic.
- Giao diện đăng nhập/đăng ký thích ứng màn hình, có xác nhận mật khẩu và khu vực giới thiệu nền tảng.
- Tài khoản quản trị có trang quản lý tài khoản, tìm kiếm, cấp/gỡ role quản trị và kích hoạt/tạm khóa.
- Tạo/chọn điểm quan trắc và đăng ký thiết bị.
- Xem mức sàng lọc ngày, số mẫu, số đo mới nhất và min/trung bình/max pH, DO, độ đục, nhiệt độ.
- Hiển thị device token đúng một lần để cài vào ESP32.

Backend hiện nhận dữ liệu HTTP có token; MQTT/ESP32 thật, biểu đồ chuỗi thời gian và push notification chưa được nối.
