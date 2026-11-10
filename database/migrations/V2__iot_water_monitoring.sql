-- V2: Add IoT water monitoring tables. Apply after database/schema-mvp.sql.
-- This migration is additive: legacy pond tables and existing user accounts remain intact.
USE fish_pond_management;

CREATE TABLE monitoring_sites (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(120) NOT NULL,
    location VARCHAR(255) NULL,
    timezone VARCHAR(64) NOT NULL DEFAULT 'Asia/Ho_Chi_Minh',
    notes TEXT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY ix_monitoring_sites_user_status (user_id, status),
    CONSTRAINT fk_monitoring_sites_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT chk_monitoring_sites_status CHECK (status IN ('ACTIVE', 'INACTIVE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE iot_devices (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    site_id BIGINT UNSIGNED NOT NULL,
    device_code VARCHAR(64) NOT NULL,
    name VARCHAR(120) NOT NULL,
    token_hash VARCHAR(100) NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
    last_seen_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT uq_iot_devices_code UNIQUE (device_code),
    KEY ix_iot_devices_site_status (site_id, status),
    CONSTRAINT fk_iot_devices_site FOREIGN KEY (site_id) REFERENCES monitoring_sites(id) ON DELETE RESTRICT,
    CONSTRAINT chk_iot_devices_status CHECK (status IN ('ACTIVE', 'DISABLED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE water_measurements (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    device_id BIGINT UNSIGNED NOT NULL,
    message_id VARCHAR(100) NOT NULL,
    measured_at DATETIME(3) NOT NULL,
    received_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    temperature_c DECIMAL(5,2) NULL,
    ph DECIMAL(4,2) NULL,
    dissolved_oxygen_mg_l DECIMAL(6,2) NULL,
    turbidity_ntu DECIMAL(8,2) NULL,
    tds_mg_l DECIMAL(8,2) NULL,
    quality_status VARCHAR(24) NOT NULL DEFAULT 'VALID',
    assessment_level VARCHAR(24) NOT NULL,
    threshold_version INT NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    CONSTRAINT uq_measurement_device_message UNIQUE (device_id, message_id),
    KEY ix_measurement_device_time (device_id, measured_at),
    CONSTRAINT fk_measurement_device FOREIGN KEY (device_id) REFERENCES iot_devices(id) ON DELETE RESTRICT,
    CONSTRAINT chk_measurement_has_value CHECK (temperature_c IS NOT NULL OR ph IS NOT NULL OR dissolved_oxygen_mg_l IS NOT NULL OR turbidity_ntu IS NOT NULL OR tds_mg_l IS NOT NULL),
    CONSTRAINT chk_measurement_ph CHECK (ph IS NULL OR (ph >= 0 AND ph <= 14)),
    CONSTRAINT chk_measurement_do CHECK (dissolved_oxygen_mg_l IS NULL OR dissolved_oxygen_mg_l >= 0),
    CONSTRAINT chk_measurement_turbidity CHECK (turbidity_ntu IS NULL OR turbidity_ntu >= 0),
    CONSTRAINT chk_measurement_tds CHECK (tds_mg_l IS NULL OR tds_mg_l >= 0),
    CONSTRAINT chk_measurement_quality CHECK (quality_status IN ('VALID', 'SENSOR_ERROR', 'OUT_OF_RANGE')),
    CONSTRAINT chk_measurement_assessment CHECK (assessment_level IN ('GOOD', 'WATCH', 'HIGH', 'CRITICAL', 'INSUFFICIENT_DATA'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE daily_water_summaries (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    site_id BIGINT UNSIGNED NOT NULL,
    local_date DATE NOT NULL,
    valid_sample_count BIGINT NOT NULL,
    screening_level VARCHAR(24) NOT NULL,
    threshold_version INT NOT NULL,
    aggregates_json JSON NOT NULL,
    updated_at DATETIME(3) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT uq_daily_summary_site_date_version UNIQUE (site_id, local_date, threshold_version),
    KEY ix_daily_summary_date (site_id, local_date),
    CONSTRAINT fk_daily_summary_site FOREIGN KEY (site_id) REFERENCES monitoring_sites(id) ON DELETE RESTRICT,
    CONSTRAINT chk_daily_summary_level CHECK (screening_level IN ('GOOD', 'WATCH', 'HIGH', 'CRITICAL', 'INSUFFICIENT_DATA'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
