<?php

return [
    'enabled' => env('COS_ENABLED', false),
    'secret_id' => env('COS_SECRET_ID', ''),
    'secret_key' => env('COS_SECRET_KEY', ''),
    'bucket' => env('COS_BUCKET', ''),
    'region' => env('COS_REGION', 'ap-shanghai'),
];
