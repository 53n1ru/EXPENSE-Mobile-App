import 'package:flutter/material.dart';
import 'loading_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart'; // optional (for later)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses',
      debugShowCheckedModeBanner: false,

      // 🎨 Global Theme (matches your app style)
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
      ),

      // 🚀 Start with loading screen
      home: LoadingScreen(
        nextScreen: const LoginPage(),
      ),

      // 🔁 Optional named routes (for later use)
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}