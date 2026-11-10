# Database local và schema quan trắc

## Schema và migration

- `schema-mvp.sql` là schema nền gồm tài khoản và bảng ao cá cũ; các câu lệnh tạo bảng dùng `IF NOT EXISTS`.
- `migrations/V2__iot_water_monitoring.sql` bổ sung điểm quan trắc, thiết bị, số đo và tổng hợp ngày, đồng thời giữ nguyên dữ liệu/bảng cũ.
- `migrations/V3__user_roles.sql` bổ sung role `USER`/`ADMIN`; mọi tài khoản hiện hữu và đăng ký mới mặc định là `USER`.
- `migrations/V4__water_alerts.sql` bổ sung bảng cảnh báo `water_alerts` (chất lượng nước ô nhiễm, thiết bị offline).

Áp dụng theo thứ tự trên môi trường phát triển:

```powershell
# Thiết lập database mới: áp dụng V2 trước.
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --login-path=pond-dev -e "source database/migrations/V2__iot_water_monitoring.sql"
# Database đã có V2: chạy V3.
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --login-path=pond-dev -e "source database/migrations/V3__user_roles.sql"
# Database đã có V3: chạy V4.
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --login-path=pond-dev -e "source database/migrations/V4__water_alerts.sql"
```

Migration không xóa bảng hoặc dữ liệu cũ. V2, V3 và V4 đã được áp dụng trên database phát triển cục bộ `fish_pond_management`. Backend tiếp tục dùng database này; Hibernate giữ `ddl-auto=validate`.

Sau khi áp dụng V3, cấp quyền quản trị có chủ đích qua SQL cho tài khoản đã đăng ký: `UPDATE users SET role='ADMIN' WHERE email='admin@example.com';`. Không có cách tự chọn role quản trị trong form đăng ký.

## Khởi động backend local

Đã cấu hình tài khoản MySQL ứng dụng `doan4_app` quyền CRUD trên database này. Credential được lưu trong Windows user environment, không nằm trong repository. Mở PowerShell mới rồi chạy:

```powershell
cd backend
.\run-local.ps1
```

## Cấu hình database

Đặt `DB_URL`, `DB_USERNAME`, `DB_PASSWORD` nếu không dùng mặc định `jdbc:mysql://localhost:3306/fish_pond_management?serverTimezone=UTC`. Không commit credential.

Ngưỡng sàng lọc ban đầu nằm trong `backend/src/main/resources/application.properties` và có thể override bằng cấu hình môi trường. Đây là giá trị mặc định tham khảo, cần điều chỉnh theo nguồn nước/cảm biến trước khi diễn giải kết quả. Số mẫu tối thiểu/ngày mặc định là 24 (`monitoring.minimum-daily-samples`) và cần khớp chu kỳ lấy mẫu thực tế.
