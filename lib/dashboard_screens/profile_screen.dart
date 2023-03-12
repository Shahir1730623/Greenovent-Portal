import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenovent_portal/dashboard_screens/profile_screen_edit.dart';
import 'package:greenovent_portal/dashboard_screens/sub_admin_dashboard.dart';
import 'package:greenovent_portal/dashboard_screens/super_admin_dashboard.dart';
import 'package:image_network/image_network.dart';
import 'package:image_picker/image_picker.dart';
import '../app_colors.dart';
import '../authentication_screens/login_screen.dart';
import '../global.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../widget/responsive_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController currentUserPositionTextEditingController = TextEditingController();

  String? imageUrl;
  XFile? imageFile;
  Uint8List webImage = Uint8List(8);
  File? pickedImage;

  bool isExpanded = false;
  int selectedIndex = 2;

  // Future<void> pickImage() async {
  //   if(!kIsWeb){
  //     try{
  //       // Pick an Image
  //       final imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  //       if(imageFile!=null){
  //         showDialog(
  //             context: context,
  //             barrierDismissible: false,
  //             builder: (BuildContext context) {
  //               return const Center(child: CircularProgressIndicator());
  //             }
  //         );
  //
  //         firebase_storage.Reference reference = firebase_storage.FirebaseStorage.instance.ref('userImage/'+ currentUserInfo!.id! +'.png');
  //         setState(() {
  //           pickedImage = File(imageFile.path);
  //         });
  //
  //         // Upload the image to firebase storage
  //         await reference.putFile(pickedImage!);
  //         imageUrl = await reference.getDownloadURL();
  //
  //         Timer(const Duration(seconds: 5), () {
  //           Navigator.pop(context);
  //         });
  //
  //
  //       }
  //
  //       else{
  //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No image selected")));
  //       }
  //     }
  //
  //     catch(e){
  //       imageFile = null;
  //       setState(() {});
  //     }
  //   }
  //
  //   else if (kIsWeb){
  //     try{
  //       // Pick an Image
  //       final imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  //       if(imageFile!=null){
  //         showDialog(
  //             context: context,
  //             barrierDismissible: false,
  //             builder: (BuildContext context) {
  //               return const Center(child: CircularProgressIndicator());
  //             }
  //         );
  //
  //         firebase_storage.Reference reference = firebase_storage.FirebaseStorage.instance.ref('userImage/'+ currentUserInfo!.id! +'.png');
  //         var img = await imageFile.readAsBytes();
  //         setState(() {
  //           webImage = img;
  //           pickedImage = File('');
  //         });
  //
  //         // Upload the image to firebase storage
  //         await reference.putData(webImage);
  //         imageUrl = await reference.getDownloadURL();
  //         setState(() {
  //
  //         });
  //
  //         Timer(const Duration(seconds: 5), () {
  //           Navigator.pop(context);
  //         });
  //
  //       }
  //
  //       else{
  //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No image selected")));
  //       }
  //     }
  //
  //     catch(e){
  //       imageFile = null;
  //       setState(() {});
  //     }
  //   }
  //
  //   else{
  //     print('error');
  //   }
  //
  //
  // }


  updateImageUrl(){
    var usersRef = FirebaseFirestore.instance.collection('users').doc(currentFirebaseUser!.uid);
    usersRef.get().then((documentSnapshot){
      documentSnapshot.data()!['imageUrl'] = imageUrl;
      setState(() {
        currentUserInfo!.imageUrl = imageUrl;
      });
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameTextEditingController.addListener(() => setState(() {}));
    phoneTextEditingController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: (ResponsiveWidget.isSmallScreen(context)) ?
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Profile Information',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 30),),
              SizedBox(height: height * 0.05,),
              // Image circle
              Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: Colors.black54,
                    ),

                  ),

                  child: (imageUrl == null) ?
                  ClipOval(
                    child: ImageNetwork(
                      height: 30,
                      width: 30,
                      image: currentUserInfo!.imageUrl!,
                    ),
                  ) :

                  ClipOval(
                    child: ImageNetwork(
                      height: 30,
                      width: 30,
                      image: imageUrl!,
                    ),
                  )
              ),
              // Upload image Circle
              Container(
                transform: Matrix4.translationValues(0.0, -35.0, 0.0),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50)),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50)),
                    child: IconButton(
                        onPressed: () async {
                          var snackBar = const SnackBar(content: Text('Work in progress'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.grey.shade400,
                        ))),
              ),


              Transform.translate(
                offset: const Offset(0,-20),
                child: Text(
                  currentUserInfo!.name!,
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 22
                  ),
                ),
              ),

              Transform.translate(
                offset: const Offset(0,-10),
                child: Text(
                  currentUserInfo!.phone!,
                  style: GoogleFonts.montserrat(
                      color: Colors.grey.shade500,
                      fontSize: 15
                  ),
                ),
              ),

              SizedBox(height: height * 0.05,),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text('Name',style: GoogleFonts.montserrat(fontSize: 20),),
              //         SizedBox(height: height * 0.03,),
              //         Text('Email',style: GoogleFonts.montserrat(fontSize: 20),),
              //         SizedBox(height: height * 0.03,),
              //         Text('Phone',style: GoogleFonts.montserrat(fontSize: 20),),
              //         SizedBox(height: height * 0.03,),
              //         Text('User Position',style: GoogleFonts.montserrat(fontSize: 20),),
              //       ],
              //     ),
              //
              //     SizedBox(width: width * 0.02,),
              //
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(currentUserInfo!.name!,style: const TextStyle(fontSize: 20,color: Color(0xff707070))),
              //         SizedBox(height: height * 0.03,),
              //         Text(currentUserInfo!.email!,style: const TextStyle(fontSize: 20,color: Color(0xff707070))),
              //         SizedBox(height: height * 0.03,),
              //         Text(currentUserInfo!.phone!,style: const TextStyle(fontSize: 20,color: Color(0xff707070))),
              //         SizedBox(height: height * 0.03,),
              //         Text(currentUserInfo!.userPosition!,style: const TextStyle(fontSize: 20,color: Color(0xff707070))),
              //       ],
              //     )
              //   ],
              // ),

              SizedBox(height: height * 0.07,),

              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const ProfileScreenEdit()));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: (Colors.grey.shade100),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
                    ),
                    child: Text(
                      "Edit Profile",
                      style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),
                  ),
                ),
              ),


            ],
          ),
        ),
      ) :

      (ResponsiveWidget.isMediumScreen(context)) ?
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Responsive layout:' + width.toString()),
              const Text('Profile Information',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 30),),
              SizedBox(height: height * 0.05,),
              // Image circle
              Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: Colors.black54,
                    ),

                  ),

                  child: (imageUrl == null) ?
                  ClipOval(
                    child: ImageNetwork(
                      height: 150,
                      width: 150,
                      image: currentUserInfo!.imageUrl!,
                    ),
                  ) :

                  ClipOval(
                    child: ImageNetwork(
                      height: 150,
                      width: 150,
                      image: imageUrl!,
                    ),
                  )
              ),
              // Upload image Circle
              Container(
                transform: Matrix4.translationValues(0.0, -35.0, 0.0),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50)),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50)),
                    child: IconButton(
                        onPressed: () async {
                          var snackBar = const SnackBar(content: Text('Work in progress'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.grey.shade400,
                        ))),
              ),


              Transform.translate(
                offset: const Offset(0,-20),
                child: Text(
                  currentUserInfo!.name!,
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 22
                  ),
                ),
              ),

              Transform.translate(
                offset: const Offset(0,-10),
                child: Text(
                  currentUserInfo!.phone!,
                  style: GoogleFonts.montserrat(
                      color: Colors.grey.shade500,
                      fontSize: 15
                  ),
                ),
              ),

              SizedBox(height: height * 0.05,),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text('Name',style: GoogleFonts.montserrat(fontSize: 20),),
              //         SizedBox(height: height * 0.03,),
              //         Text('Email',style: GoogleFonts.montserrat(fontSize: 20),),
              //         SizedBox(height: height * 0.03,),
              //         Text('Phone',style: GoogleFonts.montserrat(fontSize: 20),),
              //         SizedBox(height: height * 0.03,),
              //         Text('User Position',style: GoogleFonts.montserrat(fontSize: 20),),
              //       ],
              //     ),
              //
              //     SizedBox(width: width * 0.02,),
              //
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(currentUserInfo!.name!,style: const TextStyle(fontSize: 20,color: Color(0xff707070))),
              //         SizedBox(height: height * 0.03,),
              //         Text(currentUserInfo!.email!,style: const TextStyle(fontSize: 20,color: Color(0xff707070))),
              //         SizedBox(height: height * 0.03,),
              //         Text(currentUserInfo!.phone!,style: const TextStyle(fontSize: 20,color: Color(0xff707070))),
              //         SizedBox(height: height * 0.03,),
              //         Text(currentUserInfo!.userPosition!,style: const TextStyle(fontSize: 20,color: Color(0xff707070))),
              //       ],
              //     )
              //   ],
              // ),

              SizedBox(height: height * 0.07,),

              SizedBox(
                height: 40,
                width: width * 0.2,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> const ProfileScreenEdit()));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: (Colors.grey.shade100),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
                  ),
                  child: Text(
                    "Edit Profile",
                    style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    ),
                  ),
                ),
              ),


            ],
          ),
        ),
      ) :

      Row(
        children: [
          Stack(
            children: [
              NavigationRail(
                extended: isExpanded,
                selectedIndex: selectedIndex,
                backgroundColor: AppColors.mainBlueColor,
                selectedLabelTextStyle:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                unselectedLabelTextStyle: TextStyle(color: Colors.grey.shade300),
                selectedIconTheme: const IconThemeData(color: Colors.white),
                unselectedIconTheme: const IconThemeData(color: Colors.white, opacity: 0.5),
                onDestinationSelected: (int index) {
                  setState(() {
                    selectedIndex = index;
                    if(index == 0){
                      print(currentUserInfo!.userPosition);
                      if(currentUserInfo!.userPosition == "Executive Director" || currentUserInfo!.userPosition == "Developer"){
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const SuperAdminDashboard()));
                      }
                      else{
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const SubAdminDashboard()));
                      }
                    }
                    if(index == 1){
                      var snackBar = const SnackBar(content: Text('Work in progress!'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }

                    if (index == 3) {
                      showDialog(
                        //show confirm dialogue
                        //the return value will be from "Yes" or "No" options
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content:
                          const Text('Are you sure you want to sign out'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              //return false when click on "NO"
                              child: const Text('No'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                                firebaseAuth.signOut();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()));
                              },
                              //return true when click on "Yes"
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      ) ??
                          false;
                    }
                    else if (index == 0){
                      if(currentUserInfo!.userPosition == "Digital Marketing Executive"){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SuperAdminDashboard()));
                      }

                      else{
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SubAdminDashboard()));
                      }

                    }
                  });
                },
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text("Home"),

                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart),
                    label: Text("Reports"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person),
                    label: Text("Profile"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.logout),
                    label: Text("Logout"),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 15,
                child: IconButton(
                  onPressed: () {
                    //let's trigger the navigation expansion
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  icon: const Icon(Icons.menu,color: Colors.white,),
                ),
              )
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon button and Circle Avatar
                  const Text('Profile Information',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 30),),
                  SizedBox(height: height * 0.05,),
                  // Image circle
                  Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2,
                          color: Colors.black54,
                        ),

                      ),

                      child: (imageUrl == null) ?
                      ClipOval(
                        child: ImageNetwork(
                          height: 150,
                          width: 150,
                          image: currentUserInfo!.imageUrl!,
                        ),
                      ) :

                      ClipOval(
                        child: ImageNetwork(
                          height: 150,
                          width: 150,
                          image: imageUrl!,
                        ),
                      )
                  ),
                  // Upload image Circle
                  Container(
                    transform: Matrix4.translationValues(0.0, -35.0, 0.0),
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50)),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(50)),
                        child: IconButton(
                            onPressed: () async {
                              var snackBar = const SnackBar(content: Text('Work in progress'));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            },
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.grey.shade400,
                            ))),
                  ),


                  Transform.translate(
                    offset: const Offset(0,-20),
                    child: Text(
                      currentUserInfo!.name!,
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 22
                      ),
                    ),
                  ),

                  Transform.translate(
                    offset: const Offset(0,-10),
                    child: Text(
                      currentUserInfo!.phone!,
                      style: GoogleFonts.montserrat(
                          color: Colors.grey.shade500,
                          fontSize: 15
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.05,),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name
                          Text(
                            "Name",
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          TextFormField(
                            controller: nameTextEditingController,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Name",
                              hintText: "Name",
                              prefixIcon: IconButton(
                                icon: const Icon(Icons.person,color: Colors.black,),
                                onPressed: () {},
                              ),
                              suffixIcon: nameTextEditingController.text.isEmpty
                                  ? Container(width: 0)
                                  : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    nameTextEditingController.clear(),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade500),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),
                              ),
                              hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                              labelStyle:
                              const TextStyle(color: Colors.black, fontSize: 15),
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
                          SizedBox(
                            height: height * 0.02,
                          ),
                        ],
                      ),

                      // Email
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Last Name
                          Text(
                            "Email",
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          TextFormField(
                            readOnly: true,
                            controller: emailTextEditingController,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Email",
                              hintText: "Email",
                              prefixIcon: IconButton(
                                icon: const Icon(Icons.email,color: Colors.black,),
                                onPressed: () {},
                              ),
                              suffixIcon: emailTextEditingController.text.isEmpty
                                  ? Container(width: 0)
                                  : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    emailTextEditingController.clear(),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade500),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),
                              ),
                              hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                              labelStyle:
                              const TextStyle(color: Colors.black, fontSize: 15),
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
                          SizedBox(
                            height: height * 0.02,
                          ),
                        ],
                      ),

                      // Phone
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Last Name
                          Text(
                            "Email",
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          TextFormField(
                            controller: phoneTextEditingController,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Phone Number",
                              hintText: "Phone Number",
                              prefixIcon: IconButton(
                                icon: const Icon(Icons.phone,color: Colors.black,),
                                onPressed: () {},
                              ),
                              suffixIcon: phoneTextEditingController.text.isEmpty
                                  ? Container(width: 0)
                                  : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    phoneTextEditingController.clear(),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade500),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),
                              ),
                              hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                              labelStyle:
                              const TextStyle(color: Colors.black, fontSize: 15),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "The field is empty";
                              }

                              else if (int.parse(phoneTextEditingController.text) != 11){
                                return "Invalid phone number format";
                              }

                              else {
                                return null;
                              }
                            },

                          ),
                          SizedBox(
                            height: height * 0.02,
                          ),
                        ],
                      ),

                      // User Position
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Last Name
                          Text(
                            "User Position",
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          TextFormField(
                            controller: currentUserPositionTextEditingController,
                            readOnly: true,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "User Position",
                              hintText: "User Position",
                              prefixIcon: IconButton(
                                icon: const Icon(Icons.verified_user,color: Colors.black,),
                                onPressed: () {},
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade500),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),
                              ),
                              hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                              labelStyle:
                              const TextStyle(color: Colors.black, fontSize: 15),
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
                          SizedBox(
                            height: height * 0.02,
                          ),
                        ],
                      ),

                    ],
                  ),

                  SizedBox(height: height * 0.07,),

                  SizedBox(
                    height: 40,
                    width: width * 0.2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const ProfileScreenEdit()));
                      },
                      style: ElevatedButton.styleFrom(
                        primary: (Colors.grey.shade100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
                      ),
                      child: Text(
                        "Edit Profile",
                        style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                        ),
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
