<?php

function load_config()
{
	global $config;

	// load config
	$config = [];
	require('config.php');

	// enable debug mode
	if (isset($config['debug']) && $config['debug']) {
		error_reporting(E_ALL);
		ini_set('display_errors', 'On');
	}
}

function db_connect()
{
	global $dbconn;


}
