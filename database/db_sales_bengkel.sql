-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 02 Jul 2026 pada 05.00
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_sales_bengkel`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_bengkel`
--

CREATE TABLE `tb_bengkel` (
  `id` int(11) NOT NULL,
  `nama_bengkel` varchar(100) NOT NULL,
  `latitude` varchar(50) NOT NULL,
  `longitude` varchar(50) NOT NULL,
  `nama_sales` varchar(100) NOT NULL,
  `catatan` text DEFAULT NULL,
  `waktu_input` timestamp NOT NULL DEFAULT current_timestamp(),
  `status_kunjungan` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_bengkel`
--

INSERT INTO `tb_bengkel` (`id`, `nama_bengkel`, `latitude`, `longitude`, `nama_sales`, `catatan`, `waktu_input`, `status_kunjungan`) VALUES
(24, 'Mentari', '-6.2088', '106.8456', 'Jeno', 'negosiasi', '2026-06-25 08:46:38', 'Follow-up'),
(25, 'Trijaya', '-6.2088', '106.8456', 'Jeno', '', '2026-06-29 03:39:12', 'Tutup'),
(28, 'Citra abadi', '-6.2088', '106.8456', 'Jeno', '', '2026-06-29 07:05:00', 'Ditolak'),
(29, 'Adijaya', '-6.2088', '106.8456', 'Jeno', 'tidak ada', '2026-06-30 02:52:04', 'Sukses'),
(30, 'Adijaya', '-6.210932', '106.844973', 'karina', 'negosiasi', '2026-07-01 04:30:30', 'Follow-up');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_tasks`
--

CREATE TABLE `tb_tasks` (
  `id` int(11) NOT NULL,
  `username` varchar(50) DEFAULT NULL,
  `nama_bengkel` varchar(100) DEFAULT NULL,
  `deskripsi_tugas` text DEFAULT NULL,
  `deadline` date DEFAULT NULL,
  `status` varchar(10) DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_tasks`
--

INSERT INTO `tb_tasks` (`id`, `username`, `nama_bengkel`, `deskripsi_tugas`, `deadline`, `status`, `created_at`) VALUES
(11, 'Jeno', 'Trijaya', 'cek ketersediaan oli', '2026-07-01', 'done', '2026-06-30 02:30:11'),
(12, 'Jeno', 'Maju Jaya', 'cek oli mobil', NULL, 'done', '2026-06-30 02:36:50'),
(13, 'Karina', 'Sukses Motor', 'cek barang', NULL, 'done', '2026-06-30 07:01:19'),
(14, 'Karina', 'Adidaya', 'visit gudang', NULL, 'done', '2026-06-30 07:18:43'),
(15, 'Jeno', 'Maju Motor', 'ketersediaan barang', NULL, 'pending', '2026-06-30 07:22:57');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_users`
--

CREATE TABLE `tb_users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `waktu_daftar` timestamp NOT NULL DEFAULT current_timestamp(),
  `role` varchar(10) NOT NULL DEFAULT 'sales'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_users`
--

INSERT INTO `tb_users` (`id`, `username`, `password`, `waktu_daftar`, `role`) VALUES
(5, 'Jeno', '$2y$10$qkAYQ3w3NVBr8nnzgQXSa.cB3ien/OleBFQZ4P5mqIhiCQ6t3HpUC', '2026-06-29 07:17:05', 'sales'),
(7, 'admin', '$2y$10$F.AgbMDcDqxOUnwiJk.aDeZs9UpLSV.KkDKp1ikphYAQu36gfTSJS', '2026-06-29 07:35:31', 'admin'),
(8, 'Karina', '$2y$10$BY5/hNar/hcsqzjw210FOe7yEmGhVseTq9WGI8oRWuapsfY9dE7ZG', '2026-06-30 02:49:47', 'sales');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `tb_bengkel`
--
ALTER TABLE `tb_bengkel`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `tb_tasks`
--
ALTER TABLE `tb_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `username` (`username`);

--
-- Indeks untuk tabel `tb_users`
--
ALTER TABLE `tb_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `username_2` (`username`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `tb_bengkel`
--
ALTER TABLE `tb_bengkel`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT untuk tabel `tb_tasks`
--
ALTER TABLE `tb_tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT untuk tabel `tb_users`
--
ALTER TABLE `tb_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `tb_tasks`
--
ALTER TABLE `tb_tasks`
  ADD CONSTRAINT `tb_tasks_ibfk_1` FOREIGN KEY (`username`) REFERENCES `tb_users` (`username`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
