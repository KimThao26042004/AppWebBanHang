import 'package:flutter_emart1/views/splash_screen/splash_screen.dart';
import 'package:flutter_emart1/views/auth_screen/login_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'consts/consts.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appname,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(
                color: darkFontGrey
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent
        ),
        fontFamily: regular,
      ),
      home: LoginScreen(),
    );
  }
}