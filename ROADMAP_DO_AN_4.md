# ROADMAP ĐỒ ÁN 4
## HỆ THỐNG IoT GIÁM SÁT CHẤT LƯỢNG VÀ MỨC ĐỘ Ô NHIỄM NƯỚC THEO NGÀY

## 1. Định hướng đề tài

Người dùng đặt đầu dò cảm biến vào nguồn nước cần theo dõi. ESP32 thu thập các chỉ số chất lượng nước và gửi dữ liệu lên hệ thống. Backend lưu số đo, kiểm tra ngưỡng, phát hiện bất thường; ứng dụng hiển thị trạng thái hiện tại, biểu đồ và báo cáo theo từng ngày.

**Mục tiêu cốt lõi:** đo được chất lượng nước, nhận biết dấu hiệu bất thường và theo dõi diễn biến hằng ngày.

Mức ô nhiễm hiển thị là đánh giá sàng lọc theo các chỉ số cảm biến và bộ ngưỡng có nguồn tham khảo; không thay thế kết quả phòng thí nghiệm hoặc kết luận đạt quy chuẩn. Chi tiết tại `docs/project-direction.md`.

## 2. Phạm vi MVP

- Tài khoản người dùng, điểm quan trắc và vị trí nguồn nước.
- Quản lý thiết bị/ESP32 gắn với điểm quan trắc; theo dõi online/offline.
- Thu nhận số đo IoT (MQTT) hoặc mô phỏng payload khi chưa có phần cứng.
- Chỉ số ban đầu: nhiệt độ, pH, DO, độ đục; TDS/độ dẫn điện nếu có đầu dò phù hợp.
- Dashboard số đo mới nhất, chất lượng dữ liệu và lịch sử biểu đồ.
- Tổng hợp mỗi ngày: số mẫu, trung bình, min/max, số lần vượt ngưỡng và mức sàng lọc.
- Cảnh báo vượt ngưỡng và thiết bị mất kết nối.

Không thuộc MVP: AI dự báo, tự động xử lý nước, kết luận pháp lý, nhật ký chăm sóc cá.

## 3. Kiến trúc mục tiêu

```text
Đầu dò trong nước → ESP32 → MQTT/TLS → Spring Boot (REST + MQTT consumer)
                                      → MySQL (điểm đo, thiết bị, phép đo, ngưỡng, tổng hợp, cảnh báo)
Flutter App ← REST API ← Backend
```

Thiết bị gửi thời gian đo, mã gói, mã thiết bị, giá trị và đơn vị. Backend xác thực thiết bị, loại gói trùng, kiểm tra miền giá trị, lưu dữ liệu thô và áp dụng ngưỡng đã phiên bản hóa. Tiến trình tổng hợp ngày dùng múi giờ của điểm quan trắc.

## 4. Công nghệ dự kiến

- Ứng dụng: Flutter/Dart.
- Backend: Java, Spring Boot, REST API; MQTT consumer.
- Cơ sở dữ liệu: MySQL.
- Thiết bị: ESP32 và các đầu dò đã chọn theo yêu cầu đo.
- Truyền dữ liệu: MQTT có xác thực thiết bị; TLS khi triển khai thực tế.

## 5. Tiến độ và mốc nghiệm thu

### Giai đoạn 1 — Chốt yêu cầu và phần cứng

- Chọn đối tượng nguồn nước và vị trí quan trắc.
- Chốt model cảm biến, đơn vị, dải đo, độ chính xác, hiệu chuẩn, chu kỳ lấy mẫu.
- Chốt nguồn tham khảo cho từng ngưỡng; định nghĩa điều kiện “đủ dữ liệu” trong ngày.

### Giai đoạn 2 — Thiết kế hệ thống

- Use case, luồng MQTT, ERD và hợp đồng payload.
- Migration cho điểm quan trắc, thiết bị, số đo, ngưỡng, tổng hợp ngày và cảnh báo.
- Thiết kế xác thực thiết bị và quyền truy cập dữ liệu người dùng.

### Giai đoạn 3 — Backend và dữ liệu

- API điểm quan trắc/thiết bị/lịch sử/báo cáo.
- MQTT ingest và công cụ giả lập thiết bị.
- Kiểm tra dữ liệu, chống trùng, tính trạng thái chỉ số và tổng hợp theo ngày.

### Giai đoạn 4 — Thiết bị và giao diện

- ESP32 đọc cảm biến, gửi payload theo chu kỳ.
- Flutter dashboard, lịch sử, biểu đồ và chi tiết cảnh báo.
- Hiển thị thời điểm cập nhật và trạng thái offline rõ ràng.

### Giai đoạn 5 — Đánh giá

- Đối chiếu số đo với thiết bị tham chiếu/phương pháp phù hợp.
- Đánh giá độ trễ, tỷ lệ gói hợp lệ, xử lý mất kết nối và độ đúng báo cáo ngày.
- Nêu rõ sai số, hiệu chuẩn và giới hạn của phép đo trong báo cáo.

## 6. Sơ đồ thư mục mục tiêu

```text
backend/
  auth/                 # tài khoản và quyền
  monitoring/           # điểm quan trắc
  device/               # đăng ký/trạng thái thiết bị
  measurement/           # ingest, lịch sử, kiểm tra dữ liệu
  assessment/            # ngưỡng, phân loại sàng lọc, tổng hợp ngày
  alert/                 # cảnh báo
  integration/mqtt/      # kết nối broker và payload IoT
  common/
database/
  schema-mvp.sql         # schema nền hiện tại
  migrations/            # migration chuyển sang quan trắc IoT
docs/
  project-direction.md
  mvp-scope.md
  use-cases.md
  database-design.md
  backend-api.md
  system-diagrams.md
  ui-wireframes.md
```

Đây là cấu trúc đích; không khẳng định các module IoT đã được code.

## 7. Tình trạng hiện tại trong repository

Backend đã hoàn thiện API điểm quan trắc/thiết bị, ingest HTTP có token, công cụ PowerShell mô phỏng thiết bị, phân loại chỉ số, lịch sử, tổng hợp ngày tự động bằng Scheduled job (chốt 00:05 hàng ngày và làm mới mỗi 30 phút), phát hiện và cảnh báo thiết bị offline sau 300s, quản lý cảnh báo chất lượng nước (`water_alerts`), và phân quyền vai trò người dùng (USER/ADMIN). Migration V2, V3, V4 đã được áp dụng cho database phát triển. Mã nguồn Flutter đã được tái cấu trúc thành các module rõ ràng (`screens/`, `widgets/`, `dialogs/`, `models/`), có màn hình Cảnh báo trực quan, dashboard theo ngày, biểu đồ lịch sử 24 giờ, quản lý điểm đo/thiết bị và quản trị tài khoản. Chưa tích hợp MQTT/ESP32 thật hoặc push notification qua FCM/APNS; API quản lý ao cũ còn giữ trong giai đoạn chuyển tiếp.

## 8. Tiêu chí hoàn thành MVP

- Một thiết bị thật hoặc mô phỏng gửi được dữ liệu có xác thực.
- Hệ thống loại gói trùng và đánh dấu mẫu lỗi.
- Dashboard thể hiện phép đo mới nhất, thời điểm nhận và trạng thái thiết bị.
- Người dùng xem được thống kê từng ngày, truy vết đến phép đo gốc và biết phiên bản ngưỡng.
- Mức sàng lọc không hiển thị khi thiếu dữ liệu tối thiểu; giao diện nêu rõ đây không phải kết quả kiểm nghiệm.
