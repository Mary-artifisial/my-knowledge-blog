-- DDL for Personal Knowledge Blog System
-- Database: SQLite
-- Version: 1.3 (Recommended)

-- ----------------------------
-- Table structure for users (用户信息表)
-- ----------------------------
DROP TABLE IF EXISTS "users";
CREATE TABLE "users"
(
    "id"            INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,
    "username"      TEXT     NOT NULL UNIQUE,
    "password_hash" TEXT     NOT NULL,
    "role"          TEXT     NOT NULL CHECK ("role" IN ('OWNER', 'GUEST')) DEFAULT 'GUEST',
    "create_time"   DATETIME NOT NULL                                      DEFAULT (datetime('now', 'localtime')),
    "update_time"   DATETIME NOT NULL                                      DEFAULT (datetime('now', 'localtime'))
);

-- ----------------------------
-- Table structure for categories (分类表 - 新增)
-- ----------------------------
DROP TABLE IF EXISTS "categories";
CREATE TABLE "categories"
(
    "id"          INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,
    "parent_id"   INTEGER,
    "name"        TEXT     NOT NULL,
-- [优化] 新增冗余路径字段，存储ID路径，如根/1/5/
    "path"        TEXT     NOT NULL,
    "sort_order"  INTEGER  NOT NULL DEFAULT 0,
    "create_time" DATETIME NOT NULL DEFAULT (datetime('now', 'localtime')),
    "update_time" DATETIME NOT NULL DEFAULT (datetime('now', 'localtime')),
    FOREIGN KEY ("parent_id") REFERENCES "categories" ("id") ON DELETE CASCADE
);

-- ----------------------------
-- Table structure for articles (文章信息表 - 修改)
-- ----------------------------
DROP TABLE IF EXISTS "articles";
CREATE TABLE "articles"
(
    "id"           INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,
    "user_id"      INTEGER  NOT NULL,
    -- 新增 category_id 外键
    "category_id"  INTEGER,
    "title"        TEXT     NOT NULL,
    "content"      TEXT,
    "status"       TEXT     NOT NULL DEFAULT 'DRAFT' CHECK ("status" IN ('PUBLISHED', 'DRAFT')),
    "is_public"    INTEGER  NOT NULL DEFAULT 1,
    "is_deleted"   INTEGER  NOT NULL DEFAULT 0,
    "publish_time" DATETIME,
    "create_time"  DATETIME NOT NULL DEFAULT (datetime('now', 'localtime')),
    "update_time"  DATETIME NOT NULL DEFAULT (datetime('now', 'localtime')),
    FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE,
    -- 当分类被删除时，关联的文章 category_id 置为 NULL (变为未分类)
    FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON DELETE SET NULL
);

-- ----------------------------
-- Table structure for tags (标签表)
-- ----------------------------
DROP TABLE IF EXISTS "tags";
CREATE TABLE "tags"
(
    "id"          INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name"        TEXT     NOT NULL UNIQUE,
    "create_time" DATETIME NOT NULL DEFAULT (datetime('now', 'localtime'))
);

-- ----------------------------
-- Table structure for article_tag_relation (文章与标签关联表)
-- ----------------------------
DROP TABLE IF EXISTS "article_tag_relation";
CREATE TABLE "article_tag_relation"
(
    "article_id" INTEGER NOT NULL,
    "tag_id"     INTEGER NOT NULL,
    PRIMARY KEY ("article_id", "tag_id"),
    FOREIGN KEY ("article_id") REFERENCES "articles" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE CASCADE
);

-- ----------------------------
-- Table structure for article_history, attachments, ai_qa_records, system_settings, plugins (这些表结构保持不变)
-- ... (此处省略未改变的表以保持简洁，实际使用时应包含所有表的创建语句)
-- ----------------------------
DROP TABLE IF EXISTS "article_history";
CREATE TABLE "article_history"
(
    "id"          INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,
    "article_id"  INTEGER  NOT NULL,
    "title"       TEXT     NOT NULL,
    "content"     TEXT,
    "create_time" DATETIME NOT NULL DEFAULT (datetime('now', 'localtime')),
    FOREIGN KEY ("article_id") REFERENCES "articles" ("id") ON DELETE CASCADE
);

DROP TABLE IF EXISTS "attachments";
CREATE TABLE "attachments"
(
    "id"            INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,
    "article_id"    INTEGER,
    "user_id"       INTEGER  NOT NULL,
    "original_name" TEXT     NOT NULL,
    "storage_path"  TEXT     NOT NULL,
    "mime_type"     TEXT,
    "size_in_bytes" INTEGER,
    "is_encrypted"  INTEGER  NOT NULL DEFAULT 0,
    "create_time"   DATETIME NOT NULL DEFAULT (datetime('now', 'localtime')),
    FOREIGN KEY ("article_id") REFERENCES "articles" ("id") ON DELETE SET NULL,
    FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE
);

DROP TABLE IF EXISTS "ai_qa_records";
CREATE TABLE "ai_qa_records"
(
    "id"          INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,
    "article_id"  INTEGER  NOT NULL,
    "user_id"     INTEGER,
    "question"    TEXT     NOT NULL,
    "answer"      TEXT,
    "create_time" DATETIME NOT NULL DEFAULT (datetime('now', 'localtime')),
    FOREIGN KEY ("article_id") REFERENCES "articles" ("id") ON DELETE CASCADE,
    FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL
);

DROP TABLE IF EXISTS "system_settings";
CREATE TABLE "system_settings"
(
    "setting_key"   TEXT     NOT NULL PRIMARY KEY,
    "setting_value" TEXT,
    "description"   TEXT,
    "update_time"   DATETIME NOT NULL DEFAULT (datetime('now', 'localtime'))
);

DROP TABLE IF EXISTS "plugins";
CREATE TABLE "plugins"
(
    "id"          INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,
    "plugin_id"   TEXT     NOT NULL UNIQUE,
    "name"        TEXT     NOT NULL,
    "is_enabled"  INTEGER  NOT NULL DEFAULT 0,
    "version"     TEXT,
    "config"      TEXT,
    "create_time" DATETIME NOT NULL DEFAULT (datetime('now', 'localtime')),
    "update_time" DATETIME NOT NULL DEFAULT (datetime('now', 'localtime'))
);


-- ----------------------------
-- Create Indexes for performance (索引更新)
-- ----------------------------
CREATE INDEX "idx_articles_status" ON "articles" ("status");
CREATE INDEX "idx_articles_is_deleted" ON "articles" ("is_deleted");
CREATE INDEX "idx_articles_category_id" ON "articles" ("category_id"); -- 新索引
CREATE INDEX "idx_tags_name" ON "tags" ("name");
CREATE INDEX "idx_attachments_article_id" ON "attachments" ("article_id");
CREATE INDEX "idx_categories_parent_id" ON "categories" ("parent_id");
-- 新索引

-- ----------------------------
-- Initial Data (添加初始分类数据)
-- ----------------------------
INSERT INTO "users" ("id", "username", "password_hash", "role")
VALUES (1, 'admin', '$2a$10$tJ0pI.g6uU/0c7khP4D8ROlR2CqVmzT2/iA.gBtlW59BC5d2u0k1q', 'OWNER');
INSERT INTO "system_settings" ("setting_key", "setting_value", "description")
VALUES ('site_title', 'My Knowledge Base', '博客系统的全局标题');

-- 插入一个默认的“未分类”
INSERT INTO "categories" ("id", "name", "parent_id", "path", "sort_order")
VALUES (1, '未分类', NULL, '/1/', 0);
