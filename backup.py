#!/usr/bin/env python3

import base64
import gzip
import hashlib
import html
import http
import json
import os
import pwd
import shutil
import sqlite3
import sys
import urllib

config = {
	"debug": True
}


if sys.version_info[0] < 3 or sys.version_info[1] < 4:
	raise Exception("This program requres Python 3.4 or later.")


class Server:

	def __init__(self):
		if config["debug"]:
			import cgi
			import cgitb
			cgitb.enable()

		self.responseHeaders = {
			"Content-Type": "text/html; charset=UTF-8"
		}

		self.requestMethod = os.environ.get("REQUEST_METHOD", "GET")

		self.getVars = urllib.parse.parse_qs(os.environ.get("QUERY_STRING"))
		if self.requestMethod == "POST":
			self.postVars = urllib.parse.parse_qs(sys.stdin.read())
		else:
			self.postVars = None

		self.pathInfo = os.environ.get("PATH_INFO", "")

	def output_headers(self):
		for header, value in self.responseHeaders.items():
			print(header, ": ", value, end="\r\n", sep="")
		print("", end="\r\n")

	def route(self):
		pathInfoSplit = self.pathInfo.lstrip("/").split("/")

		if len(pathInfoSplit) >= 2 and pathInfoSplit[0] == "api":
			action = pathInfoSplit[1]

			apiActions = {
				"GET": {
					"file": None,
				},
				"POST": {
					"status": None,
					"file": None,
					"chunk": None,
					"optimize": None,
				}
			}

class ServerAPI:
	def __init__(self):
		pass




class Client:
	def __init__(self):
		pass

	def run(self):
		pass

if "GATEWAY_INTERFACE" in os.environ and os.environ["GATEWAY_INTERFACE"].startswith("CGI/1."):
	server = Server()
	server.route()
else:
	client = Client()
	client.run()
