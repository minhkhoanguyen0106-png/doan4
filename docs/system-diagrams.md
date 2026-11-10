# Sơ đồ hệ thống — MVP quan trắc nước bằng IoT

## Current System Use Case Diagram

```mermaid
flowchart LR
    guest[Guest]
    user[Authenticated User]
    admin[Admin]
    device[ESP32 / Water Sensor]

    subgraph system[Water Quality Monitoring System]
        register((Register Account))
        login((Log In))
        manageSites((Create and View Monitoring Sites))
        manageDevices((Register and View Devices))
        viewLatest((View Latest Measurement))
        viewHistory((View Measurement History))
        viewDaily((View Daily Water Quality Summary))
        sendReading((Submit Measurement via HTTP))
        authenticateDevice((Authenticate Device Code and Token))
        assess((Assess Measurement Against Thresholds))
        manageAccounts((View and Manage Accounts))
    end

    guest --> register
    guest --> login
    user --> manageSites
    user --> manageDevices
    user --> viewLatest
    user --> viewHistory
    user --> viewDaily
    admin --> manageAccounts
    device --> sendReading
    sendReading -.->|include| authenticateDevice
    sendReading -.->|include| assess
```

Users register or log in before managing monitoring sites and viewing data. A device submits measurements to the HTTP API with its device code and `X-Device-Token`; the backend authenticates the device, stores the measurement, and evaluates it against configured thresholds. Daily summaries are derived from measurements and may report insufficient data.

## Luồng nhận dữ liệu và đánh giá

```mermaid
sequenceDiagram
    participant Probe as Đầu dò
    participant ESP as ESP32
    participant MQTT as MQTT Broker
    participant Ingest as Backend Ingest
    participant DB as MySQL
    participant Eval as Bộ đánh giá
    Probe->>ESP: Giá trị cảm biến
    ESP->>MQTT: deviceCode, messageId, measuredAt, readings
    MQTT->>Ingest: Chuyển gói đã xác thực
    Ingest->>Ingest: Kiểm tra thiết bị, payload, trùng lặp
    Ingest->>DB: Lưu phép đo + receivedAt + qualityStatus
    Ingest->>Eval: Đánh giá mẫu hợp lệ
    Eval->>DB: Lưu mức sàng lọc + thresholdVersion
```

## Tổng hợp báo cáo ngày

```mermaid
flowchart TD
    A[Phép đo trong ngày địa phương] --> B{Đủ số mẫu hợp lệ?}
    B -- Không --> C[Chưa đủ dữ liệu]
    B -- Có --> D[Tính min, trung bình, max]
    D --> E[Đếm số lần/tỷ lệ vượt ngưỡng]
    E --> F[Chọn mức sàng lọc theo ngưỡng rủi ro cao nhất]
    F --> G[Lưu báo cáo ngày và phiên bản ngưỡng]
```

## Quan hệ dữ liệu chính

```mermaid
erDiagram
    USERS ||--o{ MONITORING_SITES : owns
    MONITORING_SITES ||--o{ IOT_DEVICES : has
    IOT_DEVICES ||--o{ WATER_MEASUREMENTS : sends
    MONITORING_SITES ||--o{ DAILY_WATER_SUMMARIES : summarizes
    MONITORING_SITES ||--o{ THRESHOLD_PROFILES : uses
    MONITORING_SITES ||--o{ ALERTS : raises
```

Các sơ đồ mô tả kiến trúc đích; backend hiện tại chưa tích hợp MQTT hay tính báo cáo ngày.
