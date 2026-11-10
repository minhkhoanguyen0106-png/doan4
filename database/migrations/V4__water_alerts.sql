-- V4: Add alerts table for water quality exceeding thresholds and device offline notifications.
USE fish_pond_management;

CREATE TABLE IF NOT EXISTS water_alerts (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    site_id BIGINT UNSIGNED NOT NULL,
    device_id BIGINT UNSIGNED NULL,
    alert_type VARCHAR(32) NOT NULL,
    severity VARCHAR(16) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
    triggered_at DATETIME(3) NOT NULL,
    resolved_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY ix_water_alerts_site_status (site_id, status),
    KEY ix_water_alerts_triggered (triggered_at),
    CONSTRAINT fk_water_alerts_site FOREIGN KEY (site_id) REFERENCES monitoring_sites(id) ON DELETE CASCADE,
    CONSTRAINT fk_water_alerts_device FOREIGN KEY (device_id) REFERENCES iot_devices(id) ON DELETE SET NULL,
    CONSTRAINT chk_water_alerts_type CHECK (alert_type IN ('WATER_QUALITY', 'DEVICE_OFFLINE')),
    CONSTRAINT chk_water_alerts_severity CHECK (severity IN ('WATCH', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_water_alerts_status CHECK (status IN ('ACTIVE', 'RESOLVED', 'ACKNOWLEDGED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

