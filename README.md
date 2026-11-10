# PONDORA 🦐
### Hệ thống IoT Giám Sát Chất Lượng Nước & Quản Lý Ao Tôm Thông Minh

---

## 📖 Giới thiệu

**PONDORA** là hệ thống IoT tích hợp giúp người nuôi tôm:
- **Giám sát** chỉ số chất lượng nước (pH, nhiệt độ, NH₃) liên tục 24/7 qua cảm biến ESP32
- **Số hóa** nhật ký chăm sóc: cho ăn, thay nước, dùng thuốc/chế phẩm
- **Cảnh báo tự động** khi nước vượt ngưỡng nguy hiểm
- **Báo cáo thống kê** biểu đồ theo ngày, tuần

## 🏗️ Kiến trúc hệ thống

```
ESP32 + pH-4502C → ThingSpeak Cloud → Spring Boot Backend → MySQL
                                                          ↕
                                              Flutter Web / Mobile PWA
```

## 🛠️ Công nghệ

| Tầng | Công nghệ |
|:---|:---|
| **Vi điều khiển** | ESP32 DevKit V1 + pH-4502C |
| **Cloud truyền dữ liệu** | ThingSpeak (HTTP) |
| **Backend** | Java 17, Spring Boot 3, REST API |
| **Database** | MySQL 8, Flyway Migration |
| **Frontend** | Flutter / Dart (Web + PWA Mobile) |

## 🚀 Hướng dẫn chạy dự án

### 1. Backend (Spring Boot)
```bash
cd backend
# Tạo file cấu hình từ mẫu
cp src/main/resources/application.properties.example src/main/resources/application.properties
# Điền DB_USERNAME, DB_PASSWORD, ThingSpeak API Key vào application.properties
./mvnw spring-boot:run
```

### 2. Frontend (Flutter Web)
```bash
cd frontend
flutter pub get
flutter build web --release
node serve.js
# Mở http://localhost:3000
```

### 3. Firmware (ESP32)
Mở file `firmware/esp32_water_monitor/esp32_water_monitor.ino` bằng **Arduino IDE**, cập nhật WIFI_SSID và WIFI_PASSWORD, nạp vào ESP32.

## 📡 Tính năng nổi bật

- **Soft Sensor NH₃**: Ước tính khí độc Amonia từ pH mà không cần cảm biến đắt tiền
- **Median Filter 25 mẫu**: Lọc nhiễu điện cực cho đường đồ thị pH mịn và ổn định  
- **Hardware Interrupt (GPIO 19)**: Cảnh báo ngưỡng tức thì qua chip LM393 on-board
- **Offline Buffer**: Tự lưu dữ liệu khi mất Wi-Fi, tự đồng bộ khi có lại mạng
- **PWA Mobile**: Cài được như App trên iOS/Android không qua App Store

## 📋 Yêu cầu hệ thống

- Java 17+
- Flutter 3.x
- MySQL 8.0
- Node.js 18+
- Arduino IDE 2.x (để nạp firmware)

