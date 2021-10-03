PRAGMA page_size = 65536;
PRAGMA max_page_count = 4294967294;
PRAGMA auto_vacuum = INCREMENTAL;

PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;

PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

PRAGMA user_version = 1000000;

CREATE TABLE "file_data_chunks" (
	"hash_sha256" TEXT NOT NULL PRIMARY KEY,
	"compression_algorithm" TEXT,
	"uncompressed_size" INTEGER NOT NULL,
	"created_timestamp" INTEGER NOT NULL,
	"data" BLOB NOT NULL
);

COMMIT TRANSACTION;
