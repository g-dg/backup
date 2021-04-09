PRAGMA page_size = 65536;
PRAGMA auto_vacuum = INCREMENTAL;

PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;

PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

PRAGMA user_version = 1000000;

CREATE TABLE "file_names" (
	"id" INTEGER PRIMARY KEY,
	"parent_id" INTEGER REFERENCES "file_names",
	"name" TEXT NOT NULL,
	UNIQUE("parent_id", "name")
);

CREATE TABLE "backup_plans" (
	"id" INTEGER PRIMARY KEY,
	"name" TEXT NOT NULL,
	"backup_key" TEXT NOT NULL UNIQUE,
	"root_file_name" INTEGER NOT NULL REFERENCES "file_names"("id"),
	"min_age" INTEGER DEFAULT 2592000,
	"max_age" INTEGER DEFAULT 31536000
);

CREATE TABLE "users_groups" (
	"id" INTEGER PRIMARY KEY,
	"system_id" INTEGER,
	"name" TEXT,
	UNIQUE("name", "system_id")
);

CREATE TABLE "files" (
	"id" INTEGER PRIMARY KEY,
	"filename_id" INTEGER NOT NULL REFERENCES "file_names"("id"),
	"valid_start" INTEGER,
	"valid_end" INTEGER,
	"type" INTEGER NOT NULL,
	"hash" TEXT,
	"size" INTEGER,
	"link_target" INTEGER REFERENCES "file_names"("id"),
	"user_id" INTEGER REFERENCES "users_groups"("id"),
	"group_id" INTEGER REFERENCES "users_groups"("id"),
	"mode" INTEGER,
	"atime" INTEGER,
	"ctime" INTEGER,
	"mtime" INTEGER
);

CREATE TABLE "file_chunks" (
	"hash" TEXT NOT NULL PRIMARY KEY,
	"uncompressed_size" INTEGER NOT NULL,
	"data" BLOB NOT NULL
);

CREATE TABLE "file_data" (
	"id" INTEGER PRIMARY KEY,
	"file_id" INTEGER NOT NULL REFERENCES "files"("id"),
	"chunk_index" INTEGER NOT NULL,
	"chunk_hash" TEXT NOT NULL REFERENCES "file_chunks"("hash"),
	UNIQUE("file_id", "chunk_index")
);
CREATE INDEX "idx_fileData_chunkHash" ON "file_data"("chunk_hash");

CREATE TABLE "backup_status" (
	"id" INTEGER PRIMARY KEY,
	"backup_plan_id" INTEGER NOT NULL REFERENCES "backup_plans"("id"),
	"start_time" INTEGER,
	"end_time" INTEGER,
	"last_update" INTEGER
);

CREATE TABLE "users" (
	"id" INTEGER PRIMARY KEY,
	"username" TEXT NOT NULL UNIQUE,
	"password" TEXT NOT NULL,
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
	"csrf_token" TEXT NOT NULL,
	"data" TEXT
);

COMMIT TRANSACTION;
