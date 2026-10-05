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
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  Widget buildSummaryCard(String value, String label, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCourseTile(Map<String, dynamic> course) {
    final String status = course['status'] as String;
    late final IconData icon;
    late final Color color;
    late final String label;
    switch (status) {
      case 'done':
        icon = Icons.check_circle;
        color = Colors.green;
        label = 'Selesai';
        break;
      case 'active':
        icon = Icons.play_circle;
        color = Colors.orange;
        label = 'Berjalan';
        break;
      default:
        icon = Icons.schedule;
        color = Colors.grey;
        label = 'Rencana';
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(course['title'] as String),
        subtitle: Text('${course['code']} • ${course['credits']} SKS'),
        trailing: Text(label, style: TextStyle(color: color)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: studentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final student = data['student'] as Map<String, dynamic>;
          final courses = (data['courses'] as List<dynamic>).cast<Map<String, dynamic>>();
          final int totalSks = courses.fold<int>(0, (sum, c) => sum + (c['credits'] as int));
          final int completed = courses.where((c) => c['status'] == 'done').length;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundImage: AssetImage('assets/images/profile.jpeg'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student['name'] as String,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(student['nim'] as String),
                              Text('Kelas ${student['kelas']}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    buildSummaryCard('${courses.length}', 'Materi', Icons.menu_book),
                    const SizedBox(width: 8),
                    buildSummaryCard('$totalSks', 'Total SKS', Icons.school),
                    const SizedBox(width: 8),
                    buildSummaryCard('$completed/${courses.length}', 'Selesai', Icons.check_circle),
                  ],
                ),
                const SizedBox(height: 16),
                const GreetingCard(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) => buildCourseTile(courses[index]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GreetingCard extends StatefulWidget {
  const GreetingCard({super.key});

  @override
  State<GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<GreetingCard> {
  final TextEditingController controller = TextEditingController();
  String message = 'Belum ada pesan';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$studentId - $studentName'),
        TextField(controller: controller),
        ElevatedButton(
          onPressed: () {
            setState(() {
              message = controller.text.trim().isEmpty
                  ? 'Input masih kosong'
                  : controller.text.trim();
            });
          },
          child: const Text('Tampilkan'),
        ),
        Text(message),
      ],
    );
  }
}