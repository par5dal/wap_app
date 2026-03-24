// lib/core/config/firebase_options.dart
// Generado manualmente a partir de google-services.json y GoogleService-Info.plist.

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    throw UnsupportedError(
      'DefaultFirebaseOptions no está soportado en esta plataforma.',
    );
  }

  /// Android — com.jovelupe.wap
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDV07ZyvXDso9vzPMposVS_KWNi8XftvhE',
    appId: '1:99666080057:android:0f722617de346e726338e8',
    messagingSenderId: '99666080057',
    projectId: 'what-a-plan',
    storageBucket: 'what-a-plan.firebasestorage.app',
  );

  /// iOS — com.jovelupe.wap
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwk2unaQCyiK02YOjia8JgLmzWrxO5mOY',
    appId: '1:99666080057:ios:291a72cdb722048e6338e8',
    messagingSenderId: '99666080057',
    projectId: 'what-a-plan',
    storageBucket: 'what-a-plan.firebasestorage.app',
    iosBundleId: 'com.jovelupe.wap',
  );
}
