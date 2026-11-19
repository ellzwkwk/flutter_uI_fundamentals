import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_keys.dart';
import '../pages/kos_detail_page.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[BACKGROUND] ${message.notification?.title}');
  debugPrint('[BACKGROUND] ${message.notification?.body}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Meminta izin notifikasi dan mengembalikan statusnya (Praktik 8)
  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus.name}');
    return settings.authorizationStatus;
  }

  /// Mendapatkan FCM Token (Praktik 9)
  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    return token;
  }

  /// Mendengarkan pembaruan token
  void listenTokenRefresh(void Function(String token) onRefresh) {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token diperbarui: $newToken');
      onRefresh(newToken);
    });
  }

  /// Opsional: Simpan token ke Supabase (Praktik 9)
  Future<void> saveTokenToSupabase(String token) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      await Supabase.instance.client.from('device_tokens').upsert({
        'token': token,
        'user_id': user.id,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('FCM Token berhasil disimpan ke Supabase');
    } catch (e) {
      debugPrint('Gagal menyimpan token ke Supabase: $e');
    }
  }

  /// Inisialisasi notifikasi (Praktik 10)
  Future<void> init() async {
    await requestPermission();
    final token = await getToken();
    if (token != null) {
      await saveTokenToSupabase(token);
    }
    listenTokenRefresh(saveTokenToSupabase);

    // iOS Foreground presentation
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // FOREGROUND: Pesan masuk saat aplikasi terbuka
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FOREGROUND] Notification received');
      debugPrint('title: ${message.notification?.title}');
      debugPrint('body : ${message.notification?.body}');
      debugPrint('data : ${message.data}');

      final title = message.notification?.title ?? 'Notifikasi';
      final body = message.notification?.body ?? '';
      messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('$title\n$body'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Lihat',
            onPressed: () => _handleTap(message),
          ),
        ),
      );
    });
  }

  /// Menangani interaksi notifikasi saat di-tap (Bonus)
  Future<void> setupInteractedMessage() async {
    // Aplikasi TERMINATED lalu dibuka dari notifikasi
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleTap(initial);

    // Aplikasi BACKGROUND lalu dibuka dari notifikasi
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
  }

  void _handleTap(RemoteMessage message) {
    final kosId = message.data['kos_id'] ?? message.data['id'];
    if (kosId == null) return;

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => KosDetailPage(kosId: kosId.toString()),
      ),
    );
  }
}
