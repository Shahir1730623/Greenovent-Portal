import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../global.dart';
import '../model/user_model.dart';
import 'dart:html' as html;
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../widget/dialog_widget.dart';
import '../../widget/dialog_widget2.dart';

class AssistantMethods{
  //PlatformFile? pickedFile;
  static String? pickedFileType;
  static Uint8List? pickedFile;
  static var pdfFileUrl;
  static UploadTask? uploadTask;
  static String? filename;


  static Future selectFile(BuildContext context) async {
    try{
      final result = await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions: ['pdf','xlsx']);
      if(result == null){
        return;
      }

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

    }

    catch(e){
      print(e);
    }
  }

  static Future<void> uploadFile() async {
    late firebase_storage.Reference reference;
    //final path = 'files/${pickedFile!.}';
    reference = firebase_storage.FirebaseStorage.instance.ref('campaignPdfs/${filename!}',);

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
  }

  static readCurrentOnlineUserInfo() async {
    currentFirebaseUser = firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection("users")
        .doc(currentFirebaseUser!.uid)
        .get()
        .then((documentSnapshot)
    {
      if(documentSnapshot.exists){
        currentUserInfo = UserModel.fromSnapshot(documentSnapshot);
      }

      else {
        print('Document does not exist on the database');
      }
    });
  }

  static createColumns(){
    return const [
      DataColumn(label: Text("SL No")),
      DataColumn(label: Text("Bill No")),
      DataColumn(label: Text("Campaign Name")),
      DataColumn(label: Text("Campaign Link")),
      DataColumn(label: Text("Description")),
      DataColumn(label: Text("Client")),
      DataColumn(label: Text("Project Goal")),
      DataColumn(label: Text("Sales")),
      DataColumn(label: Text("ASF")),
      DataColumn(label: Text("Subtotal")),
      DataColumn(label: Text("Amount Vat")),
      DataColumn(label: Text("AIT")),
      DataColumn(label: Text("Expense")),
      DataColumn(label: Text("Total Expense")),
      DataColumn(label: Text("Gross Profit")),
      DataColumn(label: Text("Bill Sent")),
      DataColumn(label: Text("Bill Received")),
      DataColumn(label: Text("Bill Status")),
      DataColumn(label: Text("Starting Date")),
      DataColumn(label: Text("Ending Date")),
      DataColumn(label: Text("File")),
      DataColumn(label: Text("Status")),
      DataColumn(label: Text("Last Edited By")),
      DataColumn(label: Text("")),
    ];
  }

  static void downloadFile(String url) {
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }



  static String getTodayDate(){
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return formattedDate; // prints today's date in the format dd/MM/yyyy
  }



}