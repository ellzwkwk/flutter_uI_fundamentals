# Course Explorer v2

Aplikasi Flutter untuk menjelajahi daftar mata kuliah, dengan state management
menggunakan Provider dan arsitektur berlapis.

## Struktur Folder

- **lib/models/** — representasi data (`Course`), termasuk parsing JSON lewat `fromJson()`. Tidak berisi logic bisnis atau UI.
- **lib/services/** — detail teknis akses sumber data (baca asset JSON lewat `rootBundle`). Bisa diganti ke REST API tanpa mengubah layer di atasnya.
- **lib/repositories/** — lapisan abstraksi antara Provider dan Service. Menyediakan API data sederhana (`getCourses()`) tanpa mengekspos detail implementasi sumber data.
- **lib/providers/** — state holder (`ChangeNotifier`). `CourseProvider` mengelola courses/loading/error async; `CourseState` mengelola favorites (shared state lintas screen).
- **lib/screens/** — halaman penuh (`Scaffold`), masing-masing mewakili satu route/tab aplikasi.
- **lib/widgets/** — komponen UI reusable yang dipakai lebih dari satu screen (`CourseTile`).

## Arah Dependency

Screen/Widget → Provider → Repository → Service/Data Source

UI tidak pernah memanggil `rootBundle`/`jsonDecode` secara langsung; semua akses data melewati Provider yang memanggil Repository yang memanggil Service.

## REST Endpoint

- **Base URL:** https://6ae18ec8be3bc8fead98ba30.mockapi.io/api/v1
- **Endpoint:** /courses
- **Method:** GET
- **Status code:** 200 OK
- **Field JSON:** id, code, title, credits, status

Contoh response:

    {
      "id": "1",
      "code": "MOB01",
      "title": "Git & GitHub",
      "credits": 2,
      "status": "done"
    }

## Database (Supabase)

Tabel `courses` didefinisikan di `supabase/schema.sql`.

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint identity | Primary key |
| code | text | Unik, dipakai sebagai kunci favorites |
| title | text | Judul course |
| credits | int | Harus lebih dari 0 |
| status | text | planned / active / done |
| created_at | timestamptz | Otomatis |

RLS aktif dengan policy permisif khusus praktikum lab.
Policy ini bukan pola produksi.