import 'package:flutter/material.dart';
import '../main.dart' show studentName, studentId;

class ValueNotifierDemoPage extends StatelessWidget {
  ValueNotifierDemoPage({super.key});

  final ValueNotifier<int> favoriteCount = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ValueNotifier Demo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$studentId - $studentName'),
            const SizedBox(height: 16),
            const Text('Jumlah favorite (demo):'),
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: favoriteCount,
              builder: (context, value, child) {
                return Text(
                  '$value',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => favoriteCount.value++,
                  child: const Text('+ Favorite'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (favoriteCount.value > 0) favoriteCount.value--;
                  },
                  child: const Text('- Favorite'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}