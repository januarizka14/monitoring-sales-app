<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

// Total sales
$q_sales = mysqli_query($conn, "SELECT COUNT(*) as total FROM tb_users WHERE role = 'sales'");
$total_sales = $q_sales ? (int)mysqli_fetch_assoc($q_sales)['total'] : 0;

// Total kunjungan hari ini
$q_hari_ini = mysqli_query($conn, "SELECT COUNT(*) as total FROM tb_bengkel WHERE DATE(waktu_input) = CURDATE()");
$total_hari_ini = $q_hari_ini ? (int)mysqli_fetch_assoc($q_hari_ini)['total'] : 0;

// Total kunjungan keseluruhan
$q_total = mysqli_query($conn, "SELECT COUNT(*) as total FROM tb_bengkel");
$total_kunjungan = $q_total ? (int)mysqli_fetch_assoc($q_total)['total'] : 0;

// Total tugas pending
$q_pending = mysqli_query($conn, "SELECT COUNT(*) as total FROM tb_tasks WHERE status = 'pending'");
$total_pending = $q_pending ? (int)mysqli_fetch_assoc($q_pending)['total'] : 0;

// Total tugas done
$q_done = mysqli_query($conn, "SELECT COUNT(*) as total FROM tb_tasks WHERE status = 'done'");
$total_done = $q_done ? (int)mysqli_fetch_assoc($q_done)['total'] : 0;

// Ringkasan per sales — TOTAL KESELURUHAN (kunjungan & tugas, bukan hanya hari ini/pending)
$q_per_sales = mysqli_query($conn, "
    SELECT u.username,
           (SELECT COUNT(*) FROM tb_bengkel b WHERE b.nama_sales = u.username) as total_kunjungan_sales,
           (SELECT COUNT(*) FROM tb_tasks t WHERE t.username = u.username) as total_tugas_sales
    FROM tb_users u
    WHERE u.role = 'sales'
    ORDER BY total_kunjungan_sales DESC
");
$per_sales = [];
if ($q_per_sales) {
    while ($row = mysqli_fetch_assoc($q_per_sales)) {
        $per_sales[] = $row;
    }
}

echo json_encode([
    "status"           => "success",
    "total_sales"      => $total_sales,
    "total_hari_ini"   => $total_hari_ini,
    "total_kunjungan"  => $total_kunjungan,
    "total_pending"    => $total_pending,
    "total_done"       => $total_done,
    "per_sales"        => $per_sales,
]);

mysqli_close($conn);
?>