import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenovent_portal/app_colors.dart';
import 'package:greenovent_portal/authentication_screens/change_password.dart';
import 'package:greenovent_portal/authentication_screens/registration_screen.dart';
import 'package:greenovent_portal/dashboard_screens/super_admin_dashboard.dart';
import 'package:greenovent_portal/dashboard_screens/sub_admin_dashboard.dart';
import 'package:greenovent_portal/form/sub_admin_form.dart';
import 'package:greenovent_portal/loading_screen.dart';
import 'package:greenovent_portal/widget/responsive_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../assistant_method.dart';
import '../global.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  bool passwordHide = true;
  final _formKey = GlobalKey<FormState>();

  loginUser() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        }
    );

    await firebaseAuth.signInWithEmailAndPassword(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text
    ).then((auth) async {
      currentFirebaseUser = auth.user;
      print(currentFirebaseUser!.uid);
      auth.user != null ? AssistantMethods.readCurrentOnlineUserInfo() : null;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentFirebaseUser!.uid)
          .get()
          .then((snapData) {
        if (snapData.exists) {
          Navigator.push(context, MaterialPageRoute(builder: (c) => const LoadingScreen()));
        }
      });
    }).catchError((onError){
      var snackBar = const SnackBar(content: Text('Wrong credentials! Try again'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    Timer(const Duration(seconds: 3), () {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailTextEditingController.addListener(() => setState(() {}));
    passwordTextEditingController.addListener(() => setState(() {}));

  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
        backgroundColor: AppColors.backColor,
        body: Form(
          key: _formKey,
          child: SizedBox(
              height: height,
              width: width,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    (ResponsiveWidget.isSmallScreen(context)) ? const SizedBox() : (ResponsiveWidget.isMediumScreen(context)) ? const SizedBox() :
                    Expanded(
                      child: Container(
                        height: height,
                        color: AppColors.mainBlueColor,
                        child: Center(
                          child: Text(
                            'Greenovent Portal',
                            style: GoogleFonts.raleway(
                              fontSize: 48.0,
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        height: height,
                        margin: EdgeInsets.symmetric(horizontal: ResponsiveWidget.isSmallScreen(context) ? height * 0.032 : height * 0.12),
                        color: AppColors.backColor,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: height * 0.2),
                                // Login text
                                Text(
                                  "Login to the portal",
                                  style: GoogleFonts.raleway(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.blueDarkColor,
                                    fontSize: 30.0,
                                  ),
                                ),

                                SizedBox(height: height * 0.02),
                                // Enter details text
                                Text(
                                  'Enter your details to login in \nto your account.',
                                  style: GoogleFonts.raleway(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColor,
                                  ),
                                ),

                                SizedBox(height: height * 0.064),

                                //Email Text
                                Text(
                                  'Email',
                                  style: GoogleFonts.raleway(
                                    fontSize: 12.0,
                                    color: AppColors.blueDarkColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                // Email text field
                                Container(
                                  width: width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10.0),
                                    color: AppColors.whiteColor,
                                  ),
                                  child: TextFormField(
                                    controller: emailTextEditingController,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.blueDarkColor,
                                      fontSize: 15.0,
                                    ),

                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                            Icons.email_outlined),
                                      ),
                                      suffixIcon: emailTextEditingController
                                          .text.isEmpty
                                          ? Container(width: 0)
                                          : IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => emailTextEditingController.clear(),
                                      ),
                                      contentPadding: const EdgeInsets
                                          .only(top: 16.0),
                                      hintText: 'Enter Email',
                                      hintStyle: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.blueDarkColor
                                            .withOpacity(0.8),
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "The field is empty";
                                      }

                                      else if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                                        return null;
                                      }

                                      else {
                                        return "Wrong email format!";
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: height * 0.02),

                                // Password Text
                                Text('Password',
                                  style: GoogleFonts.raleway(
                                    fontSize: 12.0,
                                    color: AppColors.blueDarkColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                // Password text field
                                Container(
                                  height: 50,
                                  width: width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10.0),
                                    color: AppColors.whiteColor,
                                  ),
                                  child: TextFormField(
                                    controller: passwordTextEditingController,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.blueDarkColor,
                                      fontSize: 15.0,
                                    ),
                                    obscureText: passwordHide,

                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          if (passwordHide) {
                                            setState(() {
                                              passwordHide = false;
                                            });
                                          }

                                          else {
                                            setState(() {
                                              passwordHide = true;
                                            });
                                          }
                                        },
                                        icon: (passwordHide)
                                            ? const Icon(Icons.visibility)
                                            : const Icon(
                                            Icons.visibility_off),
                                      ),
                                      prefixIcon: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.password),
                                      ),
                                      contentPadding: const EdgeInsets
                                          .only(top: 16.0),
                                      hintText: 'Enter Password',
                                      hintStyle: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.blueDarkColor
                                            .withOpacity(0.8),
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty) {
                                        return "The field is empty";
                                      }
                                      else {
                                        return null;
                                      }
                                    },
                                  ),
                                ),

                                SizedBox(height: height * 0.03),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const ChangePasswordScreen()));
                                    },
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty
                                          .all<Color>(
                                          const Color(0x00FFFFFF)),
                                    ),
                                    child: Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.raleway(
                                        fontSize: 15.0,
                                        color: AppColors.mainBlueColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: height * 0.03),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await loginUser();
                                      }
                                      else {
                                        var snackBar = const SnackBar(
                                            content: Text(
                                                'Fill up the login form correctly'));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(
                                        16.0),
                                    child: Ink(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 45.0,
                                          vertical: 15.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius
                                            .circular(16.0),
                                        color: AppColors.mainBlueColor,
                                      ),
                                      child: Text(
                                        'Login',
                                        style: GoogleFonts.raleway(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.whiteColor,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: height * 0.03),

                                Align(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (
                                              context) => const RegistrationScreen()));
                                    },
                                    style: ButtonStyle(
                                          overlayColor: MaterialStateProperty
                                              .all<Color>(
                                          const Color(0x00FFFFFF)),
                                    ),
                                    child: Text(
                                      'New? Register Now',
                                      style: GoogleFonts.raleway(
                                        fontSize: 15.0,
                                        color: AppColors.mainBlueColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),


                              ],
                            ),
                          ),
                        ),
                      ),
                    )

                  ]
              )
          ),
        ),
    );
  }
}

