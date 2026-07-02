<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$username     = trim($_POST['username']        ?? '');
$nama_bengkel = trim($_POST['nama_bengkel']     ?? '');
$deskripsi    = trim($_POST['deskripsi_tugas']  ?? '');
$deadline     = trim($_POST['deadline']         ?? '');

if (empty($username) || empty($nama_bengkel) || empty($deskripsi)) {
    echo json_encode(["status" => "error", "message" => "Semua field wajib diisi"]);
    exit;
}

$deadlineValue = empty($deadline) ? null : $deadline;

$stmt = mysqli_prepare($conn, "INSERT INTO tb_tasks (username, nama_bengkel, deskripsi_tugas, deadline, status) VALUES (?, ?, ?, ?, 'pending')");
mysqli_stmt_bind_param($stmt, "ssss", $username, $nama_bengkel, $deskripsi, $deadlineValue);

if (mysqli_stmt_execute($stmt)) {
    echo json_encode(["status" => "success", "message" => "Tugas berhasil dibuat!"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal membuat tugas: " . mysqli_error($conn)]);
}

mysqli_stmt_close($stmt);
mysqli_close($conn);
?>