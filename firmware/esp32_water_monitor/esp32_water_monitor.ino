/*
 * =========================================================
 * DU AN: HE THONG IOT QUAN TRAC CHAT LUONG NUOC AO NUOI TOM
 * PHAN MEM: PONDORA SMART AQUACULTURE
 * 
 * TINH NANG NANG CAO (EDGE SIGNAL PROCESSING & SOFT SENSOR):
 *   1. Edge Signal Processing:
 *      - Bo loc trung vi (Truncated Median Filter 15 mau, loai 3 min, 3 max)
 *      - Triet tieu xung nhieu dien ap ADC & bot khi bam que do
 *      - Tinh dao ham toc do bien thien pH theo thoi gian (dpH/dt)
 *   2. Soft Sensor (Cam bien mem tinh khi doc NH3 tu do):
 *      - Ap dung mo hinh can bang hoa ly Emerson:
 *        % NH3 = 100% / (1 + 10^(9.25 - pH))
 *      - Du bao doc to NH3 thoi gian thuc ma khong can cam bien dat tien
 *
 * KET NOI PHAN CUNG:
 *   Po  -> Cau phan ap 10k:10k -> GPIO35 (D35)
 *   V+  -> Nguon 5V
 *   GND -> GND chung
 *
 * THINGSPEAK:
 *   FIELD 1 = pH da loc trung vi (pH thuc te)
 *   FIELD 2 = % Khi doc NH3 tu do (Soft Sensor)
 *   FIELD 3 = Canh bao he thong (0: An toan, 1: Canh bao)
 *
 * HIEU CHUAN pH:
 *   pH 4.01 = 1.998 V
 *   pH 6.86 = 1.496 V
 * =========================================================
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <math.h>

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
// 3. CAU HINH CAM BIEN pH
// =========================================================

#define PH_PIN 35

// Tỷ lệ cầu phân áp 10k và 10k
const float VOLTAGE_DIVIDER_RATIO = 2.0;

// Thông số hiệu chuẩn chuẩn của bạn
const float PH_VOLT_AT_4_01 = 1.998f;
const float PH_VALUE_AT_4_01 = 4.01f;

const float PH_VOLT_AT_6_86 = 1.496f;
const float PH_VALUE_AT_6_86 = 6.86f;

// Chu kỳ gửi dữ liệu lên Cloud: 20 giây
const unsigned long UPLOAD_INTERVAL = 20000;
unsigned long lastUploadTime = 0;

// Biến lưu vết theo dõi tốc độ biến thiên pH (dpH/dt)
float previousPH = -1.0f;
unsigned long previousPHTime = 0;
float phVelocityPerHour = 0.0f; // Đơn vị: delta pH / giờ

// =========================================================
// 4. EDGE PROCESSING: BO LOC TRUNG VI (TRUNCATED MEDIAN FILTER)
// =========================================================

void readPHSensorEdgeFiltered(int &adcFiltered, float &gpioVoltage, float &sensorVoltage) {
  const int SAMPLES = 15;
  int rawAdc[SAMPLES];
  int rawMv[SAMPLES];

  // Đọc liên tiếp 15 mẫu
  for (int i = 0; i < SAMPLES; i++) {
    rawAdc[i] = analogRead(PH_PIN);
    rawMv[i] = analogReadMilliVolts(PH_PIN);
    delay(8);
  }

  // Sắp xếp tăng dần (Bubble sort)
  for (int i = 0; i < SAMPLES - 1; i++) {
    for (int j = i + 1; j < SAMPLES; j++) {
      if (rawAdc[i] > rawAdc[j]) {
        int t = rawAdc[i]; rawAdc[i] = rawAdc[j]; rawAdc[j] = t;
      }
      if (rawMv[i] > rawMv[j]) {
        int t = rawMv[i]; rawMv[i] = rawMv[j]; rawMv[j] = t;
      }
    }
  }

  // Loại bỏ 3 mẫu nhỏ nhất (xung âm, bọt khí) và 3 mẫu lớn nhất (nhiễu xung đỉnh)
  // Lấy trung bình cộng 9 mẫu ổn định ở giữa
  long sumAdc = 0;
  long sumMv = 0;
  for (int i = 3; i < 12; i++) {
    sumAdc += rawAdc[i];
    sumMv += rawMv[i];
  }

  adcFiltered = sumAdc / 9;
  gpioVoltage = (sumMv / 9.0f) / 1000.0f;
  sensorVoltage = gpioVoltage * VOLTAGE_DIVIDER_RATIO;
}

// =========================================================
// 5. TINH TOAN GIA TRI pH TUYEN TINH
// =========================================================

float calculatePH(float sensorVoltage) {
  float slope = (PH_VALUE_AT_6_86 - PH_VALUE_AT_4_01) /
                (PH_VOLT_AT_6_86 - PH_VOLT_AT_4_01);

  float phValue = PH_VALUE_AT_4_01 + (sensorVoltage - PH_VOLT_AT_4_01) * slope;

  if (phValue < 0.0f) phValue = 0.0f;
  if (phValue > 14.0f) phValue = 14.0f;

  return phValue;
}

// =========================================================
// 6. SOFT SENSOR: TINH TY LE KHI DOC NH3 THEO CONG THUC EMERSON
// =========================================================

float calculateToxicNH3Percent(float ph) {
  // pKa của hệ Amoniac ở điều kiện nhiệt độ ao nuôi ~28°C là 9.25
  // Công thức: % NH3 = 100 / (1 + 10^(9.25 - pH))
  float exponent = 9.25f - ph;
  float denominator = 1.0f + pow(10.0f, exponent);
  float toxicNH3 = 100.0f / denominator;
  return toxicNH3;
}

// =========================================================
// 7. TINH DAO HAM TOC DO BIEN THIEN pH (dpH/dt)
// =========================================================

void updatePHRateOfChange(float currentPH) {
  unsigned long now = millis();
  if (previousPH < 0.0f) {
    previousPH = currentPH;
    previousPHTime = now;
    return;
  }

  float elapsedHours = (now - previousPHTime) / 3600000.0f;
  // Cập nhật sau mỗi chu kỳ ít nhất 15 giây
  if (elapsedHours >= (15.0f / 3600.0f)) {
    phVelocityPerHour = (currentPH - previousPH) / elapsedHours;
    previousPH = currentPH;
    previousPHTime = now;
  }
}

// =========================================================
// 8. KET NOI WIFI
// =========================================================

void connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) return;

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
    Serial.println("\n>> Ket noi Wi-Fi thanh cong!");
    Serial.print(">> Dia chi IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n>> Khong the ket noi Wi-Fi!");
  }
}

// =========================================================
// 9. GUI DU LIEU LEN THINGSPEAK (pH, % NH3, Alert)
// =========================================================

void uploadThingSpeak(float phValue, float nh3Percent, bool isAlarm) {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  String url = String(THINGSPEAK_URL);
  url += "?api_key=" + String(WRITE_API_KEY);

  // FIELD 1: pH đã lọc
  url += "&field1=" + String(phValue, 2);

  // FIELD 2: % Khí độc NH3 (Soft Sensor)
  url += "&field2=" + String(nh3Percent, 2);

  // FIELD 3: Cảnh báo chất lượng nước
  url += "&field3=" + String(isAlarm ? 1 : 0);

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
      Serial.println(">> Gui len ThingSpeak thanh cong! (Field 1: pH, Field 2: % NH3)");
    }
    Serial.println("---------------------------------------");
  }
  http.end();
}

// =========================================================
// 10. SETUP
// =========================================================

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println();
  Serial.println("==========================================================");
  Serial.println("   HE THONG GIAM SAT AO NUOI - PONDORA SMART AQUACULTURE");
  Serial.println("   TICH HOP: EDGE SIGNAL FILTERING & SOFT SENSOR NH3");
  Serial.println("==========================================================");

  analogReadResolution(12);
  analogSetPinAttenuation(PH_PIN, ADC_11db);

  connectWiFi();
}

// =========================================================
// 11. LOOP
// =========================================================

void loop() {
  int adcFiltered = 0;
  float gpioVoltage = 0;
  float sensorVoltage = 0;

  // 1. Đọc và lọc tín hiệu bằng bộ lọc trung vị (Median Filter + SMA)
  readPHSensorEdgeFiltered(adcFiltered, gpioVoltage, sensorVoltage);
  float phValue = calculatePH(sensorVoltage);

  // 2. Soft Sensor: Tính tỷ lệ % khí độc Amonia (NH3)
  float nh3Percent = calculateToxicNH3Percent(phValue);

  // 3. Tính đạo hàm tốc độ biến thiên pH (dpH/dt)
  updatePHRateOfChange(phValue);

  // 4. Nhận diện các kịch bản bất thường trong ao nuôi
  bool isAcidShock = (phValue < 6.8f);
  bool isToxicNH3 = (nh3Percent > 5.0f || phValue > 8.5f);
  bool isAlgaeCrash = (phVelocityPerHour < -0.5f); // Tụt nhanh hơn 0.5 pH / giờ
  bool isAlarm = isAcidShock || isToxicNH3 || isAlgaeCrash;

  // 5. In báo cáo ra Serial Monitor
  Serial.println();
  Serial.println("========== PONDORA EDGE AI & SOFT SENSOR ==========");
  Serial.printf("1. pH (Median Filter): %.2f  (PO: %.3f V | ADC: %d)\n", 
                phValue, sensorVoltage, adcFiltered);
  Serial.printf("2. Soft Sensor NH3:    %.2f %%  [%s]\n", 
                nh3Percent, 
                nh3Percent < 2.0f ? "An toan" : (nh3Percent < 5.0f ? "Canh giac" : "NGUY HIEM: DOC TO CAO"));
  Serial.printf("3. Bien thien dpH/dt:  %+.2f pH/gio  [%s]\n", 
                phVelocityPerHour, 
                fabs(phVelocityPerHour) < 0.3f ? "On dinh" : (phVelocityPerHour < -0.5f ? "CANH BAO: SUP TAO/AXIT" : "Dang tang"));
  
  if (isAcidShock) {
    Serial.printf("4. Danh gia ao:        [!] NGUY CAP: Nuoc bi chua/axit hoa (pH = %.2f)\n", phValue);
  } else if (isToxicNH3) {
    Serial.printf("4. Danh gia ao:        [!] NGUY CAP: Khi doc NH3 boc phat manh (%.2f %%) gay chet tom!\n", nh3Percent);
  } else if (isAlgaeCrash) {
    Serial.println("4. Danh gia ao:        [!] CANH BAO SOM: Toc do tut pH cao (Hien tuong sup tao)!");
  } else {
    Serial.println("4. Danh gia ao:        [OK] AN TOAN - Moi truong nuoc ly tuong cho tom");
  }
  Serial.println("===================================================");

  // 6. Gửi lên ThingSpeak định kỳ 20 giây
  if (millis() - lastUploadTime >= UPLOAD_INTERVAL) {
    lastUploadTime = millis();
    connectWiFi();
    uploadThingSpeak(phValue, nh3Percent, isAlarm);
  }

  delay(1000);
}
