import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens/landing_page.dart';
import 'services/firebase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
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
