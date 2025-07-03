import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mxmnwsyxqjgezjtqckej.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im14bW53c3l4cWpnZXpqdHFja2VqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyOTE0NzAsImV4cCI6MjA2Njg2NzQ3MH0.YgyS7-B8mR15ZSPIjDkYC08-5ox0KxgFk-ZlueV1F9Y',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Application',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
