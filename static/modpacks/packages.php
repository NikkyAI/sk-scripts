<?php
$keys = isset($_GET['key']) ? array_map('trim', explode(',', strtolower($_GET['key']))) : array();
$packages = array();

$packages[] = array(
    'name' => 'fuckitbrokeagain',
    'title' => 'Fuck it broke again',
    'version' => trim(file_get_contents('fuckitbrokeagain/version.txt')),
    'priority' => 0,
    'location' => 'fuckitbrokeagain.json',
);
$packages[] = array(
    'name' => 'cpack',
    'title' => 'copy pack',
    'version' => trim(file_get_contents('cpack/version.txt')),
    'priority' => 0,
    'location' => 'cpack.json',
);
$packages[] = array(
    'name' => 'lite_pack',
    'title' => 'Lite pack',
    'version' => trim(file_get_contents('lite_pack/version.txt')),
    'priority' => 0,
    'location' => 'lite_pack.json',
);

$packages[] = array(
    'name' => 'test_pack',
    'title' => 'Test Pack',
    'version' => trim(file_get_contents('test_pack/version.txt')),
    'priority' => 0,
    'location' => 'test_pack.json',
);

$out = array('minimumVersion' => 1, 'packages' => $packages);
header('Content-Type: text/plain; charset=utf-8');
echo json_encode($out);
