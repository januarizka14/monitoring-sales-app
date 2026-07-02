<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "db_sales_bengkel");

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Koneksi database gagal"]);
    exit;
}

$username = trim($_POST['username'] ?? '');
$password = trim($_POST['password'] ?? '');

if (empty($username) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Data tidak boleh kosong"]);
    exit;
}

// Ambil username, password, DAN role
$stmt = $conn->prepare("SELECT username, password, role FROM tb_users WHERE username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "Username atau password salah!"]);
    $stmt->close();
    exit;
}

$user = $result->fetch_assoc();
$stmt->close();

if (password_verify($password, $user['password'])) {
    echo json_encode([
        "status"   => "success",
        "message"  => "Login berhasil!",
        "username" => $user['username'],
        "role"     => $user['role'], // kirim role ke Flutter
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Username atau password salah!"]);
}

$conn->close();
?>