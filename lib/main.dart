import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'app/app.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureDesktopWindow();

  await ApiService.init();
  await AuthService.loadSavedProfile();

  runApp(const MyApp());
}

Future<void> _configureDesktopWindow() async {
  if (kIsWeb || !(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    return;
  }

  setWindowTitle('ToolBC');
  const size = Size(390, 844);
  setWindowMinSize(size);
  setWindowMaxSize(const Size(430, 932));
  final screen = await getCurrentScreen();
  final frame = screen?.visibleFrame;
  if (frame != null) {
    final left = frame.left + (frame.width - size.width) / 2;
    final top = frame.top + (frame.height - size.height) / 2;
    setWindowFrame(Rect.fromLTWH(left, top, size.width, size.height));
  } else {
    setWindowFrame(const Rect.fromLTWH(100, 80, 390, 844));
  }
}
