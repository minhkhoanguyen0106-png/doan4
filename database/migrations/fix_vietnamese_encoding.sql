-- PONDORA Vietnamese UTF-8 Character Encoding & Sample Data Seeder
USE fish_pond_management;

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 1. Sửa cấu trúc bảng và default values
ALTER TABLE monitoring_sites 
    MODIFY COLUMN shrimp_species VARCHAR(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'Tôm thẻ chân trắng';

UPDATE monitoring_sites 
SET shrimp_species = 'Tôm thẻ chân trắng';

ALTER TABLE pond_feeding_logs
    MODIFY COLUMN feed_meal VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    MODIFY COLUMN feed_brand VARCHAR(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
    MODIFY COLUMN feed_tray_status VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'HẾT',
    MODIFY COLUMN notes TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL;

ALTER TABLE shrimp_health_logs
    MODIFY COLUMN health_status VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'KHỎE_MẠNH',
    MODIFY COLUMN gut_condition VARCHAR(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
    MODIFY COLUMN hepatopancreas VARCHAR(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
    MODIFY COLUMN shell_condition VARCHAR(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
    MODIFY COLUMN notes TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL;

ALTER TABLE pond_treatment_logs
    MODIFY COLUMN product_name VARCHAR(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    MODIFY COLUMN purpose VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
    MODIFY COLUMN notes TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL;

ALTER TABLE pond_water_operations
    MODIFY COLUMN water_source VARCHAR(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
    MODIFY COLUMN notes TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL;

-- 2. Xóa và làm mới dữ liệu mẫu hoàn toàn bằng UTF-8 chuẩn cho các ao
DELETE FROM pond_feeding_logs;
DELETE FROM shrimp_health_logs;
DELETE FROM pond_treatment_logs;
DELETE FROM pond_water_operations;

-- Dữ liệu mẫu cho từng ao: 2 (ao 1), 3 (nhà HHue), 4 (nhà Qlam), 5 (ao 2), 6 (nhà)
INSERT INTO pond_feeding_logs (site_id, fed_at, feed_meal, feed_brand, amount_kg, feed_tray_status, notes) VALUES
-- Ao 5 (ao 2)
(5, DATE_SUB(NOW(), INTERVAL 2 HOUR), 'Cữ 4 (18:30)', 'Grobest #2 (Protein 40%)', 28.0, 'HẾT', 'Kết thúc cữ chiều tối, kiểm tra vó sạch 100%'),
(5, DATE_SUB(NOW(), INTERVAL 6 HOUR), 'Cữ 3 (14:30)', 'Grobest #2 (Protein 40%)', 30.0, 'DƯ_DƯỚI_10%', 'Có mưa lác đác, giảm nhẹ lượng thức ăn'),
(5, DATE_SUB(NOW(), INTERVAL 10 HOUR), 'Cữ 2 (10:30)', 'Grobest #2 (Protein 40%)', 32.0, 'HẾT', 'Trời nắng đẹp, tôm bắt mồi nhanh, đường ruột căng đầy'),
(5, DATE_SUB(NOW(), INTERVAL 14 HOUR), 'Cữ 1 (06:00)', 'Grobest #2 (Protein 40%)', 26.0, 'HẾT', 'Cữ sáng đầu ngày, kiểm tra nhá sạch, tôm bung đuôi khỏe'),
(5, DATE_SUB(NOW(), INTERVAL 26 HOUR), 'Cữ 4 (18:30)', 'Grobest #2 (Protein 40%)', 27.5, 'HẾT', 'Bật quạt nước 100% trước khi cho ăn'),
(5, DATE_SUB(NOW(), INTERVAL 30 HOUR), 'Cữ 3 (14:30)', 'Grobest #2 (Protein 40%)', 30.0, 'HẾT', 'Tôm lột xác nhiều, bổ sung men vi sinh đường ruột'),
(5, DATE_SUB(NOW(), INTERVAL 34 HOUR), 'Cữ 2 (10:30)', 'Grobest #2 (Protein 40%)', 31.0, 'HẾT', 'Thời tiết tốt, chất thải gom tụ vào rốn ao'),
(5, DATE_SUB(NOW(), INTERVAL 38 HOUR), 'Cữ 1 (06:00)', 'Grobest #2 (Protein 40%)', 25.0, 'HẾT', 'Tôm bơi lội mạnh, phản xạ quạt nước rất nhạy'),

-- Ao 2 (ao 1)
(2, DATE_SUB(NOW(), INTERVAL 2 HOUR), 'Cữ 4 (18:30)', 'Grobest #2 (Protein 40%)', 25.0, 'HẾT', 'Kết thúc cữ chiều tối, kiểm tra vó sạch 100%'),
(2, DATE_SUB(NOW(), INTERVAL 6 HOUR), 'Cữ 3 (14:30)', 'Grobest #2 (Protein 40%)', 28.0, 'HẾT', 'Ăn tốt, đường ruột to màu thức ăn đồng đều'),
(2, DATE_SUB(NOW(), INTERVAL 10 HOUR), 'Cữ 2 (10:30)', 'Grobest #2 (Protein 40%)', 30.0, 'HẾT', 'Trời nắng đẹp, tôm bơi lội bắt mồi nhanh'),
(2, DATE_SUB(NOW(), INTERVAL 14 HOUR), 'Cữ 1 (06:00)', 'Grobest #2 (Protein 40%)', 24.0, 'HẾT', 'Cữ sáng đầu ngày, kiểm tra vó sạch hoàn toàn'),

-- Ao 3 (nhà HHue)
(3, DATE_SUB(NOW(), INTERVAL 2 HOUR), 'Cữ 4 (18:30)', 'CP Extra #3 (Protein 42%)', 22.0, 'HẾT', 'Kiểm tra nhá ăn sạch 100%'),
(3, DATE_SUB(NOW(), INTERVAL 6 HOUR), 'Cữ 3 (14:30)', 'CP Extra #3 (Protein 42%)', 25.0, 'HẾT', 'Tôm ăn mạnh, bung đuôi khỏe'),
(3, DATE_SUB(NOW(), INTERVAL 10 HOUR), 'Cữ 2 (10:30)', 'CP Extra #3 (Protein 42%)', 26.0, 'HẾT', 'Đường ruột to đậm, màu gan nâu đen'),
(3, DATE_SUB(NOW(), INTERVAL 14 HOUR), 'Cữ 1 (06:00)', 'CP Extra #3 (Protein 42%)', 20.0, 'HẾT', 'Cữ sáng đầu ngày, tôm phản xạ nhạy'),

-- Ao 4 (nhà Qlam)
(4, DATE_SUB(NOW(), INTERVAL 2 HOUR), 'Cữ 4 (18:30)', 'Grobest #2 (Protein 40%)', 27.0, 'HẾT', 'Kiểm tra vó sạch, tôm khỏe mạnh'),
(4, DATE_SUB(NOW(), INTERVAL 6 HOUR), 'Cữ 3 (14:30)', 'Grobest #2 (Protein 40%)', 29.0, 'DƯ_DƯỚI_10%', 'Dư nhẹ 5% do tôm bắt đầu chu kỳ lột vỏ'),
(4, DATE_SUB(NOW(), INTERVAL 10 HOUR), 'Cữ 2 (10:30)', 'Grobest #2 (Protein 40%)', 30.0, 'HẾT', 'Trời nắng trong, tôm vận động tích cực'),
(4, DATE_SUB(NOW(), INTERVAL 14 HOUR), 'Cữ 1 (06:00)', 'Grobest #2 (Protein 40%)', 25.0, 'HẾT', 'Cữ sáng đầu ngày, nhá ăn sạch sẽ');

-- Sức khỏe tôm
INSERT INTO shrimp_health_logs (site_id, logged_at, age_days, average_weight_g, estimated_survival_rate, health_status, gut_condition, hepatopancreas, shell_condition, notes) VALUES
(5, DATE_SUB(NOW(), INTERVAL 4 HOUR), 28, 12.50, 88.50, 'KHỎE_MẠNH', 'Đầy thức ăn, ruột không đứt đoạn', 'Màu nâu đen màng bọc rõ ràng', 'Cứng bóng, không đóng rong bám nhớt', 'Tăng trưởng đạt chuẩn vượt 5% so với biểu mẫu kỹ thuật'),
(5, DATE_SUB(NOW(), INTERVAL 28 HOUR), 27, 11.80, 89.00, 'KHỎE_MẠNH', 'Ruột to màu thức ăn đồng đều', 'Đậm màu, tiết dịch dịch tụy tốt', 'Bóng sáng, vỏ cứng đều', 'Tôm vận động tích cực, phản xạ nhạy khi có ánh đèn'),
(2, DATE_SUB(NOW(), INTERVAL 4 HOUR), 25, 11.20, 89.50, 'KHỎE_MẠNH', 'Ruột đầy đặn, phân thành chuỗi', 'Nâu đen màng bọc rõ', 'Vỏ cứng sáng bóng', 'Tôm thích nghi rất tốt với độ mặn ao nuôi'),
(3, DATE_SUB(NOW(), INTERVAL 4 HOUR), 26, 11.60, 88.00, 'KHỎE_MẠNH', 'Đầy thức ăn 100%', 'Màu nâu đen đều', 'Vỏ sạch bóng', 'Tỷ lệ sống ước tính trên 88%, sức khỏe ổn định'),
(4, DATE_SUB(NOW(), INTERVAL 4 HOUR), 27, 12.10, 87.50, 'KHỎE_MẠNH', 'Ruột đầy, gan tụy săn chắc', 'Nâu sẫm bình thường', 'Vỏ cứng bóng', 'Cần tăng cường bổ sung khoáng kích lột vỏ ban đêm');

-- Xử lý hóa chất / Chế phẩm ao
INSERT INTO pond_treatment_logs (site_id, treated_at, treatment_type, product_name, dosage, unit, purpose, notes) VALUES
(5, DATE_SUB(NOW(), INTERVAL 8 HOUR), 'MEN_VI_SINH', 'Men vi sinh Bio-BZT USA', 2.0, 'gói', 'Cấy men vi sinh phân hủy mùn bã hữu cơ đáy', 'Ủ vi sinh với mật rỉ đường 6 tiếng trước khi tạt đều khắp mặt ao lúc 9h sáng'),
(5, DATE_SUB(NOW(), INTERVAL 20 HOUR), 'KHOANG_CHAT', 'Khoáng tạt Calciphor Plus', 15.0, 'kg', 'Cung cấp Ca, Mg, K kích thích tôm lột xác đồng loạt', 'Tạt đều khu vực luồng quạt nước lúc 21h đêm'),
(5, DATE_SUB(NOW(), INTERVAL 44 HOUR), 'VOI_NONG_NGHIEP', 'Vôi Canxi CaCO3', 50.0, 'kg', 'Tăng độ kiềm và ổn định hệ đệm pH ao', 'Hòa tan nước xả đều khắp mặt ao sau cơn mưa giông'),
(2, DATE_SUB(NOW(), INTERVAL 8 HOUR), 'MEN_VI_SINH', 'Men vi sinh Bio-BZT USA', 2.0, 'gói', 'Cấy men vi sinh phân hủy mùn bã hữu cơ đáy', 'Ủ vi sinh với mật rỉ đường 6 tiếng trước khi tạt'),
(3, DATE_SUB(NOW(), INTERVAL 8 HOUR), 'KHOANG_CHAT', 'Khoáng Calciphor Plus', 12.0, 'kg', 'Bổ sung khoáng kích lột xác', 'Tạt quanh giàn quạt lúc 20h đêm');

-- Hoạt động nước & Xifong
INSERT INTO pond_water_operations (site_id, operated_at, operation_type, volume_m3, water_source, notes) VALUES
(5, DATE_SUB(NOW(), INTERVAL 12 HOUR), 'XIFONG_DAY', 0.0, 'Hố xifong trung tâm', 'Xifong hút vỏ lột và mùn bã đáy ao trong 45 phút, nước xả ra trong'),
(5, DATE_SUB(NOW(), INTERVAL 36 HOUR), 'THAY_NUOC', 150.0, 'Ao lắng đã xử lý KMnO4', 'Thay 15% nước tầng mặt để kích thích tôm thay vỏ'),
(5, DATE_SUB(NOW(), INTERVAL 60 HOUR), 'CAP_NUOC_MOI', 100.0, 'Ao lắng tuần hoàn', 'Cấp bù 10cm nước bù lượng bốc hơi và xifong'),
(2, DATE_SUB(NOW(), INTERVAL 12 HOUR), 'XIFONG_DAY', 0.0, 'Hố xifong trung tâm', 'Xifong định kỳ hàng ngày lúc sáng sớm trước cữ ăn 1'),
(3, DATE_SUB(NOW(), INTERVAL 12 HOUR), 'XIFONG_DAY', 0.0, 'Hố xifong trung tâm', 'Xifong hút phân và thức ăn dư thừa');
