<?php

// load config
$config = [];
require('server_config.php');

// enable debug mode
if (isset($config['debug']) && $config['debug']) {
	error_reporting(E_ALL);
	ini_set('display_errors', 'On');
}

