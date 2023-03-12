import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenovent_portal/global.dart';

import '../app_colors.dart';
import '../widget/responsive_layout.dart';

class ProfileScreenEdit extends StatefulWidget {
  const ProfileScreenEdit({Key? key}) : super(key: key);

  @override
  State<ProfileScreenEdit> createState() => _ProfileScreenEditState();
}

class _ProfileScreenEditState extends State<ProfileScreenEdit> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController positionTextEditingController = TextEditingController();

  updateInformation(){
    Map<String,dynamic> data = {
      "id" : currentUserInfo!.id!,
      "name" : nameTextEditingController.text,
      "email" : emailTextEditingController.text,
      "phone" : (phoneTextEditingController.text.length == 11) ? "+88" + phoneTextEditingController.text : phoneTextEditingController.text,
      "userType" : positionTextEditingController.text,
      "imageUrl" : currentUserInfo!.imageUrl!
    };

    FirebaseFirestore.instance
        .collection('users')
        .doc(currentFirebaseUser!.uid)
        .set(data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameTextEditingController.text = currentUserInfo!.name!;
    emailTextEditingController.text = currentUserInfo!.email!;
    phoneTextEditingController.text = currentUserInfo!.phone!;
    positionTextEditingController.text = currentUserInfo!.userPosition!;

  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.3,vertical: height * 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Profile Information',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 30),),
              SizedBox(height: height * 0.05,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
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
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade500, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
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
                  SizedBox(height: height * 0.02,),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Email",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Container(
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextFormField(
                      controller: emailTextEditingController,
                      readOnly: true,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blueDarkColor,
                        fontSize: 12.0,
                      ),

                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        prefixIcon: IconButton(
                          onPressed: (){},
                          icon: const Icon(Icons.email_outlined),
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
                          return "Wrong email format";
                        }
                      },
                    ),
                  ),
                  SizedBox(height: height * 0.02,),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Phone",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Container(
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextFormField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blueDarkColor,
                        fontSize: 12.0,
                      ),

                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade500, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        prefixIcon: IconButton(
                          onPressed: (){},
                          icon: const Icon(Icons.phone),
                        ),
                        suffixIcon: phoneTextEditingController.text.isEmpty
                            ? Container(width: 0)
                            : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              phoneTextEditingController.clear(),
                        ),
                        contentPadding: const EdgeInsets.only(top: 16.0),
                        hintText: 'Enter Phone',
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

                        else if(value.length != 11){
                          return "Wrong phone number format";
                        }

                        else {
                          return null;
                        }
                      },
                    ),
                  ),
                  SizedBox(height: height * 0.02,),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Position",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Container(
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: AppColors.whiteColor,
                    ),
                    child: TextFormField(
                      controller: positionTextEditingController,
                      readOnly: true,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blueDarkColor,
                        fontSize: 12.0,
                      ),

                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade500, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        prefixIcon: IconButton(
                          onPressed: (){},
                          icon: const Icon(Icons.verified_user),
                        ),
                        contentPadding: const EdgeInsets.only(top: 16.0),
                        hintText: 'Position',
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
                  SizedBox(height: height * 0.03,),
                ],
              ),

              SizedBox(
                height: 40,
                width: width * 0.2,
                child: ElevatedButton(
                  onPressed: () async {
                    await updateInformation();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Information updated successfully!!")));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: (Colors.blue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
                  ),
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
