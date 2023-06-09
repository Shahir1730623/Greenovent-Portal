import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenovent_portal/authentication_screens/login_screen.dart';
import 'package:greenovent_portal/dashboard_screens/super_admin_dashboard.dart';
import 'package:greenovent_portal/widget/responsive_layout.dart';
import 'app_colors.dart';
import 'assistant_method/assistant_method.dart';
import 'global.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  startTimer() async {
    late StreamSubscription<User?> user;
    user = firebaseAuth.authStateChanges().listen((user) async {
      if (user == null) {
        print('User is currently signed out!');
      }

      else {
        print('User is signed in!');
        await AssistantMethods.readCurrentOnlineUserInfo();
      }
    });

    Timer(const Duration(seconds: 3), () async {
      if (await firebaseAuth.currentUser != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SuperAdminDashboard()));
      }

      else {
        // send User to login screen
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Material(
      child: Container(
        height: height,
        color: AppColors.mainBlueColor,
        child: (ResponsiveWidget.isSmallScreen(context)) ?
        Center(
          child: Text(
            'Greenovent Portal',
            style: GoogleFonts.raleway(
              fontSize: 35.0,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ) : (ResponsiveWidget.isMediumScreen(context)) ?
        Center(
          child: Text(
            'Greenovent Portal',
            style: GoogleFonts.raleway(
              fontSize: 45.0,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ) :

        Center(
          child: Text(
            'Greenovent Portal',
            style: GoogleFonts.raleway(
              fontSize: 48.0,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        )
      ),
    );
  }
}
