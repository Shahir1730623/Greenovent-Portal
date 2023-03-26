import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenovent_portal/loading_screen.dart';


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
  }

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenovent Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoadingScreen(),
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      //navigatorKey: NavigationService.navigatorKey,
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior{
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };

}
