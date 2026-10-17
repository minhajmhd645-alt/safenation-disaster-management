<?php
// One main database for the complete SafeNation project.
// Host, port and credentials may be set for the local XAMPP installation.
// Test/import databases are retained backups, not application connections.
return ['host'=>getenv('DB_HOST') ?: '127.0.0.1','port'=>getenv('DB_PORT') ?: '3306',
 'database'=>'safenation_disaster_link','username'=>getenv('DB_USER') ?: 'root',
 'password'=>getenv('DB_PASS') ?: ''];
