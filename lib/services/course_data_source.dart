import '../models/course.dart';

/// Kontrak sumber data course. Repository hanya mengenal kontrak ini,
/// bukan implementasi konkret (REST, Supabase, dst).
abstract class CourseDataSource {
  Future<List<Course>> getCourses();
  Future<Course> createCourse(Course course);
  Future<void> updateCourse(int id, Course course);
  Future<void> deleteCourse(int id);
}