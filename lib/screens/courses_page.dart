import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show studentName, studentId;
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../widgets/course_tile.dart';
import '../widgets/error_view.dart';
import 'course_detail_page.dart';
import 'course_form_page.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  Widget _buildBody(BuildContext context, CourseProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return ErrorView(
        message: provider.error!,
        onRetry: provider.loadCourses,
      );
    }

    if (provider.courses.isEmpty) {
      return const Center(child: Text('Data course belum tersedia'));
    }

    return ListView.builder(
      itemCount: provider.courses.length,
      itemBuilder: (context, index) {
        final Course course = provider.courses[index];
        return CourseTile(
          course: course,
          onOpenDetail: (course) async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailPage(course: course),
              ),
            );
            if (result == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${course.title} ditandai favorite')),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteCount = context.watch<CourseState>().favorites.length;
    final courseProvider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Courses - $studentId $studentName'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.favorite, size: 18),
                  const SizedBox(width: 4),
                  Text('$favoriteCount'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(context, courseProvider),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah course',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CourseFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}