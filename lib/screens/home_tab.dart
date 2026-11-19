import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/notification_service.dart';
import '../widgets/role_guard.dart';
import '../pages/login_page.dart';
import '../pages/security_test_page.dart';
import 'course_form_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();

    // Inisialisasi push notification setelah frame selesai dirender
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await NotificationService.instance.init();
        await NotificationService.instance.setupInteractedMessage();
      } catch (e) {
        debugPrint('Notification setup error (FCM belum aktif): $e');
      }
    });
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final p = snap.data;
        final currentRole = p?.role ?? 'seeker';

        return Scaffold(
          appBar: AppBar(
            title: Text('Course & KosFinder (${currentRole.toUpperCase()})'),
            actions: [
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(
                          (p?.name != null && p!.name.isNotEmpty)
                              ? p.name
                              : (p?.email ?? 'Pengguna'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${p?.email ?? '-'} • Role: $currentRole'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const ListTile(
                leading: Icon(Icons.list_alt),
                title: Text('Daftar Course / Kos'),
                subtitle: Text('Dapat dilihat oleh semua pengguna (Seeker & Owner)'),
              ),
              if (currentRole == 'owner' || currentRole == 'admin')
                const ListTile(
                  leading: Icon(Icons.home_work),
                  title: Text('Kelola Course / Kos Milik Saya'),
                  subtitle: Text('Khusus Pemilik (Owner & Admin)'),
                ),
              if (currentRole == 'admin')
                const ListTile(
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text('Menu Kelola Seluruh Data (Admin)'),
                  subtitle: Text('Hak akses penuh sistem'),
                ),
              const Divider(height: 32),
              // Tombol pengujian keamanan Praktik 6
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SecurityTestPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.security),
                label: const Text('Buka Halaman Uji Keamanan (RLS Testing)'),
              ),
            ],
          ),
          // Praktik 4: Tombol Tambah hanya tampil untuk Owner / Admin
          floatingActionButton: RoleGuard(
            role: currentRole,
            allowed: const ['owner', 'admin'],
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CourseFormPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Course'),
            ),
          ),
        );
      },
    );
  }
}
