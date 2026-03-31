// Android: google-services.json ile uyumlu.
// iOS / Web / Windows için en kolayı: proje kökünde `flutterfire configure` çalıştırıp bu dosyayı yeniden üretmek.
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
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        return android;
    }
  }

  /// Web uygulaması Firebase konsolda tanımlı değilse önce Web app ekleyin veya `flutterfire configure` kullanın.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDYh9xXjBkYCy0SSqtIahaeqmmjTPRdwdE',
    appId: '1:879408463683:web:0000000000000000000000',
    messagingSenderId: '879408463683',
    projectId: 'memoirly-bdb00',
    authDomain: 'memoirly-bdb00.firebaseapp.com',
    storageBucket: 'memoirly-bdb00.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDYh9xXjBkYCy0SSqtIahaeqmmjTPRdwdE',
    appId: '1:879408463683:android:63dbe59e3ab7ae6edeb9f6',
    messagingSenderId: '879408463683',
    projectId: 'memoirly-bdb00',
    storageBucket: 'memoirly-bdb00.firebasestorage.app',
  );

  /// iOS için konsolda iOS uygulaması ekleyip `GoogleService-Info.plist` indirin; doğru değerler için `flutterfire configure` önerilir.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDYh9xXjBkYCy0SSqtIahaeqmmjTPRdwdE',
    appId: '1:879408463683:ios:0000000000000000000000',
    messagingSenderId: '879408463683',
    projectId: 'memoirly-bdb00',
    storageBucket: 'memoirly-bdb00.firebasestorage.app',
    iosBundleId: 'com.memoirly.memoirly',
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDYh9xXjBkYCy0SSqtIahaeqmmjTPRdwdE',
    appId: '1:879408463683:web:0000000000000000000000',
    messagingSenderId: '879408463683',
    projectId: 'memoirly-bdb00',
    storageBucket: 'memoirly-bdb00.firebasestorage.app',
  );
}
