Garnet DeGelder's Backup Server & Client API documentation
==========================================================

General Information
-------------------
Unless otherwise specified, the API uses JSON for transferring data.

Posted data will be a raw JSON object in the request body (not urlencoded form data).

Request parameters are urlencoded in the GET request


Protocol Versions
-----------------
Protocol versions are used to determine which features the server supports.

The protocol version follows the [Semantic Versioning 2.0.0 Specification](https://semver.org/spec/v2.0.0.html)

To allow for forwards compatability, JSON objects must be allowed to contain fields not documented by this API version.

This document defines API version 1.0.0


Authentication
--------------
Most requests will require either a backup key or session id.
Backup keys are set when creating a backup
A session id can be recieved by POSTing a valid username or password to `login`.
Backup keys use the HTTP `Authorization` header with the scheme `X-AccessKey`
Session IDs use the HTTP `Authorization` header with the scheme `X-SessionID`


Compression
-----------
Compression will be handled transparently by the server.


---

GET `server_info`
-----------------
Gets server information about supported features.

### Authentication
*none needed*

### Parameters
*none*

### Return
JSON object:
```json
{
	"api_version": "1.0.0", // API version number
	"server_version": "1.0.0", // Server version number
	"server_time": "1970-01-01T00:00:00+00:00", // Current server time
}
```

GET `file_meta`
---------------
Returns metadata of the current version of a file.
If the specified path is a directory, it will also contain an array of the current directory contents.

### Authentication
- Backup key
- Session id

### Parameters
- `path`: The path of the file
- `time`: The client time of the file history to query, current time if not specified
- `full`: Set to any value (including blank) to include chunk hashes and contained filenames

### Response Codes
- 200 OK: Successful
- 404 Not Found: File entry not found (may not exist at the specified time)

### Return
JSON object:
```json
{
	"type": "file", // file type (see "file types" section of API documentation)
	"size": 0, // filesize if file, number of files and directories if directory
	"link_target": null, // the filename the link is pointing to if the file type is a link, else null
	"metadata": { // file metadata
		// see "File Metadata" section of API documentation
	},
	"chunks": [
		// ordered array of the chunk hashes in the file (if type is a file)
		// only sent if `full` GET parameter is set
	],
	"files": [
		// unordered list of filenames if type is a directory
		// only sent if `full` GET parameter is set
	]
}
```


GET `file_chunk`
----------------
Returns the data contained in a file chunk.

To find if a chunk exists, send a HEAD request and check the response code.

### Authentication
- Backup key
- Session id

### Parameters
- `hash`: The chunk hash to retrieve

### Response Codes
- 200 OK: Successful
- 404 Not Found: Chunk hash not found

### Response Headers
- `Content-Type`: always `application/octet-stream`

### Response Body
The file data.
Note that compression is handled transparently by the server, so the response will be uncompressed


POST `file_meta`
----------------
Sends file metadata and chunk list to the server

The parent directory must already exist on the server

### Authentication
- Backup key

### Parameters
- `path`: The file path

### Request Body
A JSON object representing the file metadata
```json
{
	"deleted": false, // set to true if the file doesn't exist anymore
	"type": "file", // file type
	"link_target": null, // link target path if file type is a link
	"metadata": {
		// file metadata, see "File Metadata" section for details
	},
	"chunks": [
		// ordered array of the chunk hashes in the file
		// only required if `type` is a file
	]
}
```

### Response Codes
- 200 OK: Successful upload and processing
- 400 Bad request: Issue with request body
- 404 Not Found: Sent if the parent directory doesn't exist
- 507: Insufficient Storage: Out of space for backup


POST `file_chunk`
-----------------
Sends a new file chunk to the server.

The server will validate that the data matches the hash.

Any uploaded chunks will persist on the server until the minimum storage time has passed *and* no files are using them.

### Authentication
- Backup key

### Parameters
- `hash` The hash of the chunk

### Request Body
The file data

### Response Codes
- 200 OK: Successful upload and validated
- 400 Bad Request: Validation failed
- 507 Insufficient Storage: Out of space for backup

