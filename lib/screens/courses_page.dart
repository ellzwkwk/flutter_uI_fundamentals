import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show studentName, studentId;
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../widgets/course_tile.dart';
import 'course_detail_page.dart';
import 'value_notifier_demo_page.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteCount = context.watch<CourseState>().favorites.length;
    final courseProvider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Courses - $studentId $studentName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.science_outlined),
            tooltip: 'ValueNotifier Demo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ValueNotifierDemoPage()),
              );
            },
          ),
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
      body: Builder(
        builder: (context) {
          if (courseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (courseProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Gagal memuat data: ${courseProvider.error}'),
              ),
            );
          }

          final courses = courseProvider.courses;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final Course course = courses[index];
              return CourseTile(
                course: course,
                onOpenDetail: (course) async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (context) => CourseDetailPage(course: course)),
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
        },
      ),
    );
  }
}