import 'package:flutter/material.dart';
import '../services/kos_service.dart';

class SecurityTestPage extends StatefulWidget {
  const SecurityTestPage({super.key});

  @override
  State<SecurityTestPage> createState() => _SecurityTestPageState();
}

class _SecurityTestPageState extends State<SecurityTestPage> {
  final _idController = TextEditingController();
  String _testResult = '';
  bool _isLoading = false;

  Future<void> _executeTest() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan ID kos target milik User A')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await runSecurityTest(id);
    setState(() {
      _testResult = result;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Testing (RLS)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Uji Row Level Security (RLS)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Login sebagai User B, lalu masukkan UUID Kos milik User A untuk menguji apakah UPDATE, DELETE, dan INSERT atas nama orang lain ditolak oleh database.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'UUID Kos Milik User A',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isLoading ? null : _executeTest,
              icon: const Icon(Icons.security),
              label: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Jalankan Security Test'),
            ),
            const SizedBox(height: 24),
            if (_testResult.isNotEmpty) ...[
              const Text(
                'Hasil Pengujian:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _testResult,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
