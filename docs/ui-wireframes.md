# Wireframe — Ứng dụng giám sát chất lượng nước

## Điều hướng

```text
Đăng nhập → Tổng quan → Điểm quan trắc → Chi tiết điểm đo
                                ├─ Lịch sử / biểu đồ
                                ├─ Báo cáo theo ngày
                                ├─ Thiết bị và trạng thái
                                └─ Trạng thái thiết bị
```

## Tổng quan

```text
┌──────────────────────────────┐
│ Giám sát nguồn nước     [🔔] │
│ Điểm đang theo dõi       03   │
│ Thiết bị online          02   │
│                              │
│ Điểm đo · Hồ A               │
│ Chất lượng: CẦN THEO DÕI     │
│ Cập nhật 10:42 · 5 phút trước│
│ pH 7.4    DO 5.2 mg/L        │
│ Đục 12 NTU  Nhiệt độ 28.1°C  │
│                              │
│ [Xem báo cáo hôm nay]        │
└──────────────────────────────┘
```

## Chi tiết điểm quan trắc

```text
┌──────────────────────────────┐
│ ‹ Hồ A          Thiết bị ONLINE│
│ Mức sàng lọc: CẦN THEO DÕI    │
│ Số mẫu hợp lệ hôm nay: 276/288│
│                              │
│ [24 giờ ▾] [Chọn ngày]        │
│ Biểu đồ pH / DO / độ đục      │
│                              │
│ pH       TB 7.4  Min 7.1 Max 7.8│
│ DO       TB 5.2  Min 4.3 Max 6.1│
│ Độ đục   TB 12   Min 8   Max 31 │
│ Vượt ngưỡng: DO 3 lần         │
│ [Xem phép đo] [Thiết bị]      │
└──────────────────────────────┘
```

Hiển thị rõ nguồn/múi giờ ngày, số mẫu dự kiến và thực nhận, ngưỡng đã dùng. Khi thiếu số mẫu, ghi “Chưa đủ dữ liệu” thay vì suy ra mức ô nhiễm.

## Danh sách thiết bị

```text
┌──────────────────────────────┐
│ Thiết bị                     │
│ ESP32-WATER-01 · ONLINE      │
│ Hồ A · Nhận dữ liệu 10:42    │
│ ESP32-WATER-02 · OFFLINE     │
│ Kênh Bắc · Nhận cuối 08:10   │
│ [Gắn thiết bị]               │
└──────────────────────────────┘
```

## Trạng thái thiết bị

Hiển thị mã thiết bị, trạng thái đang hoạt động/đã vô hiệu hóa, trạng thái online/offline dựa trên timeout và lần gửi dữ liệu gần nhất. Thông báo đẩy thuộc bước tiếp theo.

## Nguyên tắc giao diện

- Phân biệt trạng thái cảm biến, kết nối thiết bị và đánh giá chất lượng nước.
- Gắn đơn vị vào từng giá trị; cho xem thời điểm đo và thời điểm nhận.
- Nêu đây là đánh giá sàng lọc từ cảm biến, không phải kết luận kiểm nghiệm.
- Có trạng thái loading, lỗi, không có dữ liệu và dữ liệu chưa đủ.
