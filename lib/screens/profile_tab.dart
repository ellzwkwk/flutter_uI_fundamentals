import 'package:flutter/material.dart';
import '../main.dart' show studentName, studentId;

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