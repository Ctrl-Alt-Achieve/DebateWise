import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens/landing_page.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final firebaseService = FirebaseService();
  await firebaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: firebaseService),
      ],
      child: const DebateWiseApp(),
    ),
  );
}

class DebateWiseApp extends StatelessWidget {
  const DebateWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DebateWise',
      theme: AppTheme.darkTheme,
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
