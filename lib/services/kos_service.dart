import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KosService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid => _client.auth.currentUser!.id;

  Future<List<Map<String, dynamic>>> fetchAll() async {
    final data = await _client
        .from('kos')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> add({
    required String name,
    required String address,
    required int price,
  }) async {
    await _client.from('kos').insert({
      'owner_id': _uid,
      'name': name,
      'address': address,
      'price': price,
    });
  }

  /// true = berhasil, false = ditolak RLS / data tidak ditemukan
  Future<bool> update(String id, Map<String, dynamic> values) async {
    final rows =
        await _client.from('kos').update(values).eq('id', id).select();
    return rows.isNotEmpty;
  }

  /// true = berhasil, false = ditolak RLS / data tidak ditemukan
  Future<bool> delete(String id) async {
    final rows = await _client.from('kos').delete().eq('id', id).select();
    return rows.isNotEmpty;
  }
}

/// Fungsi pengujian keamanan Praktik 6
Future<String> runSecurityTest(String kosIdMilikUserA) async {
  final kos = KosService();
  final buffer = StringBuffer();

  // 1. User B mencoba mengubah data User A -> harus DENIED
  final updated = await kos.update(kosIdMilikUserA, {'name': 'DIUBAH USER B'});
  final resUpdate = updated
      ? '[FAIL] User B berhasil mengubah data User A'
      : '[PASS] UPDATE ditolak oleh RLS (0 rows affected)';
  debugPrint(resUpdate);
  buffer.writeln(resUpdate);

  // 2. User B mencoba menghapus data User A -> harus DENIED
  final deleted = await kos.delete(kosIdMilikUserA);
  final resDelete = deleted
      ? '[FAIL] User B berhasil menghapus data User A'
      : '[PASS] DELETE ditolak oleh RLS (0 rows affected)';
  debugPrint(resDelete);
  buffer.writeln(resDelete);

  // 3. User B mencoba INSERT atas nama User A -> harus ERROR 42501
  try {
    await Supabase.instance.client.from('kos').insert({
      'owner_id': '00000000-0000-0000-0000-000000000000',
      'name': 'Kos palsu atas nama user lain',
    });
    const resInsert = '[FAIL] INSERT atas nama user lain berhasil';
    debugPrint(resInsert);
    buffer.writeln(resInsert);
  } on PostgrestException catch (e) {
    final resInsert = '[PASS] INSERT ditolak RLS: ${e.code} - ${e.message}';
    debugPrint(resInsert);
    buffer.writeln(resInsert);
  }

  return buffer.toString();
}
