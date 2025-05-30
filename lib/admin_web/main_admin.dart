import 'package:flutter/material.dart';
import 'views/login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC7UVcsyUTI3Bh40j93HuWX5ngRnZ_VmA0",
      authDomain: "emart-c6867.firebaseapp.com",
      projectId: "emart-c6867",
      storageBucket: "emart-c6867.firebasestorage.app",
      messagingSenderId: "572785048241",
      appId: "1:572785048241:web:00f9fb4a1a2c01c9910090",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'sans_regular',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}