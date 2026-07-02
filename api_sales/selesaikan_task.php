<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$id_task = $_POST['id'] ?? '';

if (empty($id_task) || !is_numeric($id_task)) {
    echo json_encode(['status' => 'error', 'message' => 'ID tugas tidak valid']);
    exit;
}

$stmt = mysqli_prepare($conn, "UPDATE tb_tasks SET status = 'done' WHERE id = ?");
mysqli_stmt_bind_param($stmt, "i", $id_task);

if (mysqli_stmt_execute($stmt)) {
    echo json_encode(['status' => 'success', 'message' => 'Tugas berhasil diselesaikan!']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Gagal update status: ' . mysqli_error($conn)]);
}

mysqli_stmt_close($stmt);
mysqli_close($conn);
?>
