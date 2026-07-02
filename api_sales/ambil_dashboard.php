<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "db_sales_bengkel");

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Koneksi gagal"]));
}

$username = isset($_GET['username']) ? $conn->real_escape_string($_GET['username']) : '';

// 1. Hitung Kunjungan Total (Per Sales)
$q_total = $conn->query("SELECT COUNT(*) as total FROM tb_bengkel WHERE nama_sales = '$username'");
$total_keseluruhan = $q_total ? ($q_total->fetch_assoc()['total'] ?? 0) : 0;

// 2. Hitung Kunjungan Hari Ini
$q_hari_ini = $conn->query("SELECT COUNT(*) as total FROM tb_bengkel WHERE nama_sales = '$username' AND DATE(waktu_input) = CURDATE()");
$total_hari_ini = $q_hari_ini ? ($q_hari_ini->fetch_assoc()['total'] ?? 0) : 0;

// 3. Ambil Kunjungan Terakhir
$q_terakhir = $conn->query("
    SELECT nama_bengkel, waktu_input as waktu, status_kunjungan 
    FROM tb_bengkel 
    WHERE nama_sales = '$username' 
    ORDER BY waktu_input DESC LIMIT 1
");

$bengkel_terakhir = 'Belum ada aktivitas';
$status_terakhir = '-';
$waktu_terakhir = '-';

if ($q_terakhir && $q_terakhir->num_rows > 0) {
    $row = $q_terakhir->fetch_assoc();
    $bengkel_terakhir = $row['nama_bengkel'];
    $status_terakhir = $row['status_kunjungan'] ?? '-';
    $waktu_terakhir = date('d M Y, H:i', strtotime($row['waktu'])) . ' WIB';
}

echo json_encode([
    "status" => "success",
    "total_kunjungan" => (int)$total_hari_ini,
    "total_keseluruhan" => (int)$total_keseluruhan,
    "bengkel_terakhir" => $bengkel_terakhir,
    "status_terakhir" => $status_terakhir,
    "waktu_terakhir" => $waktu_terakhir
]);

$conn->close();
?>