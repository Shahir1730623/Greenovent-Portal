import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenovent_portal/authentication_screens/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../app_colors.dart';
import '../global.dart';
import '../widget/responsive_layout.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController phoneNumberTextEditingController = TextEditingController();
  String? selectedUserType;
  bool passwordHide = true;

  List<String> userTypeList = ["Executive Director", "Accountant", "Digital Marketing Executive", "Digital Head"];

  String idGenerator() {
    final now = DateTime.now();
    return now.microsecondsSinceEpoch.toString();
  }

  saveDataToDatabase() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        }
    );

    firebase_storage.Reference reference = firebase_storage.FirebaseStorage.instance.ref('userImage/dummy-image.png');
    var imageUrl = await reference.getDownloadURL();
    
    try{
      await firebaseAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text,
          password: passwordTextEditingController.text
      ).then((firebaseAuth){
        currentFirebaseUser = firebaseAuth.user;
        Map<String,dynamic> data = {
        'id' : currentFirebaseUser!.uid,
        'name' : nameTextEditingController.text,
        "email" : emailTextEditingController.text,
        "phone" : "+88${phoneNumberTextEditingController.text}",
        "userType" : selectedUserType,
        'imageUrl' : imageUrl
        };
        FirebaseFirestore.instance.collection('users').doc(currentFirebaseUser!.uid).set(data);
        nameTextEditingController.clear();
        emailTextEditingController.clear();
        passwordTextEditingController.clear();
        phoneNumberTextEditingController.clear();
        setState(() {
          selectedUserType = null;
        });
      }).catchError((onError){
        var snackBar = SnackBar(content: Text(onError.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });

    }

    catch(e){
      print(e);
    }

    var snackBar = const SnackBar(content: Text('Registration Successful'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    Timer(const Duration(seconds: 3), () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    });

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
                          'Registration Screen',
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: height * 0.1),
                              // Login text
                              Text(
                                "Register Now",
                                style: GoogleFonts.raleway(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.blueDarkColor,
                                  fontSize: 30.0,
                                ),
                              ),

                              SizedBox(height: height * 0.02),
                              // Enter details text
                              Text('Enter your details to register\nfor a new account.',
                                style: GoogleFonts.raleway(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textColor,
                                ),
                              ),

                              SizedBox(height: height * 0.04),

                              //Name Text
                              Text(
                                'Name',
                                style: GoogleFonts.raleway(
                                  fontSize: 12.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Container(
                                width: width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: AppColors.whiteColor,
                                ),
                                child: TextFormField(
                                  controller: nameTextEditingController,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.blueDarkColor,
                                    fontSize: 12.0,
                                  ),

                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: IconButton(
                                      onPressed: (){},
                                      icon: const Icon(Icons.person),
                                    ),
                                    suffixIcon: nameTextEditingController.text.isEmpty
                                        ? Container(width: 0)
                                        : IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () =>
                                          nameTextEditingController.clear(),
                                    ),
                                    contentPadding: const EdgeInsets.only(top: 16.0),
                                    hintText: 'Enter Name',
                                    hintStyle: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.blueDarkColor.withOpacity(0.8),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "The field is empty";
                                    }

                                    else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: height * 0.02),

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
                                    fontSize: 12.0,
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
                                      fontSize: 12.0,
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
                              SizedBox(height: height * 0.02),

                              // Phone Text
                              Text(
                                'Phone Number',
                                style: GoogleFonts.raleway(
                                  fontSize: 12.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Container(
                                height: 50,
                                width: width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: AppColors.whiteColor,
                                ),
                                child: TextFormField(
                                  controller: phoneNumberTextEditingController,
                                  keyboardType: TextInputType.phone,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.blueDarkColor,
                                    fontSize: 12.0,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: IconButton(
                                      onPressed: (){},
                                      icon: const Icon(Icons.phone),
                                    ),
                                    contentPadding: const EdgeInsets.only(top: 16.0),
                                    hintText: 'Phone Number',
                                    hintStyle: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.blueDarkColor.withOpacity(0.8),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||value.isEmpty) {
                                      return "The field is empty";
                                    }

                                    else if(value.length != 11){
                                      return "Wrong phone number format";
                                    }

                                    else {
                                      return null;
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
                              Container(
                                height: 50,
                                width: width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: AppColors.whiteColor,
                                ),
                                child: TextFormField(
                                  controller: passwordTextEditingController,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.blueDarkColor,
                                    fontSize: 12.0,
                                  ),
                                  obscureText: passwordHide,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    suffixIcon: IconButton(
                                      onPressed: (){
                                        if(passwordHide){
                                          setState(() {
                                            passwordHide = false;
                                          });
                                        }

                                        else{
                                          setState(() {
                                            passwordHide = true;
                                          });
                                        }

                                      },
                                      icon: (passwordHide) ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
                                    ),
                                    prefixIcon: IconButton(
                                      onPressed: (){},
                                      icon: const Icon(Icons.password),
                                    ),
                                    contentPadding: const EdgeInsets.only(top: 16.0),
                                    hintText: 'Enter Password',
                                    hintStyle: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.blueDarkColor.withOpacity(0.8),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||value.isEmpty) {
                                      return "The field is empty";
                                    }
                                    else {
                                      return null;
                                    }
                                  },
                                ),
                              ),

                              SizedBox(height: height * 0.02),

                              // User Type
                              Text(
                                'Select User Type',
                                style: GoogleFonts.raleway(
                                  fontSize: 12.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: DropdownButtonFormField(
                                  decoration:  InputDecoration(
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(width: 1.5, color: Colors.grey.shade300),
                                    ),
                                  ) ,
                                  iconSize: 26,
                                  dropdownColor: Colors.white,
                                  isExpanded: true,
                                  value: selectedUserType,
                                  hint: Text(
                                    "Select user position",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: AppColors.blueDarkColor.withOpacity(0.8),
                                    ),
                                  ),
                                  onChanged: (newValue)
                                  {
                                    setState(() {
                                      selectedUserType = newValue;
                                    });

                                  },

                                  items: userTypeList.map((user){
                                    return DropdownMenuItem(
                                      value: user,
                                      child: Text(
                                        user,
                                        style: TextStyle(color: AppColors.blueDarkColor.withOpacity(0.8)),
                                      ),
                                    );
                                  }).toList(),

                                  validator: (value){
                                    if(value == null){
                                      return "Select user position";
                                    }
                                    else{
                                      return null;
                                    }
                                  },
                                ),
                              ),

                              SizedBox(height: height * 0.05),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    if (_formKey.currentState!.validate()){
                                      await saveDataToDatabase();
                                    }

                                    else{
                                      var snackBar = const SnackBar(content: Text('Fill up the registration form correctly'));
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: Ink(
                                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      color: AppColors.mainBlueColor,
                                    ),
                                    child: Text(
                                      'Register Now',
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.whiteColor,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: height * 0.02),

                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (
                                            context) => const LoginScreen()));
                                  },
                                  style: ButtonStyle(
                                    overlayColor: MaterialStateProperty
                                        .all<Color>(
                                        const Color(0x00FFFFFF)),
                                  ),
                                  child: Text(
                                    'Already have an account? Login Now',
                                    style: GoogleFonts.raleway(
                                      fontSize: 15.0,
                                      color: AppColors.mainBlueColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: height * 0.02),


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
