import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'forget.dart';
import 'home.dart';
import 'package:icreatz_work/login.dart';
import 'signup.dart';
//import 'firebase_options.dart'; // Import the generated file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => TaskScreen(),
        '/forget':(context) => ForgetPasswordScreen(),
      },
    );
  }
}
