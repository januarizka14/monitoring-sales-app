# 📱 Monitoring Sales App

Aplikasi mobile berbasis **Flutter** untuk memantau aktivitas sales di lapangan, khususnya kunjungan ke bengkel-bengkel otomotif. Mendukung dua role pengguna: **Sales** dan **Admin**.

---

## 🛠️ Teknologi yang Digunakan

| Komponen | Teknologi |
|---|---|
| Mobile App | Flutter (Dart) |
| Backend API | PHP (procedural mysqli) |
| Database | MySQL |
| Local Server | XAMPP |

---

## 📋 Fitur Utama

### Sisi Sales
- Login & registrasi akun
- Dashboard dengan statistik kunjungan harian & total
- Form kunjungan bengkel (nama, status, catatan, GPS otomatis)
- Riwayat kunjungan dengan infinite scroll, search, dan filter (status & tanggal)
- Tab tugas — lihat dan selesaikan tugas yang diberikan admin

### Sisi Admin
- Dashboard ringkasan seluruh aktivitas sales
- Manajemen tugas — buat, lihat, hapus tugas per sales
- Monitoring kunjungan semua sales dengan filter per sales & status
- Manajemen user — lihat dan hapus akun sales

---

## 📁 Struktur Project
monitoring_sales_app/
├── lib/
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── daftar_screen.dart
│   │   ├── main_navigation.dart        # Navigasi Sales
│   │   ├── dashboard_tab.dart
│   │   ├── bengkel_tab.dart
│   │   ├── riwayat_tab.dart
│   │   ├── task_tab.dart
│   │   ├── admin_navigation.dart       # Navigasi Admin
│   │   ├── admin_dashboard_tab.dart
│   │   ├── admin_tugas_tab.dart
│   │   ├── admin_kunjungan_tab.dart
│   │   └── admin_users_tab.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── data_service.dart
│   └── main.dart
├── backend/
│   └── api_sales/
│       ├── koneksi.php
│       ├── login.php
│       ├── daftar.php
│       ├── ambil_dashboard.php
│       ├── ambil_riwayat.php
│       ├── ambil_tasks.php
│       ├── simpan_bengkel.php
│       ├── selesaikan_task.php
│       ├── ambil_dashboard_admin.php
│       ├── ambil_semua_tugas.php
│       ├── buat_tugas.php
│       ├── hapus_tugas.php
│       ├── ambil_semua_kunjungan.php
│       ├── ambil_semua_users.php
│       └── hapus_user.php
├── database/
│   └── db_sales_bengkel.sql            # Export database
└── README.md

---

## ⚙️ Cara Setup — Backend

### 1. Install XAMPP
Download dan install XAMPP dari [https://www.apachefriends.org](https://www.apachefriends.org)

### 2. Copy folder backend
Copy folder `backend/api_sales` ke dalam folder `htdocs` XAMPP:

### 3. Setup Database
1. Jalankan XAMPP, aktifkan **Apache** dan **MySQL**
2. Buka browser, akses [http://localhost/phpmyadmin](http://localhost/phpmyadmin)
3. Buat database baru bernama `db_sales_bengkel`
4. Klik tab **Import**
5. Pilih file `database/db_sales_bengkel.sql`
6. Klik **Go / Kirim**

### 4. Buat Akun Admin
Setelah database di-import, jalankan query ini di phpMyAdmin → tab SQL:
```sql
-- Daftar dulu lewat aplikasi dengan username "admin"
-- Lalu jalankan query ini untuk set role admin
UPDATE tb_users SET role = 'admin' WHERE username = 'admin';
```

---

## 📱 Cara Setup — Flutter

### Persyaratan
- [Flutter SDK](https://flutter.dev/docs/get-started/install) versi 3.0+
- [Android Studio](https://developer.android.com/studio) atau VS Code
- Android Emulator atau device fisik (Android)
- Java SDK 8+

### Langkah

**1. Clone repository**
```bash
git clone https://github.com/USERNAME/monitoring-sales-app.git
cd monitoring-sales-app
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Jalankan app**
```bash
# Pastikan emulator sudah berjalan atau device terhubung
flutter run
```

---

## 🔗 Konfigurasi URL API

File: `lib/services/data_service.dart` dan `lib/services/auth_service.dart`

```dart
static String get _baseUrl {
  if (kIsWeb) {
    return 'http://localhost/api_sales';       // Browser
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2/api_sales';        // Android Emulator
  } else {
    return 'http://localhost/api_sales';       // iOS / lainnya
  }
}
```

> ⚠️ Jika menggunakan **device fisik** (HP asli), ganti `10.0.2.2` dengan **IP lokal laptop** kamu (cek dengan `ipconfig` di Windows atau `ifconfig` di Mac/Linux). Contoh: `http://192.168.1.5/api_sales`

---

## 🗄️ Struktur Database

### `tb_users`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INT (PK, AI) | ID user |
| username | VARCHAR(50) | Username unik |
| password | VARCHAR(255) | Password ter-hash (BCRYPT) |
| waktu_daftar | DATETIME | Waktu registrasi |
| role | VARCHAR(10) | `sales` atau `admin` |

### `tb_bengkel`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INT (PK, AI) | ID kunjungan |
| nama_sales | VARCHAR(50) | Username sales |
| nama_bengkel | VARCHAR(100) | Nama bengkel yang dikunjungi |
| latitude | VARCHAR(20) | Koordinat GPS |
| longitude | VARCHAR(20) | Koordinat GPS |
| catatan | TEXT | Catatan tambahan |
| status_kunjungan | VARCHAR(20) | Sukses/Follow-up/Tutup/Ditolak |
| waktu_input | DATETIME | Waktu kunjungan |

### `tb_tasks`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INT (PK, AI) | ID tugas |
| username | VARCHAR(50) | Username sales yang ditugaskan |
| nama_bengkel | VARCHAR(100) | Target bengkel |
| deskripsi_tugas | TEXT | Detail tugas |
| deadline | DATE | Batas waktu (opsional) |
| status | VARCHAR(10) | `pending` atau `done` |
| created_at | DATETIME | Waktu tugas dibuat |

---

## 🎨 Design System

| Elemen | Nilai |
|---|---|
| Primary Blue | `#004AAD` |
| Accent Red | `#DB1607` |
| Background | `#F5F8FF` |
| Success Green | `#00A86B` |

---

## 🔐 Keamanan

- Password di-hash menggunakan **BCRYPT** (`password_hash` PHP)
- Semua query database menggunakan **prepared statement** atau `mysqli_real_escape_string`
- Validasi input di semua endpoint PHP
- Role-based routing — akun sales tidak bisa mengakses halaman admin

---

## 📦 Dependencies Flutter

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.0.0
  geolocator: ^10.0.0
  url_launcher: ^6.0.0
```

---

## 👤 Akun Default untuk Testing

| Role | Username | Password |
|---|---|---|
| Admin | admin | *(daftar sendiri, lalu update role)* |
| Sales | *(daftar lewat app)* | *(sesuai yang didaftarkan)* |

---