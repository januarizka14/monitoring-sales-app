<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "db_sales_bengkel");

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Koneksi database gagal"]));
}

// Menangkap data dari request Flutter (POST)
$nama_sales      = $_POST['nama_sales'] ?? '';
$nama_bengkel    = $_POST['nama_bengkel'] ?? '';
$catatan         = $_POST['catatan'] ?? '';
$status          = $_POST['status_kunjungan'] ?? '';
$lat             = $_POST['latitude'] ?? '';
$lng             = $_POST['longitude'] ?? '';

// Validasi sederhana
if (empty($nama_sales) || empty($nama_bengkel)) {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
    exit;
}

// Query insert disesuaikan (Tanpa foto_kunjungan)
$query = "INSERT INTO tb_bengkel 
          (nama_sales, nama_bengkel, catatan, status_kunjungan, latitude, longitude, waktu_input) 
          VALUES 
          (?, ?, ?, ?, ?, ?, NOW())";

$stmt = $conn->prepare($query);

// "ssssss" (6 parameter string)
$stmt->bind_param("ssssss", $nama_sales, $nama_bengkel, $catatan, $status, $lat, $lng);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Data kunjungan berhasil disimpan"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal menyimpan data: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>