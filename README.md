# Perpustakaan API — Laravel 12

REST API untuk manajemen perpustakaan berbasis **Laravel 12**, dilengkapi otentikasi **Laravel Sanctum**, CRUD data buku, validasi Form Request, Resource JSON transformer, pengujian otomatis PHPUnit, serta dokumentasi OpenAPI interaktif menggunakan **L5-Swagger**.

---

## 📌 Fitur Utama

- **Otentikasi API (Sanctum)**: Register, Login (Throttle protection), Me (profil), dan Logout (token revoke).
- **CRUD Buku Lengkap**:
  - `GET /api/books`: Daftar buku berpaginasi (10/halaman) + pencarian judul/penulis.
  - `POST /api/books`: Tambah buku baru dengan validasi ISBN unik.
  - `GET /api/books/{book}`: Detail satu buku.
  - `PUT/PATCH /api/books/{book}`: Ubah data buku (mendukung pembaruan parsial).
  - `DELETE /api/books/{book}`: Hapus buku.
- **Respon Konsisten**: Semua respons API dipaksa selalu berformat JSON (`shouldRenderJsonWhen`).
- **Dokumentasi OpenAPI 3.0 (Swagger UI)**: Pengujian endpoint langsung dari browser dengan otentikasi Bearer.
- **Pengujian Otomatis**: 10 test (53 assertions) mencakup autentikasi dan seluruh operasi CRUD.

---

## 🚀 Prasyarat Sistem

- PHP >= 8.2 (disarankan PHP 8.3 dengan ekstensi `pdo_mysql`, `pdo_sqlite`, `mbstring`, `openssl`, `curl`)
- Composer 2.x
- MySQL / MariaDB (misal: Laragon / XAMPP)

---

## ⚙️ Panduan Instalasi & Menjalankan Proyek

### 1. Clone Repositori
```bash
git clone <url-repository>
cd perpus-api
```

### 2. Pasang Dependensi
```bash
composer install
```

### 3. Konfigurasi Lingkungan (`.env`)
Salin file `.env.example` menjadi `.env`:
```bash
cp .env.example .env
```
Generate App Key:
```bash
php artisan key:generate
```
Pastikan pengaturan database di `.env` sudah sesuai (misal menggunakan MySQL Laragon):
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=perpus_api
DB_USERNAME=root
DB_PASSWORD=

APP_URL=http://localhost:8000
L5_SWAGGER_CONST_HOST=http://localhost:8000
L5_SWAGGER_GENERATE_ALWAYS=true
```
> *Catatan: Buat database `perpus_api` terlebih dahulu di MySQL/HeidiSQL/phpMyAdmin.*

### 4. Migrasi & Seeder Database
Jalankan migrasi sekaligus seeder untuk membuat tabel dan data awal:
```bash
php artisan migrate:fresh --seed
```

### 5. Generate Dokumentasi Swagger
```bash
php artisan l5-swagger:generate
```

### 6. Jalankan Server Pengembangan
```bash
php artisan serve
```
Aplikasi aktif di: `http://localhost:8000`

---

## 📖 Mengakses Dokumentasi Swagger UI

Buka di browser:
- **Swagger UI**: [http://localhost:8000/api/documentation](http://localhost:8000/api/documentation)
- **OpenAPI JSON Spec**: [http://localhost:8000/docs](http://localhost:8000/docs)

### 🔑 Akun Demo:
- **Email**: `admin@example.com`
- **Password**: `password`

### 💡 Cara Menguji di Swagger UI:
1. Buka tag **Auth** &rarr; **POST /api/login**.
2. Klik **Try it out**, gunakan kredensial demo di atas, lalu klik **Execute**.
3. Salin nilai `token` dari respons (contoh: `1|Xz9aBcDeFgHi...`).
4. Klik tombol **Authorize** (ikon gembok hijau di kanan atas).
5. Tempelkan token tersebut di kolom isian (tanpa kata "Bearer"), lalu klik **Authorize** &rarr; **Close**.
6. Anda sekarang dapat mencoba semua endpoint yang membutuhkan login (grup **Books** dan **GET /api/me**).

---

## 🧪 Menjalankan Pengujian (Testing)

Pengujian otomatis menggunakan database SQLite in-memory:
```bash
php artisan test
```
Seluruh 10 test (Feature & Unit) mencakup:
- `AuthApiTest`: Registrasi user, login sukses & gagal validasi password, pencabutan token saat logout.
- `BookApiTest`: Proteksi guest, paginasi & pencarian buku, validasi store/update, show, dan delete.

---

## 📂 Laporan Hasil Uji & Dokumentasi

Dokumentasi hasil pengujian visual lengkap tersedia di:
- **PDF Laporan Uji**: [`docs/Hasil-Uji-API.pdf`](docs/Hasil-Uji-API.pdf)
- **Tangkapan Layar Tiap Endpoint**: Folder [`docs/screenshots/`](docs/screenshots/)

---

## 📜 Lisensi
Proyek ini dibuat untuk keperluan pembelajaran dan pengembangan REST API Laravel. Lisensi di bawah [MIT License](LICENSE).
