Garnet DeGelder's Backup Server & Client
========================================

This project uses the MIT license, see `LICENSE.md` for details.

Server and client are included in the main program, `backup.py`.
Configuration is stored in `config.json`.
The server uses SQLite3 to store both the file information and the file data.

Supported features:
- File backup service
- File browse and restore utility
- File history
	- Full history of file data and metadata for a minimum of 30 days and for a maximum of 1 year by default
- Most UNIX file metadata and permission support
	- Octal permissions
	- Owner and group names and IDs
	- File modification times (mtime & ctime)
- Symbolic links
- Data de-duplication
	- Data is de-duplicated on a block level with a default block size of 1MB
	- Duplication of blocks is detected with SHA256 hashing
- Compression
	- Server may compress the data blocks for storage
- Uses either single database file or multiple databases.

Potential future features:
- Hard links
- Client-side encryption
- Access control lists

Not supported:
- Windows or anything not UNIX-based
- Server-side encryption
- UNIX file access time (atime)
- Extended file attributes
- Special UNIX file types (i.e. block, char, pipes, sockets)

Any dates and times that refer to backed up files in the database are UTC and from the client's clock.
The server's time is only used for things like web sessions and caching.

Files are backed up and stored in up to 1M chunks.
Each chunk may be compressed with a supported compression algorithm.
By default, compression takes place on the client side.
By default the server verifies the integrity of the compressed data.
If either the client or server finds that the data takes up more space when compressed, then it may store the data uncompressed.

The client finds the files that changed by checking the size and last modified time.
Optionally, it can additionally check part of the file to see if it has actually changed.
