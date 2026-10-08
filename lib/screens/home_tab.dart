import 'package:flutter/material.dart';
import '../main.dart' show studentName, studentId;

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