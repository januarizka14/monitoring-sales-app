<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$id = $_POST['id'] ?? '';

if (empty($id) || !is_numeric($id)) {
    echo json_encode(["status" => "error", "message" => "ID tidak valid"]);
    exit;
}

$stmt = mysqli_prepare($conn, "DELETE FROM tb_tasks WHERE id = ?");
mysqli_stmt_bind_param($stmt, "i", $id);

if (mysqli_stmt_execute($stmt)) {
    echo json_encode(["status" => "success", "message" => "Tugas berhasil dihapus"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal menghapus tugas"]);
}

mysqli_stmt_close($stmt);
mysqli_close($conn);
?>