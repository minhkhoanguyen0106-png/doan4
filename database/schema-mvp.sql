CREATE DATABASE IF NOT EXISTS fish_pond_management CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE fish_pond_management;

CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    email VARCHAR(254) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT chk_users_status CHECK (status IN ('ACTIVE', 'DISABLED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS ponds (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(120) NOT NULL,
    area_m2 DECIMAL(10,2) NOT NULL,
    depth_m DECIMAL(6,2) NOT NULL,
    fish_species VARCHAR(120) NULL,
    initial_fish_count INT UNSIGNED NULL,
    started_on DATE NULL,
    location VARCHAR(255) NULL,
    notes TEXT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY ix_ponds_user_status (user_id, status),
    CONSTRAINT fk_ponds_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT chk_ponds_area CHECK (area_m2 > 0),
    CONSTRAINT chk_ponds_depth CHECK (depth_m > 0),
    CONSTRAINT chk_ponds_status CHECK (status IN ('ACTIVE', 'INACTIVE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS fish_batches (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pond_id BIGINT UNSIGNED NOT NULL,
    fish_species VARCHAR(120) NOT NULL,
    stocked_count INT UNSIGNED NOT NULL,
    stocked_on DATE NOT NULL,
    source VARCHAR(255) NULL,
    notes TEXT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
    ended_on DATE NULL,
    harvested_count INT UNSIGNED NULL,
    harvest_weight_kg DECIMAL(12,3) NULL,
    active_pond_id BIGINT UNSIGNED GENERATED ALWAYS AS (CASE WHEN status = 'ACTIVE' THEN pond_id ELSE NULL END) STORED,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uq_fish_batches_one_active_per_pond (active_pond_id),
    KEY ix_fish_batches_pond_dates (pond_id, stocked_on, ended_on),
    CONSTRAINT fk_batches_pond FOREIGN KEY (pond_id) REFERENCES ponds(id) ON DELETE RESTRICT,
    CONSTRAINT chk_batches_status CHECK (status IN ('ACTIVE', 'COMPLETED')),
    CONSTRAINT chk_batches_dates CHECK (ended_on IS NULL OR ended_on >= stocked_on),
    CONSTRAINT chk_batches_completion CHECK (status <> 'COMPLETED' OR ended_on IS NOT NULL),
    CONSTRAINT chk_batches_harvest_weight CHECK (harvest_weight_kg IS NULL OR harvest_weight_kg >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS feeding_logs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    batch_id BIGINT UNSIGNED NOT NULL,
    fed_at DATETIME(3) NOT NULL,
    feed_type VARCHAR(120) NOT NULL,
    amount_kg DECIMAL(10,3) NOT NULL,
    feedings_count SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    notes TEXT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY ix_feeding_logs_batch_time (batch_id, fed_at),
    CONSTRAINT fk_feeding_batch FOREIGN KEY (batch_id) REFERENCES fish_batches(id) ON DELETE RESTRICT,
    CONSTRAINT chk_feeding_amount CHECK (amount_kg > 0),
    CONSTRAINT chk_feeding_count CHECK (feedings_count > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS water_change_logs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    batch_id BIGINT UNSIGNED NOT NULL,
    changed_at DATETIME(3) NOT NULL,
    changed_percent DECIMAL(5,2) NULL,
    method VARCHAR(120) NULL,
    reason VARCHAR(255) NULL,
    notes TEXT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY ix_water_change_logs_batch_time (batch_id, changed_at),
    CONSTRAINT fk_water_change_batch FOREIGN KEY (batch_id) REFERENCES fish_batches(id) ON DELETE RESTRICT,
    CONSTRAINT chk_water_change_percent CHECK (changed_percent IS NULL OR (changed_percent > 0 AND changed_percent <= 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS water_quality_records (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pond_id BIGINT UNSIGNED NOT NULL,
    batch_id BIGINT UNSIGNED NULL,
    measured_at DATETIME(3) NOT NULL,
    temperature_c DECIMAL(5,2) NULL,
    ph DECIMAL(4,2) NULL,
    dissolved_oxygen_mg_l DECIMAL(6,2) NULL,
    water_level_m DECIMAL(7,3) NULL,
    turbidity_ntu DECIMAL(8,2) NULL,
    source VARCHAR(16) NOT NULL DEFAULT 'MANUAL',
    notes TEXT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY ix_water_quality_pond_time (pond_id, measured_at),
    KEY ix_water_quality_batch_time (batch_id, measured_at),
    CONSTRAINT fk_water_quality_pond FOREIGN KEY (pond_id) REFERENCES ponds(id) ON DELETE RESTRICT,
    CONSTRAINT fk_water_quality_batch FOREIGN KEY (batch_id) REFERENCES fish_batches(id) ON DELETE RESTRICT,
    CONSTRAINT chk_water_quality_has_value CHECK (temperature_c IS NOT NULL OR ph IS NOT NULL OR dissolved_oxygen_mg_l IS NOT NULL OR water_level_m IS NOT NULL OR turbidity_ntu IS NOT NULL),
    CONSTRAINT chk_water_quality_ph CHECK (ph IS NULL OR (ph >= 0 AND ph <= 14)),
    CONSTRAINT chk_water_quality_do CHECK (dissolved_oxygen_mg_l IS NULL OR dissolved_oxygen_mg_l >= 0),
    CONSTRAINT chk_water_quality_level CHECK (water_level_m IS NULL OR water_level_m >= 0),
    CONSTRAINT chk_water_quality_turbidity CHECK (turbidity_ntu IS NULL OR turbidity_ntu >= 0),
    CONSTRAINT chk_water_quality_source CHECK (source IN ('MANUAL', 'IOT'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

