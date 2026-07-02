<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$result = mysqli_query($conn, "SELECT id, username, waktu_daftar FROM tb_users WHERE role = 'sales' ORDER BY waktu_daftar DESC");
$users = [];
if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $users[] = $row;
    }
}

echo json_encode([
    "status" => count($users) > 0 ? "success" : "empty",
    "data_users" => $users,
]);

mysqli_close($conn);
?>