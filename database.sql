PRAGMA page_size = 65536;
PRAGMA auto_vacuum = INCREMENTAL;

PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;

PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

PRAGMA user_version = 1000000;

CREATE TABLE "files" (
	"id" INTEGER PRIMARY KEY,
	"parent_id" INTEGER REFERENCES "files",
	"name" TEXT NOT NULL,
	UNIQUE("parent_id", "name")
);

CREATE TABLE "backup_plans" (
	"id" INTEGER PRIMARY KEY,
	"name" TEXT NOT NULL,
	"backup_key" TEXT NOT NULL UNIQUE,
	"root_file_id" INTEGER NOT NULL REFERENCES "files"("id"),
	"min_age" INTEGER DEFAULT 2592000,
	"max_age" INTEGER DEFAULT 31536000
);

CREATE TABLE "file_meta" (
	"id" INTEGER PRIMARY KEY,
	"file_id" INTEGER NOT NULL REFERENCES "files"("id"),
	"valid_start" INTEGER,
	"valid_end" INTEGER,
	"type" INTEGER NOT NULL,
	"hash" TEXT,
	"size" INTEGER,
	"link_target" INTEGER REFERENCES "files"("id"),
	"metadata" TEXT
);
CREATE INDEX "idx_fileMeta_fileId" ON "file_meta"("file_id");
CREATE INDEX "idx_fileMeta_linkTarget" ON "file_meta"("link_target");

CREATE TABLE "file_data_chunks" (
	"hash" TEXT NOT NULL PRIMARY KEY,
	"compression_algorithm" TEXT,
	"uncompressed_size" INTEGER NOT NULL,
	"created_timestamp" INTEGER NOT NULL,
	"data" BLOB NOT NULL
);

CREATE TABLE "file_data" (
	"id" INTEGER PRIMARY KEY,
	"file_id" INTEGER NOT NULL REFERENCES "file_meta"("id"),
	"chunk_index" INTEGER NOT NULL,
	"chunk_hash" TEXT NOT NULL REFERENCES "file_data_chunks"("hash"),
	UNIQUE("file_id", "chunk_index")
);
CREATE INDEX "idx_fileData_fileId" ON "file_data"("file_id");
CREATE INDEX "idx_fileData_chunkHash" ON "file_data"("chunk_hash");

CREATE TABLE "backup_status" (
	"id" INTEGER PRIMARY KEY,
	"backup_plan_id" INTEGER NOT NULL REFERENCES "backup_plans"("id"),
	"start_time" INTEGER,
	"end_time" INTEGER,
	"last_update" INTEGER,
	"success" INTEGER
);

CREATE TABLE "users" (
	"id" INTEGER PRIMARY KEY,
	"username" TEXT NOT NULL UNIQUE,
	"password_hash" TEXT NOT NULL,
	"admin" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE "user_backup_plan_access" (
	"user_id" INTEGER NOT NULL REFERENCES "users"("id"),
	"backup_plan_id" INTEGER NOT NULL REFERENCES "backup_plans"("id"),
	"access_type" INTEGER NOT NULL DEFAULT 0,
	UNIQUE("user_id", "backup_plan_id")
);

CREATE TABLE "sessions" (
	"id" TEXT NOT NULL PRIMARY KEY,
	"last_access" INTEGER,
	"user_id" INTEGER REFERENCES "users"("id"),
	"data" TEXT
);

COMMIT TRANSACTION;
