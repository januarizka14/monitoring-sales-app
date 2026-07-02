<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$username = isset($_GET['username']) ? mysqli_real_escape_string($conn, $_GET['username']) : '';

if (empty($username)) {
    echo json_encode(['status' => 'error', 'message' => 'Username tidak boleh kosong']);
    exit;
}

$query = "SELECT * FROM tb_tasks WHERE username = '$username' AND status = 'pending' ORDER BY id DESC";
$result = mysqli_query($conn, $query);

$response = [];
if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $response[] = $row;
    }

    if (count($response) === 0) {
        echo json_encode(['status' => 'empty', 'data_tasks' => []]);
    } else {
        echo json_encode(['status' => 'success', 'data_tasks' => $response]);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Query gagal: ' . mysqli_error($conn)]);
}

mysqli_close($conn);
?>
