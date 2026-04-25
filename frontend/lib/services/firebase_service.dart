import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../firebase_options.dart';

class FirebaseService extends ChangeNotifier {
  final List<AgentMessage> _messages = [];
  List<AgentMessage> get messages => _messages;
  
  StreamSubscription<DatabaseEvent>? _messagesSubscription;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      listenToSession('default_session');
    } catch (e) {
      print("Firebase initialization error: $e");
    }
  }

  void listenToSession(String sessionId) {
    _messagesSubscription?.cancel();
    
    // Check if Firebase app is initialized successfully
    if (Firebase.apps.isEmpty) {
      print("[FIREBASE SERVICE] No Firebase apps initialized, cannot listen.");
      return;
    }

    print("[FIREBASE SERVICE] Setting up listener on: sessions/$sessionId/messages");
    final DatabaseReference messagesRef = 
        FirebaseDatabase.instance.ref('sessions/$sessionId/messages');

    _messagesSubscription = messagesRef.onChildAdded.listen(
      (event) {
        print("[FIREBASE SERVICE] onChildAdded fired! Key: ${event.snapshot.key}");
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          print("[FIREBASE SERVICE] Message data: $data");
          _messages.add(AgentMessage.fromMap(data));
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          notifyListeners();
        }
      },
      onError: (error) {
        print("[FIREBASE SERVICE] Listener ERROR: $error");
      },
    );
    print("[FIREBASE SERVICE] Listener established successfully.");
  }

  Future<void> sendMessage(String text, {String sessionId = 'default_session'}) async {
    if (Firebase.apps.isEmpty) {
      print("[FIREBASE SERVICE] Cannot send: no Firebase apps.");
      return;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    try {
      // 1. Push to messages so it shows up in the UI
      final messagesRef = FirebaseDatabase.instance.ref('sessions/$sessionId/messages');
      await messagesRef.push().set({
        'agent': 'User',
        'text': text,
        'timestamp': timestamp,
      });
      print("[FIREBASE SERVICE] Message pushed to messages successfully.");

      // 2. Push to inputs so the Python backend picks it up
      final inputsRef = FirebaseDatabase.instance.ref('sessions/$sessionId/inputs');
      await inputsRef.push().set({
        'agent': 'User',
        'text': text,
        'timestamp': timestamp,
      });
      print("[FIREBASE SERVICE] Input pushed to inputs successfully.");
    } catch (e) {
      print("[FIREBASE SERVICE] ERROR sending message: $e");
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
