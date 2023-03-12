import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenovent_portal/loading_screen.dart';

import 'Testing/test.dart';
import 'assistant_method.dart';

import 'authentication_screens/login_screen.dart';
import 'dashboard_screens/sub_admin_dashboard.dart';
import 'dashboard_screens/super_admin_dashboard.dart';
import 'form/sub_admin_form.dart';
import 'global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: const FirebaseOptions(
        apiKey: "AIzaSyBRCPpcqVx-Lc2eFL-smk1e-jxsgLpj_0A",
        authDomain: "greenovent-web-portal.firebaseapp.com",
        databaseURL:
            "https://greenovent-web-portal-default-rtdb.firebaseio.com",
        projectId: "greenovent-web-portal",
        storageBucket: "greenovent-web-portal.appspot.com",
        messagingSenderId: "272953366857",
        appId: "1:272953366857:web:004e0753f75f68c967e298",
        measurementId: "G-K84QZFE7J1"),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<User?> user;
  void initState() {
    super.initState();
    // user = firebaseAuth.authStateChanges().listen((user) async {
    //   if (user == null) {
    //     print('User is currently signed out!');
    //   }
    //   else{
    //     print('User is signed in!');
    //     await AssistantMethods.readCurrentOnlineUserInfo();
    //   }
    //
    // });
  }

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenovent Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //supportedLocales: L10n.all,
      home: LoadingScreen(),
      //builder: (context,child) => unFocus(child: child!),
      //home: LoginScreen(),
      debugShowCheckedModeBanner: false,
      //navigatorKey: NavigationService.navigatorKey,
    );
  }
}
