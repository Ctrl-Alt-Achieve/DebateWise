// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyAU4z1s8X-lBwrhIxVM8w87DBETd_UjqIg',
      appId: '1:440568479033:web:3dd3593301fc04265bbce8',
      messagingSenderId: '440568479033',
      projectId: 'solutionh2s',
      databaseURL: 'https://solutionh2s-default-rtdb.asia-southeast1.firebasedatabase.app',
      authDomain: 'solutionh2s.firebaseapp.com',
      storageBucket: 'solutionh2s.appspot.com',
    );
  }
}
