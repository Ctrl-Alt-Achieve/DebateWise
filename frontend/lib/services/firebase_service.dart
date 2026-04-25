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
    if (Firebase.apps.isEmpty) return;

    final DatabaseReference messagesRef = 
        FirebaseDatabase.instance.ref('sessions/$sessionId/messages');

    _messagesSubscription = messagesRef.onChildAdded.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _messages.add(AgentMessage.fromMap(data));
        // Sort by timestamp just in case
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
