/// Mengubah exception teknis menjadi pesan yang mudah dipahami pengguna.
String friendlyError(Object e) {
  final text = e.toString();

  if (e is TypeError || e is FormatException) {
    return 'Format data dari server tidak sesuai: $text';
  }

  const networkMarkers = [
    'SocketException',
    'ClientException',
    'Failed host lookup',
    'Failed to fetch',
    'XMLHttpRequest',
    'Connection refused',
    'Network is unreachable',
  ];
  if (networkMarkers.any((m) => text.contains(m))) {
    return 'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.';
  }

  return text.replaceFirst('Exception: ', '');
}