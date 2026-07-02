<?php
$conn = mysqli_connect("localhost", "root", "", "db_sales_bengkel");

if (!$conn) {
    header("Content-Type: application/json");
    die(json_encode(["status" => "error", "message" => "Koneksi database gagal: " . mysqli_connect_error()]));
}
mysqli_set_charset($conn, "utf8");
?>
