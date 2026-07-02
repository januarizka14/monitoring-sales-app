<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$status   = isset($_GET['status'])   ? mysqli_real_escape_string($conn, $_GET['status'])   : '';
$username = isset($_GET['username']) ? mysqli_real_escape_string($conn, $_GET['username']) : '';

$where = "WHERE 1=1";
if (!empty($status))   $where .= " AND status = '$status'";
if (!empty($username)) $where .= " AND username = '$username'";

$result = mysqli_query($conn, "SELECT * FROM tb_tasks $where ORDER BY created_at DESC");
$tasks = [];
if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $tasks[] = $row;
    }
}

echo json_encode([
    "status"     => count($tasks) > 0 ? "success" : "empty",
    "data_tasks" => $tasks,
]);

mysqli_close($conn);
?>