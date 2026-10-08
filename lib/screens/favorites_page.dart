import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show studentName, studentId;
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../widgets/course_tile.dart';
import 'course_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseState>();
    final allCourses = context.watch<CourseProvider>().courses;

    final favoriteCourses = allCourses
        .where((course) => courseState.isFavorite(course.code))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Favorites - $studentId $studentName')),
      body: favoriteCourses.isEmpty
          ? const Center(child: Text('Belum ada course favorite'))
          : ListView.builder(
              itemCount: favoriteCourses.length,
              itemBuilder: (context, index) {
                final course = favoriteCourses[index];
                return CourseTile(
                  course: course,
                  onOpenDetail: (course) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CourseDetailPage(course: course)),
                    );
                  },
                );
              },
            ),
    );
  }
}