import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCZcn8MMBCy57fsrSDA9sUdqFXGRubb3A',
    appId: '1:937757605085:android:5f429712c5cee98427af34',
    messagingSenderId: '937757605085',
    projectId: 'assistbridge-6cb92',
    storageBucket: 'assistbridge-6cb92.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAtk44B7PwjQKeP2p0OPuFP8QZU0zadPo4',
    appId: '1:937757605085:ios:7ea325dfa1135f6e27af34',
    messagingSenderId: '937757605085',
    projectId: 'assistbridge-6cb92',
    storageBucket: 'assistbridge-6cb92.firebasestorage.app',
    iosBundleId: 'com.assistbridge.app',
  );
}
