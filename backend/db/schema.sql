-- =============================================================
-- Public Allegation Portal - database schema
-- Rebuilt from the queries in backend/server.js.
-- Works on MySQL 8, MariaDB 10.5+ and TiDB Cloud.
--
-- Usage:  mysql -h HOST -P PORT -u USER -p DB_NAME < db/schema.sql
-- =============================================================

SET NAMES utf8mb4;

-- Drop in reverse dependency order so the script can be re-run
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS complaint_edits;
DROP TABLE IF EXISTS complaint_votes;
DROP TABLE IF EXISTS complaints;
DROP TABLE IF EXISTS banned_users;
DROP TABLE IF EXISTS user_organizations;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS organizations;

-- -------------------------------------------------------------
-- Organizations (they also log in, so they have a password)
-- -------------------------------------------------------------
CREATE TABLE organizations (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name         VARCHAR(150) NOT NULL,
  slug         VARCHAR(160) NOT NULL,
  email        VARCHAR(190) NOT NULL,
  password     VARCHAR(255) NOT NULL,              -- bcrypt hash
  address      VARCHAR(255) NULL,
  description  TEXT NULL,
  access_type  ENUM('Public','Private') NOT NULL DEFAULT 'Public',
  logo         VARCHAR(500) NULL,                  -- full URL (Cloudinary) or /uploads/...
  status       ENUM('active','inactive') NOT NULL DEFAULT 'active',
  createdAt    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_org_name (name),
  UNIQUE KEY uq_org_slug (slug),
  UNIQUE KEY uq_org_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Users (citizens / members who file complaints)
-- -------------------------------------------------------------
CREATE TABLE users (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name         VARCHAR(150) NOT NULL,
  email        VARCHAR(190) NOT NULL,
  password     VARCHAR(255) NOT NULL,              -- bcrypt hash
  address      VARCHAR(255) NULL,
  description  TEXT NULL,
  createdAt    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Which users belong to which organizations
-- -------------------------------------------------------------
CREATE TABLE user_organizations (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id      INT UNSIGNED NOT NULL,
  org_id       INT UNSIGNED NOT NULL,
  role_code    VARCHAR(30) NOT NULL DEFAULT 'member',
  createdAt    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_org (user_id, org_id),        -- needed by INSERT IGNORE
  KEY idx_uo_org (org_id),
  CONSTRAINT fk_uo_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_uo_org  FOREIGN KEY (org_id)  REFERENCES organizations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Users banned by an organization
-- -------------------------------------------------------------
CREATE TABLE banned_users (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id        INT UNSIGNED NOT NULL,
  banned_by_org  INT UNSIGNED NOT NULL,
  createdAt      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ban (user_id, banned_by_org),
  CONSTRAINT fk_ban_user FOREIGN KEY (user_id)       REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_ban_org  FOREIGN KEY (banned_by_org) REFERENCES organizations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Departments inside an organization
-- -------------------------------------------------------------
CREATE TABLE departments (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  org_id       INT UNSIGNED NOT NULL,
  name         VARCHAR(150) NOT NULL,
  slug         VARCHAR(160) NOT NULL,
  description  TEXT NULL,
  status       ENUM('active','inactive') NOT NULL DEFAULT 'active',
  createdAt    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_dept_slug (org_id, slug),
  CONSTRAINT fk_dept_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Complaints (allegations)
-- -------------------------------------------------------------
CREATE TABLE complaints (
  id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  org_id           INT UNSIGNED NOT NULL,
  department_id    INT UNSIGNED NULL,              -- NULL = whole organization
  user_id          INT UNSIGNED NULL,              -- NULL = anonymous
  title            VARCHAR(255) NOT NULL,
  description      TEXT NOT NULL,
  priority         ENUM('Low','Medium','High','Urgent') NOT NULL DEFAULT 'Low',
  is_anonymous     TINYINT(1) NOT NULL DEFAULT 0,
  attachment_path  VARCHAR(500) NULL,
  status           ENUM('Open','Pending','In Progress','Resolved','Rejected','Closed','Withdrawn')
                   NOT NULL DEFAULT 'Open',
  trackingCode     VARCHAR(20) NOT NULL,
  votes            INT NOT NULL DEFAULT 0,
  createdAt        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  editedAt         DATETIME NULL,
  withdrawnAt      DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_tracking (trackingCode),
  KEY idx_c_org (org_id, createdAt),
  KEY idx_c_user (user_id),
  KEY idx_c_dept (department_id),
  KEY idx_c_withdrawn (status, withdrawnAt),
  CONSTRAINT fk_c_org  FOREIGN KEY (org_id)        REFERENCES organizations(id) ON DELETE CASCADE,
  CONSTRAINT fk_c_dept FOREIGN KEY (department_id) REFERENCES departments(id)   ON DELETE SET NULL,
  CONSTRAINT fk_c_user FOREIGN KEY (user_id)       REFERENCES users(id)         ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Votes: one per voter per complaint.
-- voter_key = 'u:<userId>' for logged-in users, 'a:<cookieId>' for anonymous
-- -------------------------------------------------------------
CREATE TABLE complaint_votes (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  complaint_id  INT UNSIGNED NOT NULL,
  voter_key     VARCHAR(80) NOT NULL,
  createdAt     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_vote (complaint_id, voter_key),
  CONSTRAINT fk_v_complaint FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Edit history of complaints
-- -------------------------------------------------------------
CREATE TABLE complaint_edits (
  id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  complaint_id     INT UNSIGNED NOT NULL,
  old_title        VARCHAR(255) NULL,
  old_description  TEXT NULL,
  new_title        VARCHAR(255) NULL,
  new_description  TEXT NULL,
  edited_by        INT UNSIGNED NOT NULL,
  edited_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_e_complaint (complaint_id, edited_at),
  CONSTRAINT fk_e_complaint FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE,
  CONSTRAINT fk_e_user      FOREIGN KEY (edited_by)    REFERENCES users(id)      ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Notifications for users and organizations
-- -------------------------------------------------------------
CREATE TABLE notifications (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id        INT UNSIGNED NULL,
  org_id         INT UNSIGNED NULL,
  complaints_id  INT UNSIGNED NULL,
  type           VARCHAR(40) NOT NULL DEFAULT 'info',
  message        VARCHAR(500) NOT NULL,
  createdAt      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  read_at        DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_n_user (user_id, createdAt),
  KEY idx_n_org (org_id, createdAt),
  CONSTRAINT fk_n_user      FOREIGN KEY (user_id)       REFERENCES users(id)         ON DELETE CASCADE,
  CONSTRAINT fk_n_org       FOREIGN KEY (org_id)        REFERENCES organizations(id) ON DELETE CASCADE,
  CONSTRAINT fk_n_complaint FOREIGN KEY (complaints_id) REFERENCES complaints(id)    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
