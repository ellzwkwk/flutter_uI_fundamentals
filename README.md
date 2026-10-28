# Course Data Manager

Aplikasi Flutter untuk mengelola data mata kuliah (course) dengan operasi
lengkap tambah, lihat, ubah, dan hapus. Aplikasi ini adalah pengembangan dari
**Course Explorer v2** (Pertemuan 5-6), bukan aplikasi baru.

- **Nama:** Gabriel Pranata Sembiring
- **NIM:** 2415051086
- **Kelas:** PTI-5C

## Fitur

- Daftar course dari database, dengan state loading, empty, error, dan retry
- Tambah course (form dengan validasi), edit course, hapus course dengan konfirmasi
- Halaman detail, serta favorites yang memakai `code` sebagai kunci
- Navigasi responsif: `NavigationBar` di layar sempit, `NavigationRail` di layar lebar
- Umpan balik lewat SnackBar untuk operasi berhasil maupun gagal

## Backend yang Digunakan

- **Supabase** (PostgreSQL) sebagai sumber data utama aplikasi final.
- **REST API (MockAPI)** tetap tersedia sebagai data source alternatif.
  Kedua sumber data dapat ditukar hanya dengan mengubah satu baris di `lib/main.dart`.

## Arsitektur

```
Screen / Widget  ->  Provider  ->  Repository  ->  DataSource (kontrak)
                                                      |-- CourseSupabaseService
                                                      |-- CourseApiService
```

| Folder | Tanggung jawab |
|---|---|
| `lib/models/` | Model `Course`, termasuk `fromJson()` dan `toJson()` |
| `lib/services/` | Kontrak `CourseDataSource` dan implementasinya (Supabase dan REST) |
| `lib/repositories/` | `CourseRepository`, abstraksi akses data untuk provider |
| `lib/providers/` | `CourseProvider` (courses, loading, error) dan `CourseState` (favorites) |
| `lib/screens/` | Halaman: shell navigasi, daftar, detail, form, favorites, profil |
| `lib/widgets/` | Komponen reusable: `CourseTile`, `ErrorView` |
| `lib/config/` | Konfigurasi client Supabase (hanya key publishable/anon) |
| `lib/utils/` | Penerjemah error teknis menjadi pesan ramah |
| `supabase/` | `schema.sql`, definisi tabel dan kebijakan RLS |

Provider hanya berkomunikasi dengan repository, dan screen tidak memanggil
package `http` maupun Supabase secara langsung.

## Cara Menjalankan

1. Pastikan Flutter SDK sudah terpasang, lalu ambil dependency:

   ```bash
   flutter pub get
   ```

2. Siapkan project Supabase, lalu jalankan isi `supabase/schema.sql` di SQL Editor
   untuk membuat tabel `courses`, data awal, dan kebijakan RLS.

3. Isi `lib/config/supabase_config.dart` dengan Project URL dan key
   **publishable/anon** dari project Anda.

4. Jalankan aplikasi:

   ```bash
   flutter run
   ```

   Untuk menguji layout lebar, gunakan `flutter run -d chrome`.

## Mengganti Sumber Data

Di `lib/main.dart`, pilih satu data source:

```dart
// Supabase (aktif)
final CourseDataSource dataSource = CourseSupabaseService();

// REST API
// final CourseDataSource dataSource = CourseApiService(apiBaseUrl);
```

## REST Endpoint (Tahap 1-9)

- **Base URL:** `https://6ae18ec8be3bc8fead98ba30.mockapi.io/api/v1`
- **Resource:** `/courses` (GET, POST, PUT `/courses/:id`, DELETE `/courses/:id`)
- **Field JSON:** `id`, `code`, `title`, `credits`, `status`

Contoh response:

```json
{
  "id": "1",
  "code": "MOB01",
  "title": "Git & GitHub",
  "credits": 2,
  "status": "done"
}
```

MockAPI mengirim `id` sebagai string, sehingga `Course.fromJson()` mengonversinya
menjadi integer.

## Database (Supabase)

Tabel `courses` didefinisikan di `supabase/schema.sql`.

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint identity | Primary key |
| code | text | Unik, dipakai sebagai kunci favorites |
| title | text | Judul course |
| credits | int | Harus lebih dari 0 |
| status | text | `planned`, `active`, atau `done` |
| created_at | timestamptz | Diisi otomatis |

## Keamanan

- Aplikasi hanya memakai key **publishable/anon**. Key secret atau `service_role`
  tidak digunakan dan tidak disimpan di repository.
- Kebijakan RLS pada `schema.sql` bersifat permisif dan **hanya untuk praktikum
  laboratorium**. Pada aplikasi produksi, kebijakan harus mensyaratkan autentikasi
  dan pengecekan kepemilikan data.
- Validasi di UI bukan pengganti validasi di backend. Constraint `unique` dan
  `check` pada tabel tetap menjadi lapisan terakhir.