import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show studentName, studentId;
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import 'course_form_page.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;
  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool showDetail = false;
  bool isDeleting = false;

  Future<void> _confirmAndDelete(Course course) async {
    if (isDeleting || course.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus course?'),
        content: Text('"${course.title}" (${course.code}) akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => isDeleting = true);

    try {
      await context.read<CourseProvider>().deleteCourse(course.id!);
      if (!mounted) return;
      // Bersihkan dari favorites agar tidak tersisa data yatim.
      context.read<CourseState>().removeFavorite(course.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${course.title} berhasil dihapus')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => isDeleting = false);
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil versi terbaru dari provider (setelah edit/refresh).
    final course = context.watch<CourseProvider>().courses.firstWhere(
          (c) => c.code == widget.course.code,
          orElse: () => widget.course,
        );

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: SingleChildScrollView(
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
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              onPressed: (course.id == null || isDeleting)
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseFormPage(course: course),
                        ),
                      );
                    },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete),
              label: Text(isDeleting ? 'Menghapus...' : 'Delete'),
              style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: (course.id == null || isDeleting)
                  ? null
                  : () => _confirmAndDelete(course),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.favorite),
              label: const Text('Tandai Favorite'),
              onPressed: isDeleting
                  ? null
                  : () {
                      context.read<CourseState>().toggleFavorite(course.code);
                      Navigator.pop(context, true);
                    },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(context),
              child: const Text('Kembali tanpa favorite'),
            ),
          ],
        ),
      ),
    );
  }
}