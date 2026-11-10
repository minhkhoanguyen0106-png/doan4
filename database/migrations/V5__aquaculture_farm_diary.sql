-- V5: Aquaculture Farm Diary - Digital Pond Profile, Feeding, Shrimp Health, Treatments & Water Operations
USE fish_pond_management;

-- 1. Thêm các thuộc tính số hóa ao nuôi vào monitoring_sites
ALTER TABLE monitoring_sites
    ADD COLUMN area_m2 DECIMAL(10,2) NULL DEFAULT 1000.00,
    ADD COLUMN depth_m DECIMAL(6,2) NULL DEFAULT 1.50,
    ADD COLUMN shrimp_species VARCHAR(120) NULL DEFAULT 'Tôm thẻ chân trắng',
    ADD COLUMN stocked_count INT UNSIGNED NULL DEFAULT 100000,
    ADD COLUMN stocked_on DATE NULL,
    ADD COLUMN farming_stage VARCHAR(64) NULL DEFAULT 'GIAI_DOAN_1',
    ADD COLUMN target_harvest_weight_g DECIMAL(6,2) NULL DEFAULT 25.00;

-- Cập nhật dữ liệu mặc định cho các ao đang có nếu chưa có stocked_on
UPDATE monitoring_sites 
SET stocked_on = DATE_SUB(CURDATE(), INTERVAL 25 DAY), 
    area_m2 = COALESCE(area_m2, 1000.00),
    depth_m = COALESCE(depth_m, 1.50),
    shrimp_species = COALESCE(shrimp_species, 'Tôm thẻ chân trắng'),
    stocked_count = COALESCE(stocked_count, 100000)
WHERE stocked_on IS NULL;

-- 2. Bảng nhật ký cho ăn chi tiết theo cữ
CREATE TABLE IF NOT EXISTS pond_feeding_logs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    site_id BIGINT UNSIGNED NOT NULL,
    fed_at DATETIME(3) NOT NULL,
    feed_meal VARCHAR(64) NOT NULL,
    feed_brand VARCHAR(120) NULL,
    amount_kg DECIMAL(8,2) NOT NULL,
    feed_tray_status VARCHAR(64) NOT NULL DEFAULT 'HẾT',
    notes TEXT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY ix_feeding_site_fed_at (site_id, fed_at),
    CONSTRAINT fk_feeding_site FOREIGN KEY (site_id) REFERENCES monitoring_sites(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3. Bảng nhật ký theo dõi tình trạng tôm và tăng trưởng
CREATE TABLE IF NOT EXISTS shrimp_health_logs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    site_id BIGINT UNSIGNED NOT NULL,
    logged_at DATETIME(3) NOT NULL,
    age_days INT UNSIGNED NULL,
    average_weight_g DECIMAL(8,2) NOT NULL,
    estimated_survival_rate DECIMAL(5,2) NULL DEFAULT 85.00,
    health_status VARCHAR(64) NOT NULL DEFAULT 'KHỎE_MẠNH',
    gut_condition VARCHAR(120) NULL,
    hepatopancreas VARCHAR(120) NULL,
    shell_condition VARCHAR(120) NULL,
    notes TEXT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY ix_health_site_logged_at (site_id, logged_at),
    CONSTRAINT fk_health_site FOREIGN KEY (site_id) REFERENCES monitoring_sites(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. Bảng nhật ký xử lý ao: Dùng thuốc, hóa chất, vi sinh, khoáng, vôi
CREATE TABLE IF NOT EXISTS pond_treatment_logs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    site_id BIGINT UNSIGNED NOT NULL,
    treated_at DATETIME(3) NOT NULL,
    treatment_type VARCHAR(64) NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    dosage DECIMAL(8,2) NOT NULL,
    unit VARCHAR(32) NOT NULL DEFAULT 'kg',
    purpose VARCHAR(255) NULL,
    notes TEXT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY ix_treatment_site_treated_at (site_id, treated_at),
    CONSTRAINT fk_treatment_site FOREIGN KEY (site_id) REFERENCES monitoring_sites(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5. Bảng nhật ký hoạt động thay nước và xifong đáy
CREATE TABLE IF NOT EXISTS pond_water_operations (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    site_id BIGINT UNSIGNED NOT NULL,
    operated_at DATETIME(3) NOT NULL,
    operation_type VARCHAR(64) NOT NULL,
    volume_m3 DECIMAL(8,2) NULL,
    water_source VARCHAR(120) NULL,
    notes TEXT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY ix_water_op_site_operated (site_id, operated_at),
    CONSTRAINT fk_water_op_site FOREIGN KEY (site_id) REFERENCES monitoring_sites(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
