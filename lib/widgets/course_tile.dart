import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_state.dart';

class CourseTile extends StatelessWidget {
  final Course course;
  final void Function(Course course) onOpenDetail;

  const CourseTile({
    super.key,
    required this.course,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(course.title),
        subtitle: Text('${course.code} • ${course.credits} SKS'),
        onTap: () => onOpenDetail(course),
        trailing: Consumer<CourseState>(
          builder: (context, state, child) {
            final bool isFavorite = state.isFavorite(course.code);
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                context.read<CourseState>().toggleFavorite(course.code);
              },
            );
          },
        ),
      ),
    );
  }
}