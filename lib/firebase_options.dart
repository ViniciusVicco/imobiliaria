import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are configured for web only. '
          'Run flutterfire configure before enabling this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAlvzeWRUMdJuBEIjSShs2yCEzcrAK0gSY',
    appId: '1:940026403272:web:0496f26f4a70332ab508fd',
    messagingSenderId: '940026403272',
    projectId: 'seletta-imobiliaria',
    authDomain: 'seletta-imobiliaria.firebaseapp.com',
    storageBucket: 'seletta-imobiliaria.firebasestorage.app',
    measurementId: 'G-Y2DY7JYW07',
  );
}
