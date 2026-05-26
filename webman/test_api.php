<?php
$loginData = json_encode(['username' => 'admin', 'password' => 'admin123']);
$ch = curl_init('http://127.0.0.1:8787/login');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $loginData);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$loginRes = curl_exec($ch);
$loginArr = json_decode($loginRes, true);
$token = $loginArr['token'] ?? 'NO_TOKEN';
echo "Token: " . substr($token, 0, 30) . "...\n\n";

$ch = curl_init('http://127.0.0.1:8787/system/appMenu/grouped');
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Authorization: Bearer ' . $token]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$res = curl_exec($ch);
$data = json_decode($res, true);
echo "Code: " . ($data['code'] ?? 'null') . "\n";
echo "Groups count: " . count($data['data'] ?? []) . "\n";
foreach ($data['data'] ?? [] as $g) {
    echo "  " . $g['group_name'] . " (" . $g['group_key'] . "): " . count($g['items']) . " items\n";
}
