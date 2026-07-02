<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$page    = isset($_GET['page'])    ? max(1, (int)$_GET['page']) : 1;
$limit   = 15;
$offset  = ($page - 1) * $limit;
$search  = isset($_GET['search'])  ? mysqli_real_escape_string($conn, trim($_GET['search']))  : '';
$status  = isset($_GET['status'])  ? mysqli_real_escape_string($conn, trim($_GET['status']))  : '';
$sales   = isset($_GET['sales'])   ? mysqli_real_escape_string($conn, trim($_GET['sales']))   : '';
$dari    = isset($_GET['dari'])    ? mysqli_real_escape_string($conn, trim($_GET['dari']))    : '';
$sampai  = isset($_GET['sampai'])  ? mysqli_real_escape_string($conn, trim($_GET['sampai'])) : '';

$where = "WHERE 1=1";
if (!empty($search))  $where .= " AND nama_bengkel LIKE '%$search%'";
if (!empty($status))  $where .= " AND status_kunjungan = '$status'";
if (!empty($sales))   $where .= " AND nama_sales = '$sales'";
if (!empty($dari))    $where .= " AND DATE(waktu_input) >= '$dari'";
if (!empty($sampai))  $where .= " AND DATE(waktu_input) <= '$sampai'";

$q_total = mysqli_query($conn, "SELECT COUNT(*) as total FROM tb_bengkel $where");
$total   = $q_total ? (int)mysqli_fetch_assoc($q_total)['total'] : 0;

$result = mysqli_query($conn, "SELECT nama_sales, nama_bengkel, status_kunjungan, catatan, waktu_input 
                         FROM tb_bengkel $where 
                         ORDER BY waktu_input DESC 
                         LIMIT $limit OFFSET $offset");
$kunjungan = [];
if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $kunjungan[] = $row;
    }
}

echo json_encode([
    "status"          => "success",
    "data_kunjungan"  => $kunjungan,
    "has_more"        => ($offset + $limit) < $total,
    "total"           => $total,
]);

mysqli_close($conn);
?>