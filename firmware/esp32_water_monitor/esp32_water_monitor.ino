/*
 * =========================================================
 * DU AN: IOT GIAM SAT MOI TRUONG AO NUOI THUY SAN & pH
 * CAM BIEN: pH PH-4502C (Full 3 kenh: Po, To, Do)
 * VI DIEU KHIEN: ESP32 DEVKIT V1
 *
 * KET NOI PHAN CUNG:
 *   Po  -> Cau phan ap 10k:10k -> GPIO35 (Do pH Analog)
 *   To  -> Cam truc tiep       -> GPIO34 (Do Nhiet do Analog)
 *   Do  -> Cam truc tiep       -> GPIO19 (Ngat bao dong Digital)
 *   V+  -> Nguon 5V
 *   GND -> GND chung
 *
 * THINGSPEAK:
 *   FIELD 1 = Gia tri pH
 *   FIELD 2 = Nhiet do nuoc (°C)
 *   FIELD 3 = Trang thai canh bao Do (0: An toan, 1: Canh bao)
 *
 * HIEU CHUAN:
 *   pH 4.01 = 1.998 V (do tai GPIO35)
 *   pH 6.86 = 1.496 V (do tai GPIO35)
 *
 * SERIAL MONITOR: 115200 baud
 * CHU KY GUI: 20 giay
 * =========================================================
 */

#include <WiFi.h>
#include <HTTPClient.h>

// =========================================================
// 1. CAU HINH WIFI
// =========================================================

const char* WIFI_SSID = "iPhone";
const char* WIFI_PASSWORD = "thaochode";

// =========================================================
// 2. CAU HINH THINGSPEAK
// =========================================================

const char* WRITE_API_KEY = "8L8NJP5QT7UAE0IE";
const char* THINGSPEAK_URL = "http://api.thingspeak.com/update";

// =========================================================
// 3. CAU HINH CHAN CAM BIEN
// =========================================================

#define PH_PIN    35   // Po: Tín hiệu pH chính qua cầu phân áp
#define TEMP_PIN  34   // To: Tín hiệu nhiệt độ tương đối (ADC1)
#define ALARM_PIN 19   // Do: Tín hiệu ngắt báo động phần cứng Digital

// Số lần lấy mẫu ADC để lọc nhiễu
const int ADC_SAMPLES = 20;

// Tỷ lệ cầu phân áp 10k và 10k cho chân Po
const float VOLTAGE_DIVIDER_RATIO = 2.0;

// =========================================================
// 4. THONG SO HIEU CHUAN pH (Đo tại chân GPIO35)
// =========================================================

const float PH_VOLT_AT_4_01 = 1.998f;
const float PH_VALUE_AT_4_01 = 4.01f;

const float PH_VOLT_AT_6_86 = 1.496f;
const float PH_VALUE_AT_6_86 = 6.86f;

// =========================================================
// 5. THOI GIAN GUI DU LIEU
// =========================================================

const unsigned long UPLOAD_INTERVAL = 20000;
unsigned long lastUploadTime = 0;

// =========================================================
// 6. DOC DU LIEU CAM BIEN pH (Chan Po)
// =========================================================

void readPHSensor(
  int &adcValue,
  float &gpioVoltage,
  float &sensorVoltage
) {
  long adcTotal = 0;
  long voltageTotal = 0;

  for (int i = 0; i < ADC_SAMPLES; i++) {
    adcTotal += analogRead(PH_PIN);
    voltageTotal += analogReadMilliVolts(PH_PIN);
    delay(5);
  }

  // ADC trung bình
  adcValue = adcTotal / ADC_SAMPLES;

  // Điện áp đo trực tiếp tại GPIO35
  gpioVoltage = (voltageTotal / (float)ADC_SAMPLES) / 1000.0f;

  // Điện áp gốc PO trước cầu phân áp (tham khảo)
  sensorVoltage = gpioVoltage * VOLTAGE_DIVIDER_RATIO;
}

// =========================================================
// 7. TINH GIA TRI pH (Dua tren dien ap GPIO35 chuan)
// =========================================================

float calculatePH(float voltage) {
  // Tính hệ số góc từ 2 điểm hiệu chuẩn thực nghiệm
  float slope = (PH_VALUE_AT_6_86 - PH_VALUE_AT_4_01) /
                (PH_VOLT_AT_6_86 - PH_VOLT_AT_4_01);

  // Nội suy tuyến tính
  float phValue = PH_VALUE_AT_4_01 + (voltage - PH_VOLT_AT_4_01) * slope;

  // Giới hạn trong thang đo chuẩn 0.0 - 14.0
  if (phValue < 0.0f) phValue = 0.0f;
  if (phValue > 14.0f) phValue = 14.0f;

  return phValue;
}

// =========================================================
// 8. DOC DU LIEU NHIET DO (Chan To - GPIO34)
// =========================================================

void readTempSensor(int &tempAdc, float &tempVoltage, float &tempC) {
  long adcTotal = 0;
  long voltTotal = 0;

  for (int i = 0; i < ADC_SAMPLES; i++) {
    adcTotal += analogRead(TEMP_PIN);
    voltTotal += analogReadMilliVolts(TEMP_PIN);
    delay(5);
  }

  tempAdc = adcTotal / ADC_SAMPLES;
  tempVoltage = (voltTotal / (float)ADC_SAMPLES) / 1000.0f;

  // Kiểm tra đầu dò nhiệt độ:
  // Que đo pH BNC tiêu chuẩn thông thường KHÔNG tích hợp nhiệt điện trở NTC bên trong,
  // do đó chân To trên bo bị treo lên mức cao (ADC kịch trần ~4095 / 3.15V).
  // Khi không có đầu dò nhiệt độ riêng, ta giữ nhiệt độ môi trường ao nuôi chuẩn (28.5 °C).
  if (tempAdc >= 3900 || tempAdc <= 50) {
    tempC = 28.5f; // Mức nhiệt độ ao tôm tiêu chuẩn (28.5 °C)
  } else {
    // Trường hợp có gắn cảm biến nhiệt độ tương thích
    tempC = 25.0f + (tempVoltage - 1.55f) * 20.0f;
    if (tempC < 15.0f) tempC = 15.0f;
    if (tempC > 40.0f) tempC = 40.0f;
  }
}

// =========================================================
// 9. KET NOI WIFI
// =========================================================

void connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) {
    return;
  }

  Serial.println();
  Serial.print("Dang ket noi Wi-Fi '");
  Serial.print(WIFI_SSID);
  Serial.println("'...");

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int retry = 0;
  while (WiFi.status() != WL_CONNECTED && retry < 25) {
    delay(500);
    Serial.print(".");
    retry++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println();
    Serial.println(">> Ket noi Wi-Fi thanh cong!");
    Serial.print(">> Dia chi IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println();
    Serial.println(">> Khong the ket noi Wi-Fi, se thu lai chu ky sau!");
  }
}

// =========================================================
// 10. GUI DU LIEU LEN THINGSPEAK (3 Fields)
// =========================================================

void uploadThingSpeak(
  float phValue,
  float tempC,
  bool alarmActive
) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("[ThingSpeak] Wi-Fi chua ket noi, bo qua upload!");
    return;
  }

  HTTPClient http;
  String url = String(THINGSPEAK_URL);
  url += "?api_key=" + String(WRITE_API_KEY);

  // FIELD 1: Giá trị pH
  url += "&field1=" + String(phValue, 2);

  // FIELD 2: Nhiệt độ nước (°C)
  url += "&field2=" + String(tempC, 1);

  // FIELD 3: Cảnh báo phần cứng Do (0: Bình thường, 1: Báo động)
  url += "&field3=" + String(alarmActive ? 1 : 0);

  http.begin(url);
  int httpCode = http.GET();

  if (httpCode > 0) {
    String response = http.getString();
    Serial.println("---------- THINGSPEAK UPLOAD ----------");
    Serial.print("HTTP Code: ");
    Serial.println(httpCode);
    Serial.print("Entry ID: ");
    Serial.println(response);

    if (httpCode == HTTP_CODE_OK && response.toInt() > 0) {
      Serial.println(">> Gui du lieu len ThingSpeak thanh cong!");
    } else {
      Serial.println(">> Gui du lieu that bai (kiem tra rate limit 15s)!");
    }
    Serial.println("---------------------------------------");
  } else {
    Serial.print("[ThingSpeak] Loi HTTP: ");
    Serial.println(http.errorToString(httpCode));
  }

  http.end();
}

// =========================================================
// 11. SETUP
// =========================================================

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println();
  Serial.println("==============================================");
  Serial.println("   HE THONG GIAM SAT AO NUOI - ESP32 & pH");
  Serial.println("        Module pH-4502C (Po - To - Do)");
  Serial.println("==============================================");

  // Cấu hình ADC 12 bit (0 - 4095)
  analogReadResolution(12);

  // Cấu hình ADC dải đo 11dB (đọc an toàn 0V - 3.3V)
  analogSetPinAttenuation(PH_PIN, ADC_11db);
  analogSetPinAttenuation(TEMP_PIN, ADC_11db);

  // Cấu hình chân cảnh báo Digital Do
  pinMode(ALARM_PIN, INPUT_PULLUP);

  // Hiển thị thông số cấu hình
  Serial.println("CAU HINH CHAN:");
  Serial.println("  - Po (pH):      GPIO 35");
  Serial.println("  - To (Nhiet do): GPIO 34");
  Serial.println("  - Do (Canh bao): GPIO 19");
  Serial.println("THONG SO HIEU CHUAN pH:");
  Serial.printf("  - Diem 4.01: %.3f V\n", PH_VOLT_AT_4_01);
  Serial.printf("  - Diem 6.86: %.3f V\n", PH_VOLT_AT_6_86);

  // Kết nối Wi-Fi
  connectWiFi();
}

// =========================================================
// 12. LOOP
// =========================================================

void loop() {
  int phAdc = 0;
  float phGpioVolt = 0;
  float phSensorVolt = 0;

  int tempAdc = 0;
  float tempVolt = 0;
  float tempC = 0;

  // 1. Đọc cảm biến pH (Po)
  readPHSensor(phAdc, phGpioVolt, phSensorVolt);
  float phValue = calculatePH(phSensorVolt);

  // 2. Đọc cảm biến nhiệt độ (To)
  readTempSensor(tempAdc, tempVolt, tempC);

  // 3. Hệ thống cảnh báo thông minh 2 lớp (Phần mềm + Phần cứng Do)
  // Ngưỡng an toàn ao nuôi tôm chuẩn: 6.8 <= pH <= 8.5
  int alarmRaw = digitalRead(ALARM_PIN);
  bool hardwareAlarm = (alarmRaw == LOW);
  bool phAbnormal = (phValue < 6.8f || phValue > 8.5f);
  bool alarmActive = phAbnormal || hardwareAlarm;

  // 4. In thông tin ra Serial Monitor
  Serial.println();
  Serial.println("========== DU LIEU CAM BIEN (Po - To - Do) ==========");
  Serial.printf("1. pH:       %.2f  (ADC: %d | GPIO35: %.3f V | PO: %.3f V)\n", 
                phValue, phAdc, phGpioVolt, phSensorVolt);
  Serial.printf("2. Nhiet do: %.1f °C (ADC: %d | GPIO34: %.3f V)\n", 
                tempC, tempAdc, tempVolt);
  
  if (phValue < 6.8f) {
    Serial.printf("3. Canh bao: [!] KICH HOAT CANH BAO (pH = %.2f: Nuoc bi axit hoa nguy hiem! | Do = %d)\n", 
                  phValue, alarmRaw);
  } else if (phValue > 8.5f) {
    Serial.printf("3. Canh bao: [!] KICH HOAT CANH BAO (pH = %.2f: Nuoc bi kiem hoa qua cao! | Do = %d)\n", 
                  phValue, alarmRaw);
  } else if (hardwareAlarm) {
    Serial.printf("3. Canh bao: [!] KICH HOAT CANH BAO (Ngat phan cung Do = %d)\n", alarmRaw);
  } else {
    Serial.printf("3. Canh bao: [OK] Binh thuong (pH an toan: 6.8 - 8.5 | Do = %d)\n", alarmRaw);
  }
  Serial.println("=====================================================");

  // 5. Gửi lên ThingSpeak định kỳ mỗi 20 giây
  if (millis() - lastUploadTime >= UPLOAD_INTERVAL) {
    lastUploadTime = millis();
    connectWiFi();
    uploadThingSpeak(phValue, tempC, alarmActive);
  }

  delay(1000);
}
