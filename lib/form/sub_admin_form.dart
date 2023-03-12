import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import '../app_colors.dart';
import '../widget/responsive_layout.dart';

class DataInputForm extends StatefulWidget {
  const DataInputForm({Key? key}) : super(key: key);

  @override
  State<DataInputForm> createState() => _DataInputFormState();
}

class _DataInputFormState extends State<DataInputForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController campaignNameTextEditingController = TextEditingController();
  TextEditingController campaignLinkTextEditingController = TextEditingController();
  TextEditingController budgetTextEditingController = TextEditingController();
  TextEditingController totalSpentTextEditingController = TextEditingController();
  var selectedClient;
  String? pickedFileType;

  List<String> degreeList = [];
  DateTime startingDate = DateTime.now();
  DateTime endingDate = DateTime.now();
  String? formattedStartingDate,formattedEndingDate;
  int startingDateCounter = 0, endingDateCounter = 0;
  bool flag = false, flag2 = false;
  //PlatformFile? pickedFile;
  Uint8List? pickedFile;
  var pdfFileUrl;
  UploadTask? uploadTask;
  String? filename;


  Future selectFile() async {
    try{
      final result = await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions: ['pdf','xlsx']);
      if(result == null){
        return;
      }

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          }
      );

      pickedFile = result.files.single.bytes;
      filename = path.basename(result.files.single.name);
      int idx = filename!.indexOf(".");
      List parts = [filename!.substring(0,idx).trim(), filename!.substring(idx+1).trim()];
      print(parts);
      if(parts[1] == "pdf"){
        pickedFileType = "pdf";
      }
      else{
        pickedFileType = "excel";
      }

      setState(() {
      });

      Navigator.pop(context);
      var snackBar = const SnackBar(content: Text("File uploaded successfully"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    catch(e){
      print(e);
    }
  }

  Future<void> uploadFile() async {
    late firebase_storage.Reference reference;
    //final path = 'files/${pickedFile!.}';
    reference = firebase_storage.FirebaseStorage.instance.ref('campaignPdfs/'+ filename!,);

    // Upload the image to firebase storage
    try{
      uploadTask = reference.putData(pickedFile!);
      final snapshot = await uploadTask!.whenComplete((){});
      pdfFileUrl = await snapshot.ref.getDownloadURL();

      print(pdfFileUrl.toString());

    }

    catch(e){
      print(e.toString());
    }

    //String url = await reference.getDownloadURL();
    //return url;
  }


  pickStartingDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), //get today's date
        firstDate:DateTime.now(), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2030)
    );

    if(pickedDate != null ){
      setState(() {
        startingDate = pickedDate;
        formattedStartingDate = DateFormat('dd-MM-yyyy').format(startingDate);
        startingDateCounter++;
        flag = true;
      });
    }

    else{
      print("Date is not selected");
    }

  }
  pickEndingDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), //get today's date
        firstDate:DateTime.now(), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2030)
    );

    if(pickedDate != null ){
      setState(() {
        endingDate = pickedDate;
        formattedEndingDate = DateFormat('dd-MM-yyyy').format(endingDate);
        endingDateCounter++;
        flag2 = true;
      });
    }

    else{
      print("Date is not selected");
    }

  }

  String idGenerator() {
    final now = DateTime.now();
    return now.microsecondsSinceEpoch.toString();
  }

  saveDataToDatabase(){
    Map<String,dynamic> data = {
      'campaignName' : campaignNameTextEditingController.text,
      'campaignLink' : campaignLinkTextEditingController.text,
      'client' : selectedClient.toString(),
      'budget' : budgetTextEditingController.text,
      'totalSpent' : totalSpentTextEditingController.text,
      'startingDate' : formattedStartingDate,
      'endingDate' : formattedEndingDate,
      'pdfLink' : pdfFileUrl,
      'status' : "Ongoing"
    };
    FirebaseFirestore.instance.collection('campaignData').doc(idGenerator()).set(data);
    setState(() {
      startingDateCounter = 0;
      endingDateCounter = 0;
      selectedClient = null;
      pickedFile = null;
    });
    campaignNameTextEditingController.clear();
    campaignLinkTextEditingController.clear();
    budgetTextEditingController.clear();
    totalSpentTextEditingController.clear();
    var snackBar = const SnackBar(content: Text('Data uploaded successfully'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                          'Input Data Form',
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
                              SizedBox(height: height * 0.05),
                              // Login text
                              Text(
                                "Media Buying Form",
                                style: GoogleFonts.raleway(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.blueDarkColor,
                                  fontSize: 30.0,
                                ),
                              ),

                              SizedBox(height: height * 0.02),
                              // Enter details text
                              Text('Enter media buying details\nin your form',
                                style: GoogleFonts.raleway(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textColor,
                                ),
                              ),

                              SizedBox(height: height * 0.05),

                              // Campaign Name
                              Text(
                                'Campaign Name',
                                style: GoogleFonts.raleway(
                                  fontSize: 12.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              TextFormField(
                                controller: campaignNameTextEditingController,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Campaign Name",
                                  suffixIcon: campaignNameTextEditingController.text.isEmpty
                                      ? Container(width: 0)
                                      : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () =>
                                        campaignNameTextEditingController.clear(),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  hintStyle:
                                  const TextStyle(color: AppColors.blueDarkColor, fontSize: 15),
                                  labelStyle:
                                  const TextStyle(
                                      color: AppColors.blueDarkColor, fontSize: 15),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "The field is empty";
                                  } else {
                                    return null;
                                  }
                                },
                              ),

                              SizedBox(height: height * 0.025),

                              // Campaign Link
                              Text(
                                'Campaign Link',
                                style: GoogleFonts.raleway(
                                  fontSize: 12.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              TextFormField(
                                controller: campaignLinkTextEditingController,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Campaign Link",
                                  suffixIcon: campaignLinkTextEditingController.text.isEmpty
                                      ? Container(width: 0)
                                      : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () =>
                                        campaignLinkTextEditingController.clear(),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  hintStyle:
                                  const TextStyle(color: AppColors.blueDarkColor, fontSize: 15),
                                  labelStyle:
                                  const TextStyle(
                                      color: AppColors.blueDarkColor, fontSize: 15),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "The field is empty";
                                  } else {
                                    return null;
                                  }
                                },
                              ),

                              SizedBox(height: height * 0.025),

                              // Client Name
                              Text(
                                'Client',
                                style: GoogleFonts.raleway(
                                  fontSize: 12.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              StreamBuilder(
                                stream: FirebaseFirestore.instance.collection('clientList').snapshots(),
                                builder: (context, snapshot){
                                  if (snapshot.hasError) return Text('Error = ${snapshot.error}');

                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }

                                  else{
                                    //selectedClient = snapshot.data!.docs[0].get('name');
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: DropdownButtonFormField(
                                        items: snapshot.data!.docs.map((value) {
                                          return DropdownMenuItem(
                                            value: value.get('name'),
                                            child: Text('${value.get('name')}'),
                                          );
                                        }).toList(),
                                        decoration:  InputDecoration(
                                          isDense: true,
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(width: 1.5, color: Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(10)
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(width: 1.5, color: Colors.grey.shade300),
                                          ),
                                        ) ,
                                        iconSize: 26,
                                        dropdownColor: Colors.white,
                                        isExpanded: true,
                                        value: selectedClient,
                                        hint: const Text(
                                          "Select a client",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: AppColors.blueDarkColor,
                                          ),
                                        ),
                                        onChanged: (newValue)
                                        {
                                          setState(() {
                                            selectedClient = newValue;
                                          });

                                        },

                                        validator: (value){
                                          if(value == null){
                                            return "Select a client";
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                      ),
                                    );
                                  }
                                },
                              ),

                              SizedBox(height: height * 0.025),

                              // Budget
                              Text(
                                'Budget',
                                style: GoogleFonts.raleway(
                                  fontSize: 12.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                controller: budgetTextEditingController,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  labelText: "Budget",
                                  suffixIcon: budgetTextEditingController.text.isEmpty
                                      ? Container(width: 0)
                                      : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () =>
                                        budgetTextEditingController.clear(),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  hintStyle:
                                  const TextStyle(color: AppColors.blueDarkColor, fontSize: 15),
                                  labelStyle:
                                  const TextStyle(
                                      color: AppColors.blueDarkColor, fontSize: 15),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "The field is empty";
                                  } else {
                                    return null;
                                  }
                                },
                              ),

                              SizedBox(height: height * 0.025),

                              // Budget
                              Text(
                                'Total Spent',
                                style: GoogleFonts.raleway(
                                  fontSize: 12.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                controller: totalSpentTextEditingController,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  labelText: "Total spent",
                                  suffixIcon: totalSpentTextEditingController.text.isEmpty
                                      ? Container(width: 0)
                                      : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () =>
                                        totalSpentTextEditingController.clear(),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  hintStyle:
                                  const TextStyle(color: AppColors.blueDarkColor, fontSize: 15),
                                  labelStyle:
                                  const TextStyle(
                                      color: AppColors.blueDarkColor, fontSize: 15),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "The field is empty";
                                  } else {
                                    return null;
                                  }
                                },
                              ),

                              SizedBox(height: height * 0.025),

                              // Select starting date
                              Text(
                                'Starting Date',
                                style: GoogleFonts.raleway(
                                  fontSize: 12.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 30.0),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300,width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    pickStartingDate();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: (Colors.white),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                                  ),
                                  child: Text(
                                    (startingDateCounter != 0) ? formattedStartingDate! : "Select starting date",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: height * 0.025),

                              // Select ending date
                              Text(
                                'Ending Date',
                                style: GoogleFonts.raleway(
                                  fontSize: 12.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300,width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    pickEndingDate();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: (Colors.white),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                                  ),
                                  child: Text(
                                    (endingDateCounter != 0) ? formattedEndingDate! : "Select ending date",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: height * 0.02),

                              // File Picker
                              GestureDetector(
                                onTap: () async {
                                  await selectFile();
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(25),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 0.5,
                                      style: BorderStyle.solid,
                                    ),
                                  ) ,
                                  child: Row(
                                      children: [
                                        Icon(Icons.add,size: 30),

                                        const SizedBox(width: 10,),

                                        Expanded(
                                          child: Text(
                                              "Upload your excel/pdf file",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black
                                              )
                                          ),
                                        ),
                                      ]
                                  ),
                                ),
                              ),

                              // Container
                              Column(
                                children: [
                                  SizedBox(
                                      width: Get.width,
                                      height: height * 0.15,
                                      child: (pickedFile == null)
                                          ? const Center(
                                        child: Text("No File selected"),) :
                                      Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.topCenter,
                                        children: [
                                          Container(
                                            width: width * 0.05,
                                            height: height * 0.15,
                                            margin: const EdgeInsets.only(right: 10),
                                            decoration: (pickedFileType == 'pdf') ?
                                            const BoxDecoration(
                                              image: DecorationImage(image: AssetImage('assets/pdf.png'),fit: BoxFit.fitWidth)
                                            ) :

                                            const BoxDecoration(
                                                image: DecorationImage(image: AssetImage('assets/excel.png'),fit: BoxFit.fitWidth)
                                            ),
                                          ),

                                          SizedBox(
                                            width: width * 0.05,
                                            height: height * 0.15,
                                            child: Align(
                                              alignment: const Alignment(1, -1),
                                              child: IconButton(
                                                onPressed: (){
                                                  setState(() {
                                                    pickedFile = null;
                                                  });
                                                },
                                                icon: Image.asset(
                                                  'assets/cancel.png',
                                                  width: 25,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                  ),
                                  (pickedFile!=null) ? Text(filename!) : Text('')
                                ],
                              ),

                              SizedBox(height: height * 0.05),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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

                                          await uploadFile();
                                          await saveDataToDatabase();

                                          Timer(const Duration(seconds: 3), () {
                                            Navigator.pop(context);
                                            //Navigator.push(context, MaterialPageRoute(builder: (context) => const Initialization()));
                                          });
                                        }

                                        else{
                                          var snackBar = const SnackBar(content: Text('Fill up the login form correctly'));
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Ink(
                                        padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 18.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16.0),
                                          color: AppColors.mainBlueColor,
                                        ),
                                        child: Text(
                                          'Input',
                                          style: GoogleFonts.raleway(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.whiteColor,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: height * 0.05),


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
