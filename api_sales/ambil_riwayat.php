<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "db_sales_bengkel");

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Koneksi database gagal"]);
    exit;
}

$username = isset($_GET['username']) ? $conn->real_escape_string($_GET['username']) : '';
$page     = isset($_GET['page'])     ? max(1, (int)$_GET['page']) : 1;
$limit    = 10;
$offset   = ($page - 1) * $limit;

// Parameter filter baru
$search  = isset($_GET['search'])  ? $conn->real_escape_string(trim($_GET['search'])) : '';
$status  = isset($_GET['status'])  ? $conn->real_escape_string(trim($_GET['status'])) : '';
$dari    = isset($_GET['dari'])    ? $conn->real_escape_string(trim($_GET['dari']))   : '';
$sampai  = isset($_GET['sampai'])  ? $conn->real_escape_string(trim($_GET['sampai'])): '';

if (empty($username)) {
    echo json_encode(["status" => "error", "message" => "Username tidak boleh kosong"]);
    exit;
}

// Bangun WHERE clause dinamis
$where = "WHERE nama_sales = '$username'";
if (!empty($search))  $where .= " AND nama_bengkel LIKE '%$search%'";
if (!empty($status))  $where .= " AND status_kunjungan = '$status'";
if (!empty($dari))    $where .= " AND DATE(waktu_input) >= '$dari'";
if (!empty($sampai))  $where .= " AND DATE(waktu_input) <= '$sampai'";

// Hitung total data sesuai filter
$q_total = $conn->query("SELECT COUNT(*) as total FROM tb_bengkel $where");
$total   = $q_total ? (int)$q_total->fetch_assoc()['total'] : 0;

// Ambil data sesuai halaman + filter
$q_kunjungan = $conn->query("SELECT nama_bengkel, waktu_input, status_kunjungan, catatan, latitude, longitude 
                              FROM tb_bengkel 
                              $where 
                              ORDER BY waktu_input DESC 
                              LIMIT $limit OFFSET $offset");

$kunjungan = [];
if ($q_kunjungan) {
    while ($row = $q_kunjungan->fetch_assoc()) {
        $kunjungan[] = $row;
    }
}

$hasMore = ($offset + $limit) < $total;

echo json_encode([
    "status"         => "success",
    "data_kunjungan" => $kunjungan,
    "page"           => $page,
    "has_more"       => $hasMore,
    "total"          => $total,
]);

$conn->close();
?>