import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const String studentName = 'Gabriel Pranata Sembiring';
const String studentId = '2415051086';

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString('assets/data/student_data.json');
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int selectedIndex = 0;

  static const List<Widget> pages = [
    HomeTab(),
    CoursesPage(),
    ProfileTab(),
  ];

  static const destinations = [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.school), label: 'Courses'),
    NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
  ];

  static const railDestinations = [
    NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
    NavigationRailDestination(icon: Icon(Icons.school), label: Text('Courses')),
    NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Scaffold(
            body: pages[selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() => selectedIndex = index);
              },
              destinations: destinations,
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => selectedIndex = index);
                },
                labelType: NavigationRailLabelType.all,
                destinations: railDestinations,
              ),
              const VerticalDivider(width: 1),
              Expanded(child: pages[selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Explorer')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.waving_hand, size: 48),
            const SizedBox(height: 12),
            Text('Selamat datang, $studentName'),
            Text(studentId),
          ],
        ),
      ),
    );
  }
}

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  static const List<Map<String, dynamic>> courses = [
    {'code': 'MOB01', 'title': 'Git & GitHub', 'credits': 2, 'status': 'done'},
    {'code': 'MOB02', 'title': 'Dart Fundamentals', 'credits': 2, 'status': 'done'},
    {'code': 'MOB03', 'title': 'Flutter UI Fundamentals', 'credits': 3, 'status': 'active'},
    {'code': 'MOB04', 'title': 'Navigation', 'credits': 2, 'status': 'planned'},
    {'code': 'MOB05', 'title': 'State Management', 'credits': 3, 'status': 'planned'},
  ];

  final Set<String> favoriteCodes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Courses - $studentId $studentName')),
      body: CourseListSection(
        courses: courses,
        favoriteCodes: favoriteCodes,
        onToggleFavorite: (code) {
          setState(() {
            if (favoriteCodes.contains(code)) {
              favoriteCodes.remove(code);
            } else {
              favoriteCodes.add(code);
            }
          });
        },
        onOpenDetail: (course) async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => CourseDetailPage(course: course)),
          );
          if (result == true && context.mounted) {
            setState(() => favoriteCodes.add(course['code'] as String));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${course['title']} ditandai favorite')),
            );
          }
        },
      ),
    );
  }
}

class CourseListSection extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final Set<String> favoriteCodes;
  final void Function(String code) onToggleFavorite;
  final void Function(Map<String, dynamic> course) onOpenDetail;

  const CourseListSection({
    super.key,
    required this.courses,
    required this.favoriteCodes,
    required this.onToggleFavorite,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    return CourseListBody(
      courses: courses,
      favoriteCodes: favoriteCodes,
      onToggleFavorite: onToggleFavorite,
      onOpenDetail: onOpenDetail,
    );
  }
}

class CourseListBody extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final Set<String> favoriteCodes;
  final void Function(String code) onToggleFavorite;
  final void Function(Map<String, dynamic> course) onOpenDetail;

  const CourseListBody({
    super.key,
    required this.courses,
    required this.favoriteCodes,
    required this.onToggleFavorite,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final String code = course['code'] as String;
        final bool isFavorite = favoriteCodes.contains(code);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(course['title'] as String),
            subtitle: Text('${course['code']} • ${course['credits']} SKS'),
            onTap: () => onOpenDetail(course),
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => onToggleFavorite(code),
            ),
          ),
        );
      },
    );
  }
}

class CourseDetailPage extends StatefulWidget {
  final Map<String, dynamic> course;
  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool showDetail = false; // local state: hanya dipakai halaman ini

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      appBar: AppBar(title: Text(course['title'] as String)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course['title'] as String,
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
              Text('Kode: ${course['code']}'),
              Text('${course['credits']} SKS'),
              Text('Status: ${course['status']}'),
            ],
            const SizedBox(height: 24),
            Text('$studentId - $studentName'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.favorite),
              label: const Text('Tandai Favorite'),
              onPressed: () {
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

int columnsFor(double width) {
  if (width < 600) return 1;
  if (width < 840) return 2;
  return 3;
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: studentName);
  final nimController = TextEditingController(text: studentId);
  final commentController = TextEditingController();

  String? submittedComment;
  bool isSubmitting = false;

  @override
  void dispose() {
    nameController.dispose();
    nimController.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    if (!formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Kirim feedback sekarang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      isSubmitting = false;
      submittedComment = commentController.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 46,
              backgroundImage: AssetImage('assets/images/profile.jpeg'),
            ),
            const SizedBox(height: 16),
            Text('Feedback Form', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nimController,
                    decoration: const InputDecoration(labelText: 'NIM'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'NIM wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: commentController,
                    decoration: const InputDecoration(labelText: 'Komentar'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().length < 5) {
                        return 'Komentar minimal 5 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : handleSubmit,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Kirim Feedback'),
                  ),
                ],
              ),
            ),
            if (submittedComment != null) ...[
              const SizedBox(height: 16),
              Text('Feedback tersimpan: $submittedComment'),
            ],
          ],
        ),
      ),
    );
  }
}