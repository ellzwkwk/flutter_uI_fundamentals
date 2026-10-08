import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/course_state.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';
import 'screens/root_shell.dart';

const String studentName = 'Gabriel Pranata Sembiring';
const String studentId = '2415051086';

void main() {
  final repository = CourseRepository(CourseService());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseState()),
        ChangeNotifierProvider(create: (_) => CourseProvider(repository)..loadCourses()),
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