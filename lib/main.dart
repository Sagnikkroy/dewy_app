import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart'; // Ensure config.dart is in your lib/ folder
import 'splash_screen.dart';

void main() async {
  // 1. Mandatory for async initialization
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Supabase using your AppConfig keys
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}