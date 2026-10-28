import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    try {
      final data = await supabase.from('courses').select().order('id');
      return (data as List)
          .map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil course: ${e.message}');
    }
  }

  @override
  Future<Course> createCourse(Course course) async {
    try {
      final row = await supabase
          .from('courses')
          .insert(course.toJson())
          .select()
          .single();
      return Course.fromJson(row);
    } on PostgrestException catch (e) {
      // 23505 = unique violation (kolom code sudah dipakai)
      if (e.code == '23505') {
        throw Exception('Kode course sudah dipakai');
      }
      throw Exception('Gagal membuat course: ${e.message}');
    }
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    try {
      final updated = await supabase
          .from('courses')
          .update(course.toJson())
          .eq('id', id)
          .select();

      // Jika RLS menolak atau id tidak ada, Supabase tidak melempar error;
      // hasilnya hanya daftar kosong. Kita ubah menjadi error yang jelas.
      if ((updated as List).isEmpty) {
        throw Exception(
          'Course tidak ditemukan atau perubahan ditolak oleh policy',
        );
      }
    } on PostgrestException catch (e) {
      throw Exception('Gagal memperbarui course: ${e.message}');
    }
  }

  // Sementara, agar kelas tetap dapat dikompilasi.
  // Diimplementasikan pada Tahap 15.
  @override
  Future<void> deleteCourse(int id) => throw UnimplementedError();
}