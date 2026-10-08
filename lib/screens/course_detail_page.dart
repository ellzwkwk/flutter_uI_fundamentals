import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show studentName, studentId;
import '../models/course.dart';
import '../providers/course_state.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;
  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool showDetail = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: Icon(showDetail ? Icons.expand_less : Icons.expand_more),
              label: Text(showDetail ? 'Sembunyikan detail' : 'Tampilkan detail'),
              onPressed: () {
                setState(() => showDetail = !showDetail);
              },
            ),
            if (showDetail) ...[
              Text('Kode: ${course.code}'),
              Text('${course.credits} SKS'),
              Text('Status: ${course.status}'),
            ],
            const SizedBox(height: 24),
            Text('$studentId - $studentName'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.favorite),
              label: const Text('Tandai Favorite'),
              onPressed: () {
                context.read<CourseState>().toggleFavorite(course.code);
                Navigator.pop(context, true);
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali tanpa favorite'),
            ),
          ],
        ),
      ),
    );
  }
}