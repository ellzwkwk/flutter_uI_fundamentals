import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show studentName, studentId;
import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseFormPage extends StatefulWidget {
  final Course? course; // null = tambah baru, ada isi = edit

  const CourseFormPage({super.key, this.course});

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  static const List<String> statuses = ['planned', 'active', 'done'];

  final formKey = GlobalKey<FormState>();
  late final TextEditingController codeController;
  late final TextEditingController titleController;
  late final TextEditingController creditsController;

  late String status;
  bool isSaving = false;

  bool get isEdit => widget.course != null;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    codeController = TextEditingController(text: c?.code ?? '');
    titleController = TextEditingController(text: c?.title ?? '');
    creditsController = TextEditingController(text: c?.credits.toString() ?? '');
    status = statuses.contains(c?.status) ? c!.status : 'planned';
  }

  @override
  void dispose() {
    codeController.dispose();
    titleController.dispose();
    creditsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (!formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final course = Course(
      id: widget.course?.id,
      code: codeController.text.trim(),
      title: titleController.text.trim(),
      credits: int.parse(creditsController.text.trim()),
      status: status,
    );

    try {
      final provider = context.read<CourseProvider>();
      if (isEdit) {
        await provider.updateCourse(widget.course!.id!, course);
      } else {
        await provider.createCourse(course);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Course berhasil diperbarui' : 'Course berhasil ditambahkan',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Course' : 'Tambah Course')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$studentId - $studentName'),
              const SizedBox(height: 16),
              TextFormField(
                controller: codeController,
                enabled: !isSaving,
                readOnly: isEdit,
                decoration: InputDecoration(
                  labelText: 'Kode (contoh: MOB06)',
                  helperText: isEdit ? 'Kode tidak dapat diubah' : null,
                  filled: isEdit,
                ),
                validator: (value) {
                  final code = value?.trim() ?? '';
                  if (code.isEmpty) return 'Kode wajib diisi';
                  if (!isEdit) {
                    final exists = context
                        .read<CourseProvider>()
                        .courses
                        .any((c) => c.code.toLowerCase() == code.toLowerCase());
                    if (exists) return 'Kode sudah dipakai';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: titleController,
                enabled: !isSaving,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: creditsController,
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Credits (SKS)'),
                validator: (value) {
                  final credits = int.tryParse(value?.trim() ?? '');
                  if (credits == null) return 'Credits harus berupa angka';
                  if (credits <= 0) return 'Credits harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) setState(() => status = value);
                      },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : _submit,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(isSaving ? 'Menyimpan...' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}