<?php
$keys = isset($_GET['key']) ? array_map('trim', explode(',', strtolower($_GET['key']))) : array();
$packages = array();

$packages[] = array(
    'name' => 'lite_pack',
    'title' => 'Lite pack',
    'version' => trim(file_get_contents('lite_pack/version.txt')),
    'priority' => 0,
    'location' => 'lite_pack.json',
);

$packages[] = array(
    'name' => 'penguins_retreat',
    'title' => 'penguins retreat',
    'version' => trim(file_get_contents('penguins_retreat/version.txt')),
    'priority' => 0,
    'location' => 'penguins_retreat.json',
);

$out = array('minimumVersion' => 1, 'packages' => $packages);
header('Content-Type: text/plain; charset=utf-8');
echo json_encode($out);
