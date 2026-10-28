import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'providers/course_state.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';
import 'screens/root_shell.dart';

const String studentName = 'Gabriel Pranata Sembiring';
const String studentId = '2415051086';

const String apiUrl =
    'https://6ae18ec8be3bc8fead98ba30.mockapi.io/api/v1/courses';

Future<List<dynamic>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  }
  throw Exception('HTTP ${response.statusCode}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final data = await fetchCourses();
    debugPrint('$studentId - $studentName');
    debugPrint('GET berhasil: ${data.length} item');
    if (data.isNotEmpty) debugPrint('Item pertama: ${data.first}');
  } catch (e) {
    debugPrint('$studentId - $studentName');
    debugPrint('GET gagal: $e');
  }

  final repository = CourseRepository(CourseService());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseState()),
        ChangeNotifierProvider(
          create: (_) => CourseProvider(repository)..loadCourses(),
        ),
      ],
      child: const MyApp(),
    ),
  );
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