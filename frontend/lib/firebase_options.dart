// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      databaseURL: dotenv.env['FIREBASE_DATABASE_URL'] ?? '',
      authDomain: '${dotenv.env['FIREBASE_PROJECT_ID']}.firebaseapp.com',
      storageBucket: '${dotenv.env['FIREBASE_PROJECT_ID']}.appspot.com',
    );
  }
}
