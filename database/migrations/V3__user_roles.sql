-- V3: Add a safe default role for existing and newly registered accounts.
USE fish_pond_management;

ALTER TABLE users
    ADD COLUMN role VARCHAR(16) NOT NULL DEFAULT 'USER' AFTER status,
    ADD CONSTRAINT chk_users_role CHECK (role IN ('USER', 'ADMIN'));
