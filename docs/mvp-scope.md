# Phạm vi MVP — Giám sát chất lượng nước bằng IoT

## Mục tiêu

Trình diễn trọn luồng từ một thiết bị cảm biến (hoặc bộ mô phỏng ESP32) gửi số đo lên hệ thống, đến dashboard hiển thị chỉ số hiện tại, lịch sử và mức cảnh báo theo ngày.

## Đưa vào MVP

- Tài khoản người dùng và quản lý điểm quan trắc.
- Quản lý thiết bị: mã thiết bị, điểm quan trắc, trạng thái kết nối, lần nhận dữ liệu gần nhất.
- Nhận dữ liệu đo từ IoT qua MQTT; có công cụ/API mô phỏng để phát triển khi chưa có phần cứng.
- Lưu các phép đo: thời gian đo/nhận, nhiệt độ, pH, DO, độ đục; TDS/độ dẫn điện là tùy chọn theo cảm biến thực tế.
- Kiểm tra phạm vi, loại dữ liệu, thiết bị và chống nhận trùng gói tin.
- Cấu hình ngưỡng có phiên bản và nguồn tham khảo; phân loại từng phép đo.
- Tổng hợp ngày: số mẫu hợp lệ, trung bình, min/max, số lần vượt ngưỡng và mức sàng lọc.
- Dashboard hiện tại, biểu đồ và lịch sử theo ngày/khoảng thời gian.
- Hiển thị mức sàng lọc theo từng phép đo/báo cáo ngày, thời điểm nhận cuối và trạng thái online/offline suy ra theo timeout cấu hình của thiết bị. Thông báo cảnh báo đẩy là bước tiếp theo.

## Chưa làm trong MVP

- Kết luận đạt/không đạt quy chuẩn pháp lý.
- AI dự báo, tự động điều khiển bơm/xử lý nước, bản đồ nhiều trạm, tích hợp phòng thí nghiệm.
- Nhật ký cho ăn, đợt nuôi và các chức năng quản lý cá không phục vụ trực tiếp việc quan trắc.

## Quy tắc nghiệp vụ

1. Một điểm quan trắc có thể có nhiều thiết bị; mỗi thiết bị tại một thời điểm gắn với một điểm.
2. Mỗi gói đo lưu `device_id`, `measured_at`, `received_at`, mã gói duy nhất và các giá trị cảm biến hiện có; giá trị thiếu lưu `NULL`, không thay bằng 0.
3. Kiểm tra quyền sở hữu điểm quan trắc ở mọi API ứng dụng. Thiết bị gửi qua thông tin xác thực riêng, không dùng tài khoản người dùng.
4. Chỉ số đo phải có đơn vị, giới hạn hợp lệ và trạng thái chất lượng; số đo lỗi/ngoài miền vật lý được giữ dấu để chẩn đoán nhưng không đưa vào tổng hợp.
5. Mức cảnh báo là đánh giá sàng lọc theo cấu hình ngưỡng, không phải kết luận ô nhiễm theo quy chuẩn. Mỗi đánh giá lưu phiên bản ngưỡng đã sử dụng.
6. Báo cáo ngày tính theo múi giờ của điểm quan trắc; lưu thời điểm gốc UTC và lưu ngày địa phương rõ ràng.
7. Mức ngày chỉ kết luận khi đủ số mẫu tối thiểu đã cấu hình; nếu thiếu 24 mẫu mặc định, hiển thị “Chưa đủ dữ liệu”; có thể cấu hình theo chu kỳ lấy mẫu.
8. Tổng hợp ngày có thể tính lại từ dữ liệu thô; không sửa/xóa lịch sử đo âm thầm.
9. Thiết bị được xem là offline khi quá thời gian cấu hình không nhận được dữ liệu.

## Yêu cầu phi chức năng

- MQTT có xác thực từng thiết bị; triển khai dùng TLS.
- API ứng dụng yêu cầu xác thực và kiểm tra quyền sở hữu phía backend.
- Có giới hạn tốc độ/payload, validation dữ liệu, log lỗi ingest và chống gói trùng.
- Truy vấn lịch sử có phân trang và lọc theo điểm quan trắc/thời gian.
- Dashboard cần phân biệt “chưa có dữ liệu”, thiết bị không có lần nhận gần đây và mức sàng lọc chất lượng nước.
- Ghi rõ chu kỳ lấy mẫu, độ chính xác, phương pháp hiệu chuẩn, nguồn ngưỡng và giới hạn cảm biến.

## Việc cần chốt khi có phần cứng

Model từng đầu dò, giao tiếp với ESP32, dải đo/độ chính xác, tần suất lấy mẫu, cách hiệu chuẩn, vị trí lắp, ngưỡng và số mẫu tối thiểu/ngày. Không đặt một ngưỡng chung cho mọi nguồn nước nếu chưa xác định mục tiêu quan trắc.
