-- Select your SafeNation database before importing this additive update.
ALTER TABLE reports ADD COLUMN IF NOT EXISTS address VARCHAR(255) NOT NULL DEFAULT '';
ALTER TABLE assistance_requests ADD COLUMN IF NOT EXISTS address VARCHAR(255) NOT NULL DEFAULT '';
