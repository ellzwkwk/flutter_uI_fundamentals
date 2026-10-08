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