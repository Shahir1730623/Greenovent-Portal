import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenovent_portal/app_colors.dart';
import 'package:greenovent_portal/authentication_screens/login_screen.dart';
import 'package:greenovent_portal/global.dart';
import 'package:greenovent_portal/widget/responsive_layout.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> resetPassword() async {
    try{
      await firebaseAuth.sendPasswordResetEmail(email: emailTextEditingController.text.trim());
    }

    catch(e){
      print(e.toString());
    }

    emailTextEditingController.clear();

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailTextEditingController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
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
                  (ResponsiveWidget.isSmallScreen(context)) ? const SizedBox() : (ResponsiveWidget.isMediumScreen(context)) ? SizedBox() : Expanded(
                    child: Container(
                      height: height,
                      color: AppColors.mainBlueColor,
                      child: Center(
                        child: Text(
                          'Forgot Password?',
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
                      margin: EdgeInsets.symmetric(horizontal: ResponsiveWidget.isSmallScreen(context)? height * 0.032 : height * 0.12),
                      color: AppColors.backColor,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: height * 0.2),
                              // Login text
                              Text(
                                "Change Password",
                                style: GoogleFonts.raleway(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.blueDarkColor,
                                  fontSize: 30.0,
                                ),
                              ),

                              SizedBox(height: height * 0.02),
                              // Enter details text
                              Text('Enter your new password \nin the form below',
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
                                  borderRadius: BorderRadius.circular(10.0),
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
                                      onPressed: (){},
                                      icon: const Icon(Icons.email_outlined),
                                    ),
                                    suffixIcon: emailTextEditingController.text.isEmpty
                                        ? Container(width: 0)
                                        : IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () =>
                                          emailTextEditingController.clear(),
                                    ),
                                    contentPadding: const EdgeInsets.only(top: 16.0),
                                    hintText: 'Enter Email',
                                    hintStyle: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.blueDarkColor.withOpacity(0.8),
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "The field is empty";
                                    }

                                    else if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)){
                                      return null;
                                    }

                                    else {
                                      return "Wrong email format!";
                                    }
                                  },
                                ),
                              ),

                              SizedBox(height: height * 0.03),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    if (_formKey.currentState!.validate()){
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return const Center(child: CircularProgressIndicator());
                                          }
                                      );

                                      await resetPassword();
                                      Timer(const Duration(seconds: 3), () {
                                        Navigator.pop(context);
                                        var snackBar = const SnackBar(content: Text('Password reset email sent'));
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      });
                                    }

                                    else{
                                      var snackBar = const SnackBar(content: Text('Fill up email field'));
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Ink(
                                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      color: AppColors.mainBlueColor,
                                    ),
                                    child: Text(
                                      'Reset Password',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.whiteColor,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: height * 0.05),

                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                                  },
                                  style: ButtonStyle(
                                    overlayColor: MaterialStateProperty
                                        .all<Color>(
                                        const Color(0x00FFFFFF)),
                                  ),
                                  child: Text(
                                    'Back to Login',
                                    style: GoogleFonts.raleway(
                                      fontSize: 18.0,
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

