<?php

$allowedOrigins = array_filter(explode(',', getenv('CORS_ALLOWED_ORIGINS') ?: ''));

return [
    'allowed_origins' => $allowedOrigins,
    'methods' => 'GET, POST, PUT, DELETE, OPTIONS',
    'headers' => 'Content-Type, Authorization, X-Requested-With, token, isToken, repeatSubmit, interval',
    'max_age' => 86400,
];
