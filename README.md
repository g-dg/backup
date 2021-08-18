Garnet DeGelder's Backup Server & Client
========================================

This project uses the MIT license, see `LICENSE.md` for details.

Server and client are included in the main program, `backup.py`.
Configuration is stored in `config.json`.
The server uses SQLite3 to store both the file information and the file data.

This backup program does not and likely won't ever properly support:
 - Hard links (do get deduplicated when backed up, but get restored as separate files)
 - Encryption (may add support for client-side encryption in the future)
 - Access control lists
 - Extended file attributes
 - Any Windows file permissions or metadata

Any dates and times that refer to backed up files in the database are UTC and from the client's clock.
The server's time is only used for things like web sessions and caching.

Files are backed up and stored in up to 1M chunks.
Each chunk may be compressed with a supported compression algorithm.
By default, compression takes place on the client side.
By default the server verifies the integrity of the compressed data.
If either the client or server finds that the data takes up more space when compressed, then it may store the data uncompressed.

The client finds the files that changed by checking the size and last modified time.
Optionally, it can additionally check part of the file to see if it has actually changed.

