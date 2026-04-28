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
      // Check if Firebase is already initialized (e.g., from index.html)
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      debugPrint("[FirebaseService] Firebase initialized. Apps: ${Firebase.apps.length}");
      listenToSession('default_session');
    } catch (e) {
      debugPrint("Firebase initialization error: $e");
    }
  }

  void listenToSession(String sessionId) {
    _messagesSubscription?.cancel();
    
    if (Firebase.apps.isEmpty) return;

    final DatabaseReference messagesRef = 
        FirebaseDatabase.instance.ref('sessions/$sessionId/messages');

    _messagesSubscription = messagesRef.onChildAdded.listen(
      (event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          _messages.add(AgentMessage.fromMap(data));
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint("[FirebaseService] Listener error: $error");
      },
    );
  }

  Future<void> sendMessage(String text, {String sessionId = 'default_session'}) async {
    if (Firebase.apps.isEmpty) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    try {
      // Push to messages so it shows up in the UI
      final messagesRef = FirebaseDatabase.instance.ref('sessions/$sessionId/messages');
      await messagesRef.push().set({
        'agent': 'User',
        'text': text,
        'timestamp': timestamp,
      });

      // Push to inputs so the Python backend picks it up
      final inputsRef = FirebaseDatabase.instance.ref('sessions/$sessionId/inputs');
      await inputsRef.push().set({
        'agent': 'User',
        'text': text,
        'timestamp': timestamp,
      });
    } catch (e) {
      debugPrint("[FirebaseService] Send error: $e");
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
