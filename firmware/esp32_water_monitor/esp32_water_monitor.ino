/*
 * =========================================================
 * DU AN: IOT GIAM SAT MOI TRUONG VA DINH DUONG CHO CAY OT
 * CAM BIEN: pH PH-4502C
 * VI DIEU KHIEN: ESP32 DEVKIT V1
 *
 * KET NOI:
 *   PO  -> Cau phan ap -> GPIO35 (D35)
 *   V+  -> Nguon 5V rieng
 *   GND -> GND chung
 *  
 *
 * THINGSPEAK:
 *   FIELD 1 = Gia tri pH
 *   FIELD 2 = Gia tri ADC tho
 *
 * HIEU CHUAN:
 *   pH 4.01 = 1.998 V
 *   pH 6.86 = 1.496 V
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

const char* WIFI_SSID = "OnePlus Ace 2 Pro f193";
const char* WIFI_PASSWORD = "thaochode";

// =========================================================
// 2. CAU HINH THINGSPEAK
// =========================================================

const char* WRITE_API_KEY = "8L8NJP5QT7UAE0IE";

const char* THINGSPEAK_URL =
  "http://api.thingspeak.com/update";

// =========================================================
// 3. CAU HINH CAM BIEN pH
// =========================================================

#define PH_PIN 35

// So lan lay mau ADC
const int ADC_SAMPLES = 20;

// Ty le cau phan ap 10k va 10k
const float VOLTAGE_DIVIDER_RATIO = 2.0;

// =========================================================




















// 4. THONG SO HIEU CHUAN pH
// =========================================================

// Diem hieu chuan thu nhat
const float PH_VOLT_AT_4_01 = 1.998f;
const float PH_VALUE_AT_4_01 = 4.01f;

// Diem hieu chuan thu hai
const float PH_VOLT_AT_6_86 = 1.496f;
const float PH_VALUE_AT_6_86 = 6.86f;

// =========================================================
// 5. THOI GIAN GUI DU LIEU
// =========================================================

const unsigned long UPLOAD_INTERVAL = 20000;

unsigned long lastUploadTime = 0;

// =========================================================
// 6. DOC DU LIEU CAM BIEN
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

    delay(10);
  }

  // Tinh ADC trung binh
  adcValue = adcTotal / ADC_SAMPLES;

  // Dien ap tai GPIO35
  gpioVoltage =
    (voltageTotal / (float)ADC_SAMPLES) / 1000.0f;

  // Khoi phuc dien ap PO truoc cau phan ap
  sensorVoltage =
    gpioVoltage * VOLTAGE_DIVIDER_RATIO;
}

// =========================================================
// 7. TINH GIA TRI pH
// =========================================================

float calculatePH(float sensorVoltage) {

  // Tinh he so goc tu hai diem hieu chuan
  float slope =
(PH_VALUE_AT_6_86 - PH_VALUE_AT_4_01) /
    (PH_VOLT_AT_6_86 - PH_VOLT_AT_4_01);

  // Noi suy tuyen tinh
  float phValue =
    PH_VALUE_AT_4_01 +
    (sensorVoltage - PH_VOLT_AT_4_01) * slope;

  return phValue;
}

// =========================================================
// 8. KET NOI WIFI
// =========================================================

void connectWiFi() {

  if (WiFi.status() == WL_CONNECTED) {
    return;
  }

  Serial.println();
  Serial.print("Dang ket noi Wi-Fi: ");
  Serial.println(WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.disconnect(true);
  delay(100);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int retry = 0;

  while (
    WiFi.status() != WL_CONNECTED &&
    retry < 30
  ) {

    delay(500);

    Serial.print(".");

    retry++;
  }

  if (WiFi.status() == WL_CONNECTED) {

    Serial.println();
    Serial.println("Ket noi Wi-Fi thanh cong!");

    Serial.print("Dia chi IP: ");
    Serial.println(WiFi.localIP());

  } else {

    Serial.println();
    Serial.print("Khong the ket noi Wi-Fi! Ma trang thai: ");
    Serial.println(WiFi.status());

    // Quet cac mang Wi-Fi 2.4GHz kha dung quanh day de chan doan
    Serial.println("Dang quet mang Wi-Fi 2.4GHz gan day...");
    int n = WiFi.scanNetworks();
    bool foundTarget = false;
    for (int i = 0; i < n; i++) {
      String ssid = WiFi.SSID(i);
      if (ssid == String(WIFI_SSID)) {
        foundTarget = true;
      }
      Serial.print("  - ");
      Serial.print(ssid);
      Serial.print(" (");
      Serial.print(WiFi.RSSI(i));
      Serial.println(" dBm)");
    }
    if (!foundTarget) {
      Serial.println(">> CANH BAO: ESP32 KHONG TIM THAY mang nay o bang tan 2.4GHz!");
      Serial.println(">> Nguyen nhan: Wi-Fi dang phat o bang tan 5GHz (ESP32 chi bat duoc 2.4GHz).");
      Serial.println(">> Cach sua: Chuyen diem phat sang 2.4GHz (hoac bat 'Toi da hoa tuong thich' tren iPhone).");
    } else {
      Serial.println(">> Tim thay mang 2.4GHz nhung ket noi that bai. Hay kiem tra lai mat khau WIFI_PASSWORD!");
    }
  }
}

// =========================================================
// 9. GUI DU LIEU LEN THINGSPEAK
// =========================================================

void uploadThingSpeak(
  int adcValue,
  float phValue
) {

  if (WiFi.status() != WL_CONNECTED) {

    Serial.println("Wi-Fi chua ket noi!");
    return;
  }

  HTTPClient http;

  String url = String(THINGSPEAK_URL);

  url += "?api_key=";
  url += WRITE_API_KEY;

  // FIELD 1: Gia tri pH
  url += "&field1=";
  url += String(phValue, 2);

  // FIELD 2: Gia tri ADC tho
  url += "&field2=";
  url += String(adcValue);

  http.begin(url);

  int httpCode = http.GET();

  if (httpCode > 0) {

    String response = http.getString();

    Serial.println();
    Serial.println("========== THINGSPEAK ==========");

    Serial.print("HTTP Code: ");
    Serial.println(httpCode);

    Serial.print("Entry ID: ");
    Serial.println(response);

    if (
      httpCode == HTTP_CODE_OK &&
      response.toInt() > 0
    ) {

      Serial.println("Gui du lieu thanh cong!");

    } else {

      Serial.println("Gui du lieu that bai!");
    }

  } else {

    Serial.print("Loi HTTP: ");
    Serial.println(http.errorToString(httpCode));
  }

  http.end();
}

// =========================================================
// SOFT SENSOR: TINH TOAN DOC TO % NH3 TU pH (APHA / EMERSON)
// =========================================================
float calculateToxicNH3Percent(float ph, float tempC = 28.0) {
  // Cong thuc Emerson tinh pKa theo nhiet do:
  float pKa = 0.09018 + (2729.92 / (273.15 + tempC));
  float nh3Pct = 100.0 / (1.0 + pow(10.0, (pKa - ph)));
  return nh3Pct;
}

// =========================================================
// 10. SETUP
// =========================================================

void setup() {

  Serial.begin(115200);

  delay(1000);

  Serial.println();
  Serial.println("==================================");
  Serial.println("     HE THONG GIAM SAT pH");
  Serial.println("          PH-4502C");
  Serial.println("==================================");

  // Cau hinh ADC 12 bit
  analogReadResolution(12);

  // Cau hinh ADC cho GPIO35
  analogSetPinAttenuation(
    PH_PIN,
    ADC_11db
  );

  // Hien thi thong tin hieu chuan
  Serial.println("THONG SO HIEU CHUAN:");

  Serial.print("pH 4.01: ");
  Serial.print(PH_VOLT_AT_4_01, 3);
  Serial.println(" V");

  Serial.print("pH 6.86: ");
  Serial.print(PH_VOLT_AT_6_86, 3);
  Serial.println(" V");

  // Ket noi Wi-Fi
connectWiFi();
}

// =========================================================
// 11. LOOP
// =========================================================

void loop() {

  int adcValue = 0;

  float gpioVoltage = 0;
  float sensorVoltage = 0;

  // Doc du lieu cam bien
  readPHSensor(
    adcValue,
    gpioVoltage,
    sensorVoltage
  );

  // Tinh gia tri pH
  float phValue = calculatePH(sensorVoltage);
  float toxicNH3Pct = calculateToxicNH3Percent(phValue, 28.0);

  // Hien thi du lieu
  Serial.println();
  Serial.println("========== DU LIEU CAM BIEN pH & SOFT SENSOR ==========");

  Serial.print("ADC tho: ");
  Serial.println(adcValue);

  Serial.print("Dien ap GPIO35: ");
  Serial.print(gpioVoltage, 3);
  Serial.println(" V");

  Serial.print("Dien ap PO: ");
  Serial.print(sensorVoltage, 3);
  Serial.println(" V");

  Serial.print("Gia tri pH: ");
  Serial.println(phValue, 2);

  Serial.print("Doc to NH3 (Soft Sensor): ");
  Serial.print(toxicNH3Pct, 2);
  Serial.println(" %");

  if (toxicNH3Pct > 10.0) {
    Serial.println(">> CANH BAO: Doc to NH3 vuot nguong (>10%)!");
  } else if (phValue < 7.5) {
    Serial.println(">> LUU Y: pH < 7.5 (nguy co doc to H2S, tom mem vo)!");
  } else {
    Serial.println(">> Nuoc dat nguong an toan.");
  }

  Serial.println("=======================================================");

  // Gui du lieu moi 20 giay
  if (
    millis() - lastUploadTime >= UPLOAD_INTERVAL
  ) {

    lastUploadTime = millis();

    // Kiem tra Wi-Fi
    connectWiFi();

    // Gui du lieu len ThingSpeak
    uploadThingSpeak(
      adcValue,
      phValue
    );
  }

  delay(1000);
}