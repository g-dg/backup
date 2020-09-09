PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

PRAGMA user_version = 1;

CREATE TABLE "files"(
	"id" INTEGER PRIMARY KEY NOT NULL,
	"filename" TEXT NOT NULL,
	"type" INTEGER NOT NULL,
	"valid_start" INTEGER NOT NULL,
	"valid_end" INTEGER NOT NULL,
	"link_target" TEXT
);

CREATE TABLE "backup_plans"(
	"id" INTEGER PRIMARY KEY NOT NULL,
	"name" TEXT NOT NULL UNIQUE,
	"backup_key" TEXT UNIQUE,
	"root_file_id" INTEGER REFERENCES "files"
);

CREATE TABLE "backups"(
	"id" INTEGER PRIMARY KEY NOT NULL,
	"backup_plan_id" INTEGER NOT NULL REFERENCES "backup_plans",
	"status" INTEGER NOT NULL,
	"start_time" INTEGER NOT NULL,
	"end_time" INTEGER NOT NULL,
	"last_updated" INTEGER NOT NULL
);

CREATE TABLE "users"(
	"id" INTEGER PRIMARY KEY NOT NULL,
	"username" TEXT NOT NULL,
	"password" TEXT NOT NULL,
	"is_admin" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE "user_backup_plan_access"(
	"user_id" INTEGER NOT NULL REFERENCES "users",
	"backup_plan_id" INTEGER NOT NULL REFERENCES "backup_plans",
	PRIMARY KEY("user_id", "backup_plan_id")
);

CREATE TABLE "storage_locations"(
	"id" INTEGER PRIMARY KEY NOT NULL,
	"system_path" TEXT NOT NULL,
	"current_disk_usage" INTEGER NOT NULL DEFAULT 0,
	"max_disk_usage" TEXT
);

CREATE TABLE "backup_plan_storage_locations"(
	"backup_plan_id" INTEGER NOT NULL REFERENCES "backup_plans",
	"storage_location_id" INTEGER NOT NULL REFERENCES "storage_locations",
	"priority" INTEGER,
	"current_disk_usage" INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("backup_plan_id", "storage_location_id")
);

CREATE TABLE "objects"(
	"id" INTEGER PRIMARY KEY NOT NULL,
	"hash" TEXT NOT NULL UNIQUE,
	"storage_location_id" INTEGER NOT NULL REFERENCES "storage_locations",
	"chunk_size" INTEGER NOT NULL,
	"chunk_count" INTEGER NOT NULL,
	"reference_count" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE "file_data"(
	"id" INTEGER PRIMARY KEY NOT NULL,
	"file_id" INTEGER NOT NULL REFERENCES "files",
	"valid_start" INTEGER,
	"valid_end" INTEGER,
	"size" INTEGER NOT NULL,
	"object_id" INTEGER REFERENCES "objects"
);

CREATE TABLE "file_user_group_names"(
	"id" INTEGER PRIMARY KEY NOT NULL,
	"name" TEXT
);

CREATE TABLE "file_meta"(
	"id" INTEGER PRIMARY KEY NOT NULL,
	"file_id" INTEGER NOT NULL REFERENCES "files",
	"valid_start" INTEGER,
	"valid_end" INTEGER,
	"user_id" INTEGER REFERENCES "file_user_group_names",
	"group_id" INTEGER REFERENCES "file_user_group_names",
	"mode" INTEGER,
	"atime" INTEGER,
	"ctime" INTEGER,
	"mtime" INTEGER
);

CREATE TABLE "sessions"(
	"id" INTEGER PRIMARY KEY NOT NULL,
	"session_id" TEXT NOT NULL UNIQUE,
	"last_access" INTEGER NOT NULL,
	"user_id" INTEGER NOT NULL REFERENCES "users"
);

CREATE TABLE "session_data"(
	"session_id" INTEGER NOT NULL REFERENCES "sessions",
	"key" TEXT NOT NULL,
	"value" TEXT NOT NULL,
	UNIQUE("session_id", "key")
);


COMMIT TRANSACTION;
