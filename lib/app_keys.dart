import 'package:flutter/material.dart';

/// Key global agar navigasi/snackbar bisa dipanggil dari luar widget
/// (dipakai juga pada notifikasi FCM).
final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();
