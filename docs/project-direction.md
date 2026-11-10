# Định hướng đồ án — Giám sát chất lượng và ô nhiễm nước bằng IoT

## Tên đề tài đề xuất

**Xây dựng hệ thống IoT giám sát chất lượng và mức độ ô nhiễm nước theo ngày**

## Mục tiêu

Người dùng đặt đầu dò cảm biến xuống nguồn nước cần theo dõi. Bộ điều khiển ESP32 đọc các thông số, gửi dữ liệu lên máy chủ; hệ thống lưu lịch sử, tổng hợp theo ngày và hiển thị mức cảnh báo dựa trên các ngưỡng cấu hình. Trọng tâm là **đo liên tục – xem biến động – phát hiện dấu hiệu bất thường – tra cứu theo ngày**.

Mức ô nhiễm trong ứng dụng là **đánh giá sàng lọc từ các chỉ số cảm biến**, không phải kết luận pháp lý hay kết quả kiểm nghiệm phòng thí nghiệm. Cần ghi rõ loại cảm biến, đơn vị, hiệu chuẩn và ngưỡng đang dùng.

## Phạm vi MVP đề xuất

1. Quản lý tài khoản và điểm quan trắc (tên nguồn nước, vị trí, mô tả).
2. Đăng ký thiết bị và gắn thiết bị với một điểm quan trắc.
3. Thu nhận số đo IoT có thời gian đo, mã thiết bị và trạng thái chất lượng dữ liệu.
4. Theo dõi nhiệt độ, pH, oxy hòa tan (DO), độ đục; có thể bổ sung độ dẫn điện/TDS nếu phần cứng có cảm biến phù hợp.
5. Tính trạng thái từng chỉ số theo bộ ngưỡng có phiên bản; tổng hợp trạng thái ô nhiễm sàng lọc cho ngày.
6. Dashboard số đo mới nhất, biểu đồ ngày, bộ lọc khoảng thời gian và bảng tổng hợp từng ngày.
7. Cảnh báo khi ngưỡng bị vượt hoặc thiết bị ngừng gửi dữ liệu.

Ngoài MVP: AI dự đoán, điều khiển thiết bị, bản đồ diện rộng, tích hợp dữ liệu kiểm nghiệm và kết luận đạt chuẩn pháp lý.

## Cách diễn giải mức độ ô nhiễm

Không có một cảm biến đơn lẻ đo được “độ ô nhiễm” chung. Mỗi cảm biến chỉ đo một đại lượng. Hệ thống phân loại từng thông số bằng ngưỡng và tổng hợp thành mức sàng lọc:

- **Tốt:** mọi thông số đủ dữ liệu đều trong ngưỡng.
- **Cần theo dõi:** có thông số cảnh báo nhẹ hoặc thiếu một phần dữ liệu.
- **Ô nhiễm cao:** có thông số vượt ngưỡng nghiêm trọng hoặc nhiều thông số cùng cảnh báo.
- **Chưa đủ dữ liệu:** không có đủ số phép đo hợp lệ trong ngày.

Ngưỡng cụ thể phải cấu hình theo mục tiêu sử dụng và nguồn tham khảo được ghi trong báo cáo. Tổng hợp ngày phải thể hiện số phép đo hợp lệ, trung bình, nhỏ nhất, lớn nhất và thời lượng/số lần vượt ngưỡng; không chỉ hiển thị một nhãn.

## Luồng dữ liệu

```text
Đầu dò đặt trong nước
  → Cảm biến (pH, nhiệt độ, DO, độ đục, ...)
  → ESP32 đọc/lọc và đóng dấu thời gian
  → Wi-Fi / MQTT
  → Backend xác thực thiết bị, kiểm tra dữ liệu
  → MySQL lưu số đo và sự kiện cảnh báo
  → Tiến trình tổng hợp ngày
  → Ứng dụng hiển thị dashboard, biểu đồ, lịch sử
```

Thiết kế phần cứng cần tách đầu dò khỏi bo điều khiển nếu ESP32 không phù hợp để ngâm. Bản thân cảm biến phải có đầu dò, mạch giao tiếp, vỏ chống nước và quy trình hiệu chuẩn phù hợp.

## Kiến trúc phần mềm

- **Thiết bị:** ESP32 + đầu dò; lấy mẫu theo chu kỳ, gắn `device_id`, `measured_at`, giá trị và mã chất lượng.
- **Truyền tin:** MQTT qua TLS; topic theo thiết bị, ví dụ `water-monitor/{deviceCode}/measurements`. Thiết bị có thông tin xác thực riêng.
- **Backend:** Spring Boot REST cho ứng dụng; MQTT consumer riêng cho thiết bị; validation, lưu số đo, đánh giá ngưỡng và tạo cảnh báo.
- **Database:** MySQL; tách điểm quan trắc, thiết bị, số đo, cấu hình ngưỡng, tổng hợp ngày và cảnh báo.
- **Ứng dụng:** Flutter; dashboard, trạng thái thiết bị, chất lượng hiện tại, lịch sử theo ngày, cảnh báo.

## Mô hình dữ liệu khái niệm

```text
User 1 ── N MonitoringSite 1 ── N IoTDevice
                                  │
                                  └── 1 ── N WaterMeasurement
MonitoringSite 1 ── N DailyWaterSummary
MonitoringSite 1 ── N ThresholdProfile
MonitoringSite 1 ── N Alert
```

Mỗi phép đo thuộc về một thiết bị và điểm quan trắc; lưu nguồn, thời điểm đo, thời điểm nhận, đơn vị/giá trị, trạng thái dữ liệu và phiên bản ngưỡng dùng đánh giá. Dữ liệu thô được giữ lại để có thể tính lại báo cáo khi ngưỡng thay đổi.

## Chỉ số đánh giá đồ án

- Tỷ lệ gói đo hợp lệ được nhận và lưu.
- Độ trễ từ thiết bị đến dashboard.
- Khả năng nhận biết thiết bị offline.
- Độ đúng của tổng hợp ngày so với dữ liệu mẫu.
- Kết quả hiệu chuẩn/đối chiếu đầu dò trong điều kiện thử nghiệm.

## Các bước triển khai

1. Chốt nguồn nước, đầu dò thực tế, đơn vị, chu kỳ lấy mẫu và ngưỡng tham khảo.
2. Hoàn thiện schema và API ingest; trước mắt có thể giả lập payload thiết bị.
3. Tích hợp ESP32, MQTT và xác thực thiết bị.
4. Làm dashboard, biểu đồ và báo cáo ngày.
5. Thêm cảnh báo, kiểm tra hiệu chuẩn và đánh giá giới hạn của phép đo.

## Tình trạng repository

Backend hiện có tài khoản, quản lý điểm quan trắc/thiết bị, nhận số đo HTTP có token, phân loại sàng lọc, tổng hợp ngày và xác định online/offline từ thời điểm nhận mẫu theo timeout cấu hình. Ứng dụng Flutter có đăng nhập, điểm đo, thiết bị, báo cáo ngày và biểu đồ chuỗi thời gian 24 giờ. Chưa tích hợp MQTT consumer/ESP32 thật hoặc push notification. API quản lý ao cũ vẫn được giữ trong giai đoạn chuyển tiếp.
