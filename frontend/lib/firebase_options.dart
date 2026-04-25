// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      // [TO SAATVIK & SAMAIRA]:
      // Replace these values with your Firebase Web configuration
      // located in Firebase Console -> Project Settings -> General -> Web App
      apiKey: 'WEB_API_KEY',
      appId: 'WEB_APP_ID',
      messagingSenderId: 'SENDER_ID',
      projectId: 'PROJECT_ID',
      databaseURL: 'https://MOCK_URL.firebaseio.com',
      authDomain: 'PROJECT_ID.firebaseapp.com',
      storageBucket: 'PROJECT_ID.appspot.com',
      measurementId: 'MEASUREMENT_ID',
    );
  }
}
