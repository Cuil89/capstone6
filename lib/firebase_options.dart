import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBCD5HWtktNq1tOezgHW8eEKCVjaOyL52s',
    appId: '1:691571373089:web:fb762503727d6180e2df60',
    messagingSenderId: '691571373089',
    projectId: 'smart-farmasi',
    authDomain: 'smart-farmasi.firebaseapp.com',
    storageBucket: 'smart-farmasi.firebasestorage.app',
    measurementId: 'G-7WTLEF15H4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhFApCia7hysrc3mm5EtvYUPGcjNgscvY',
    appId: '1:691571373089:android:55ce01ee6e175f91e2df60',
    messagingSenderId: '691571373089',
    projectId: 'smart-farmasi',
    storageBucket: 'smart-farmasi.firebasestorage.app',
  );
}
