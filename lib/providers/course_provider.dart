import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';
import '../utils/error_message.dart';

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
      error = friendlyError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Exception diteruskan ke form/detail dengan pesan yang sudah ramah,
  // sehingga SnackBar tidak menampilkan teks teknis.
  Future<void> createCourse(Course course) async {
    try {
      await repository.createCourse(course);
    } catch (e) {
      throw Exception(friendlyError(e));
    }
    await loadCourses();
  }

  Future<void> updateCourse(int id, Course course) async {
    try {
      await repository.updateCourse(id, course);
    } catch (e) {
      throw Exception(friendlyError(e));
    }
    await loadCourses();
  }

  Future<void> deleteCourse(int id) async {
    try {
      await repository.deleteCourse(id);
    } catch (e) {
      throw Exception(friendlyError(e));
    }
    await loadCourses();
  }
}