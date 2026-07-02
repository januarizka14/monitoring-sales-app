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
    echo json_encode(["status" => "error", "message" => "Username dan password wajib diisi"]);
    exit;
}

if (strlen($password) < 6) {
    echo json_encode(["status" => "error", "message" => "Password minimal 6 karakter"]);
    exit;
}

// Cek username pakai prepared statement
$stmt = $conn->prepare("SELECT id FROM tb_users WHERE username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "Username sudah digunakan!"]);
    $stmt->close();
    exit;
}
$stmt->close();

// Hash password sebelum disimpan
$hashedPassword = password_hash($password, PASSWORD_BCRYPT);

// Simpan dengan prepared statement
$stmt = $conn->prepare("INSERT INTO tb_users (username, password) VALUES (?, ?)");
$stmt->bind_param("ss", $username, $hashedPassword);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Akun berhasil dibuat! Silakan login."]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal mendaftarkan akun"]);
}

$stmt->close();
$conn->close();
?>