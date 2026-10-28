import 'package:flutter/material.dart';
import '../main.dart' show studentName, studentId, fetchCourses;
import '../models/course.dart';

class ApiDemoPage extends StatefulWidget {
  const ApiDemoPage({super.key});

  @override
  State<ApiDemoPage> createState() => _ApiDemoPageState();
}

class _ApiDemoPageState extends State<ApiDemoPage> {
  late Future<List<Course>> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<Course>> _load() async {
    final data = await fetchCourses();
    return data
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('API Demo - $studentId $studentName')),
      body: FutureBuilder<List<Course>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal: ${snapshot.error}'));
          }
          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final c = courses[index];
              return ListTile(
                title: Text(c.title),
                subtitle: Text('${c.code} • ${c.credits} SKS • id: ${c.id}'),
                trailing: Text(c.status),
              );
            },
          );
        },
      ),
    );
  }
}