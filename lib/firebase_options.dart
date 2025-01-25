// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB7pASRd-kKBDP-WubIISPEPbFpVyjFhRQ',
    appId: '1:999791418099:web:ea2ea213d5f131e0077586',
    messagingSenderId: '999791418099',
    projectId: 'framer-app-6d8b6',
    authDomain: 'framer-app-6d8b6.firebaseapp.com',
    storageBucket: 'framer-app-6d8b6.appspot.com',
    measurementId: 'G-7EM9TLCPHT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDbX7ebQ9QmMxNq7cPnn-gXJexvRZqDdDs',
    appId: '1:999791418099:android:b0cfa7582c7fc7f9077586',
    messagingSenderId: '999791418099',
    projectId: 'framer-app-6d8b6',
    storageBucket: 'framer-app-6d8b6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCim33VJSZHLHQB5ZvkyJPRZeSlvdXP5-Y',
    appId: '1:999791418099:ios:8ee745a7e8a80012077586',
    messagingSenderId: '999791418099',
    projectId: 'framer-app-6d8b6',
    storageBucket: 'framer-app-6d8b6.appspot.com',
    iosClientId: '999791418099-p9nek07rq4p6knis7nk254jca9t5iemj.apps.googleusercontent.com',
    iosBundleId: 'com.example.ko',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCim33VJSZHLHQB5ZvkyJPRZeSlvdXP5-Y',
    appId: '1:999791418099:ios:8ee745a7e8a80012077586',
    messagingSenderId: '999791418099',
    projectId: 'framer-app-6d8b6',
    storageBucket: 'framer-app-6d8b6.appspot.com',
    iosClientId: '999791418099-p9nek07rq4p6knis7nk254jca9t5iemj.apps.googleusercontent.com',
    iosBundleId: 'com.example.ko',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB7pASRd-kKBDP-WubIISPEPbFpVyjFhRQ',
    appId: '1:999791418099:web:1162ed76daf50503077586',
    messagingSenderId: '999791418099',
    projectId: 'framer-app-6d8b6',
    authDomain: 'framer-app-6d8b6.firebaseapp.com',
    storageBucket: 'framer-app-6d8b6.appspot.com',
    measurementId: 'G-B8SNVMFK5D',
  );
}
