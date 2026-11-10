USE fish_pond_management;

-- Replace this with an account created for local development before running this file.
SET @demo_email = 'replace-with-your-local-account-email';
SET @user_id = (SELECT id FROM users WHERE email = LOWER(TRIM(@demo_email)) LIMIT 1);

-- Inserts are scoped to that account and can be re-run without duplicating the demo pond/batch.
INSERT INTO ponds (user_id, name, area_m2, depth_m, fish_species, initial_fish_count, started_on, location, notes)
SELECT @user_id, 'Ao demo', 120.00, 1.50, 'Cá rô phi', 1000, CURRENT_DATE - INTERVAL 30 DAY, 'Khu A', 'Dữ liệu minh họa'
WHERE @user_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM ponds WHERE user_id = @user_id AND name = 'Ao demo');

SET @pond_id = (SELECT id FROM ponds WHERE user_id = @user_id AND name = 'Ao demo' LIMIT 1);

INSERT INTO fish_batches (pond_id, fish_species, stocked_count, stocked_on, source, notes)
SELECT @pond_id, 'Cá rô phi', 1000, CURRENT_DATE - INTERVAL 30 DAY, 'Trại giống địa phương', 'Đợt nuôi minh họa'
WHERE @pond_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM fish_batches WHERE pond_id = @pond_id AND status = 'ACTIVE');

SET @batch_id = (SELECT id FROM fish_batches WHERE pond_id = @pond_id AND status = 'ACTIVE' LIMIT 1);

INSERT INTO feeding_logs (batch_id, fed_at, feed_type, amount_kg, feedings_count, notes)
SELECT @batch_id, UTC_TIMESTAMP(3) - INTERVAL 1 HOUR, 'Thức ăn viên', 2.500, 2, 'Bữa sáng minh họa'
WHERE @batch_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM feeding_logs WHERE batch_id = @batch_id AND notes = 'Bữa sáng minh họa');

INSERT INTO water_change_logs (batch_id, changed_at, changed_percent, method, reason, notes)
SELECT @batch_id, UTC_TIMESTAMP(3) - INTERVAL 1 DAY, 10.00, 'Thay một phần', 'Vệ sinh định kỳ', 'Bản ghi minh họa'
WHERE @batch_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM water_change_logs WHERE batch_id = @batch_id AND notes = 'Bản ghi minh họa');

INSERT INTO water_quality_records (pond_id, batch_id, measured_at, temperature_c, ph, dissolved_oxygen_mg_l, water_level_m, turbidity_ntu, source, notes)
SELECT @pond_id, @batch_id, UTC_TIMESTAMP(3) - INTERVAL 1 HOUR, 27.50, 7.20, 5.80, 1.20, 18.00, 'MANUAL', 'Số đo minh họa'
WHERE @pond_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM water_quality_records WHERE pond_id = @pond_id AND notes = 'Số đo minh họa');

SELECT 'Ao demo' AS seeded_pond, @pond_id AS pond_id, @batch_id AS active_batch_id;
