import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Firebase 初期化を試行。未設定の場合は false を返し、モックDBにフォールバック。
  static Future<bool> tryInitialize() async {
    if (_initialized) {
      return true;
    }

    try {
      await Firebase.initializeApp();
      _initialized = true;
      return true;
    } catch (error) {
      debugPrint('Firebase initialize skipped: $error');
      return false;
    }
  }
}
