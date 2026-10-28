import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> courses = [];
  bool isLoading = false;
  String? error;

  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Jika POST gagal, exception diteruskan ke pemanggil (form)
  // agar form bisa menampilkan SnackBar error.
  Future<void> createCourse(Course course) async {
    await repository.createCourse(course);
    await loadCourses(); // ganti isi list dari server, bukan menambah manual
  }
}