# Hướng dẫn đấu nối & Nạp Firmware ESP32 đo pH

Tài liệu này hướng dẫn bạn ráp nối phần cứng và nạp chương trình cho 3 linh kiện bạn vừa mua:
1. **Mạch vi điều khiển trung tâm ESP32 DevKitC (ESP-32D / 30 chân)**.
2. **Mạch mở rộng chân cho ESP32 (ESP32 30P Expansion Board)**.
3. **Mạch chuyển đổi và đầu dò đo pH nước (pH Sensor Module)**.

---

## 1. SƠ ĐỒ ĐẤU DÂY (WIRING DIAGRAM)

### Bước 1: Gắn ESP32 vào bo mở rộng chân
* Đặt bo ESP32 30 chân cắm thẳng hàng vào 2 hàng chân socket của bo mở rộng (Expansion Board).
* **Lưu ý chiều cắm:** Cổng Micro-USB của ESP32 thường quay về cùng hướng với cổng nguồn DC tròn của bo mở rộng.

### Bước 2: Nối dây từ Module pH sang ESP32
Module pH thường có 6 chân: `VCC`, `GND`, `GND`, `Po` (Analog pH Output), `Do` (Digital Output), `To` (Temperature). Bạn chỉ cần nối **3 dây**:

| Chân Module pH | Chân trên bo mở rộng ESP32 | Mô tả |
| :--- | :--- | :--- |
| **VCC** | **5V** (hoặc chân **V5 / VIN**) | Cấp nguồn 5V cho mạch khuếch đại Op-Amp của cảm biến |
| **GND** | **GND** | Chân nối đất chung |
| **Po** (hoặc A0) | **GPIO 35** (hoặc GPIO 34 / 32 / 33) | Tín hiệu điện áp analog tỷ lệ với độ pH của nước |
| *Do, To* | *Để trống (Không cần nối)* | Do là ngưỡng so sánh, To là nhiệt độ phụ |

> ⚠️ **LƯU Ý QUAN TRỌNG VỀ CHÂN ADC ESP32:**  
> Luôn cắm chân `Po` vào các chân thuộc **ADC1** (như GPIO 32, 33, 34, 35, 36, 39). **Tuyệt đối không cắm vào các chân ADC2** (GPIO 0, 2, 4, 12, 13, 14, 15, 25, 26, 27) vì khi ESP32 bật Wi-Fi, bộ ADC2 sẽ bị hệ điều hành tắt hoặc gây sai lệch tín hiệu!

---

## 2. HƯỚNG DẪN CÀI ĐẶT ARDUINO IDE

1. Tải và cài đặt [Arduino IDE](https://www.arduino.cc/en/software) (khuyến nghị bản 2.x).
2. Vào **File** $\rightarrow$ **Preferences** $\rightarrow$ mục *Additional boards manager URLs*, dán đường link:
   ```text
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
3. Vào **Tools** $\rightarrow$ **Board** $\rightarrow$ **Boards Manager...**, tìm từ khóa `esp32` và bấm **Install** gói của Espressif Systems.
4. Cắm cáp USB nối ESP32 với máy tính.
5. Vào **Tools** $\rightarrow$ **Board** $\rightarrow$ **esp32** $\rightarrow$ chọn **DOIT ESP32 DEVKIT V1** (hoặc *ESP32 Dev Module*).
6. Vào **Tools** $\rightarrow$ **Port** $\rightarrow$ chọn cổng COM tương ứng của ESP32 (ví dụ: `COM3`, `COM4`...).

---

## 3. CẤU HÌNH VÀ NẠP FIRMWARE

Mã nguồn hoàn chỉnh đã được tạo sẵn tại file:
👉 [`firmware/esp32_water_monitor/esp32_water_monitor.ino`](file:///d:/HK1_NAM4/DoAn4/firmware/esp32_water_monitor/esp32_water_monitor.ino)

Mở file trên bằng Arduino IDE và chỉnh sửa **5 thông số** ở đầu file:

```cpp
// 1. Tên và mật khẩu Wi-Fi (BẮT BUỘC dùng Wi-Fi 2.4GHz, ESP32 không hỗ trợ Wi-Fi 5GHz)
const char* WIFI_SSID     = "TEN_WIFI_NHA_BAN";
const char* WIFI_PASSWORD = "MAT_KHAU_WIFI";

// 2. Địa chỉ IP của máy tính đang chạy Backend
// Mở CMD/PowerShell trên máy tính, gõ 'ipconfig' tìm dòng 'IPv4 Address'
const char* SERVER_BASE_URL = "http://192.168.1.15:8080"; 

// 3. Mã thiết bị và Token (Lấy từ app Flutter khi bạn bấm "Thêm thiết bị")
const char* DEVICE_CODE   = "WM-xxxxxxxxxxxxxxxx"; 
const char* DEVICE_TOKEN  = "your_device_token_from_flutter_dialog";
```

Bấm nút **Upload** (mũi tên hướng sang phải) trên Arduino IDE để nạp code.  
*(Nếu IDE hiện chữ `Connecting........_____.....`, hãy bấm giữ nút **BOOT** trên bo ESP32 1-2 giây rồi thả ra để ESP32 vào chế độ nạp flash).*

---

## 4. QUY TRÌNH TEST THỰC TẾ

1. Mở **Serial Monitor** trên Arduino IDE (tốc độ baud: `115200`).
2. ESP32 sẽ hiển thị:
   ```text
   Đang kết nối vào Wi-Fi: ...
   >> Wi-Fi đã kết nối thành công!
   >> Địa chỉ IP của ESP32: 192.168.1.102
   Đang đồng bộ thời gian NTP...
   Thời gian đã được đồng bộ!
   [SENSOR] pH đo được: 7.21
   [HTTP] Đang gửi tới: http://192.168.1.15:8080/api/device-ingest/...
   [THÀNH CÔNG] Backend đã tiếp nhận và đánh giá số đo!
   ```
3. Mở ứng dụng Flutter (web hoặc mobile):
   * Điểm đo sẽ hiển thị ngay thiết bị chuyển sang trạng thái **Đang online**.
   * Chỉ số pH cập nhật thời gian thực trên màn hình **Tổng quan** và vẽ đồ thị trên **Lịch sử**.
   * Thử nhúng đầu dò pH vào nước chanh/giấm (pH < 5) $\rightarrow$ Hệ thống sẽ chuyển sang trạng thái `CRITICAL` hoặc `HIGH` và tự động bắn một **Cảnh báo (Alert)** lên banner trang chủ và tab Cảnh báo!

---

## 5. CÁCH HIỆU CHUẨN ĐẦU DÒ pH (CALIBRATION)

Trên module mạch pH có **2 biến trở vi chỉnh màu xanh dương có ốc vặn nhỏ**:
* Biến trở gần cổng BNC: Dùng để chỉnh **điện áp offset (pH 7)**.
* **Cách hiệu chuẩn nhanh:**
  1. Tháo nắp bảo vệ của đầu dò pH (lưu ý bên trong có dung dịch bảo quản KCl, không đổ đi).
  2. Rửa nhẹ đầu dò bằng nước tinh khiết/nước lọc rồi thấm khô bằng khăn giấy mềm.
  3. Nhúng đầu dò vào nước lọc trung tính (hoặc gói dung dịch chuẩn pH 6.86 / 7.00 đi kèm nếu có).
  4. Nhìn giá trị pH in ra trên Serial Monitor. Dùng tua-vít nhỏ vặn nhẹ ốc trên biến trở xanh đến khi giá trị pH đọc được về mức xấp xỉ `7.00`.

