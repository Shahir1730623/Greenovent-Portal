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

  static DateTime startingDate = DateTime.now();
  static DateTime endingDate = DateTime.now();
  static String? formattedStartingDate,formattedEndingDate;
  static int startingDateCounter = 0, endingDateCounter = 0;
  static double? initialAit;
  static bool flag = false, flag2 = false;

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

  static List<DataRow> createRows(QuerySnapshot snapshot,BuildContext context) {
    List<DocumentSnapshot> docs = snapshot.docs;
    docs.sort((a, b) {
      Map<String, dynamic>? aData = a.data() as Map<String, dynamic>?;
      Map<String, dynamic>? bData = b.data() as Map<String, dynamic>?;
      int aSlNo = aData != null && aData.containsKey('slNo') ? aData['slNo'] : 0;
      int bSlNo = bData != null && bData.containsKey('slNo') ? bData['slNo'] : 0;
      return aSlNo.compareTo(bSlNo);
    });


    List<DataRow> newList = docs.map((DocumentSnapshot documentSnapshot)  {
      Map<String, dynamic> docData = documentSnapshot.data() as Map<String, dynamic>;
      return DataRow(
          color: documentSnapshot.get('billStatus') == 'Received'
              ? MaterialStateColor.resolveWith((states) => Colors.green)
              : documentSnapshot.get('billStatus') == 'Sent'
              ? MaterialStateColor.resolveWith((states) => Colors.yellow)
              : documentSnapshot.get('billStatus') == 'Processing' ?
                MaterialStateColor.resolveWith((states) => Colors.orange)
              : MaterialStateColor.resolveWith((states) => Colors.transparent),
          cells: [
            DataCell(
              Text(docData['slNo'].toString()),
            ),

            DataCell(
              Text(docData['billNo']),
            ),

            DataCell(
              Text(docData['campaignName']),
            ),

            DataCell(
              Text(docData['description']),
            ),

            DataCell(
              Text(docData['client']),
            ),

            DataCell(
              Text(docData['projectGoal'].toStringAsFixed(0)),
            ),

            DataCell(
              Text(docData['sales'].toStringAsFixed(0)),
              showEditIcon: true,
              onTap: () async {
                final updatedSales = await showTextDialog2(
                  context,
                  title: 'Change sales',
                  value: documentSnapshot.get('sales').toString(),
                );

                if(updatedSales!=null){
                  double sales = double.parse(updatedSales);
                  double ASF = sales * (documentSnapshot.get('ASFPercentage') / 100);
                  double subTotal = sales + ASF;
                  double amountVat = subTotal * (documentSnapshot.get('vatPercentage') / 100);
                  double projectGoal = subTotal + amountVat;
                  double AIT = subTotal * (documentSnapshot.get('AITPercentage') / 100);
                  double totalExpense = documentSnapshot.get('expense') + amountVat + AIT;
                  double grossProfit = projectGoal - totalExpense;

                  Map<String, dynamic> updatedSalesMap = {
                    'sales': sales,
                    'ASF': ASF,
                    'subTotal': subTotal,
                    'amountVat': amountVat,
                    'projectGoal': projectGoal,
                    'AIT': AIT,
                    'totalExpense' : totalExpense,
                    'grossProfit' : grossProfit,
                    'lastEditedBy': currentUserInfo?.name
                  };

                  documentSnapshot.reference.update(updatedSalesMap);
                }
              },
            ),

            DataCell(
              Text(docData['ASF'].toStringAsFixed(0)),
              showEditIcon: true,
              // onTap: () async {
              //   final updatedASF = await showTextDialog2(
              //     context,
              //     title: 'Change ASF',
              //     value: documentSnapshot.get('ASF').toString(),
              //   );
              //
              //   if(updatedASF!=null){
              //     double sales = double.parse(documentSnapshot.get('sales'));
              //     double subTotal = sales + double.parse(updatedASF);
              //     double amountVat = subTotal * (documentSnapshot.get('vatPercentage') / 100);
              //     double projectGoal = subTotal + amountVat;
              //     double AIT = subTotal * (documentSnapshot.get('AITPercentage') / 100);
              //     double totalExpense = documentSnapshot.get('expense') + amountVat + AIT;
              //     double grossProfit = projectGoal - totalExpense;
              //
              //     documentSnapshot.reference.update({'subTotal': subTotal});
              //     documentSnapshot.reference.update({'amountVat': amountVat});
              //     documentSnapshot.reference.update({'projectGoal': projectGoal});
              //     documentSnapshot.reference.update({'AIT': AIT});
              //     documentSnapshot.reference.update({'totalExpense' : totalExpense});
              //     documentSnapshot.reference.update({'grossProfit' : grossProfit});
              //     documentSnapshot.reference.update({'lastEditedBy': currentUserInfo?.name});
              //   }
              // },
            ),

            DataCell(
              Text(docData['subTotal'].toStringAsFixed(0)),

            ),

            DataCell(
              Text(docData['amountVat'].toStringAsFixed(0)),
            ),

            DataCell(
              Text(docData['AIT'].toStringAsFixed(0)),
              showEditIcon: true,
              onTap: () async {
                final updatedAIT = await showTextDialog2(
                  context,
                  title: 'Change AIT',
                  value: documentSnapshot.get('AIT').toString(),
                );

                if(updatedAIT!=null){
                  double AIT = double.parse(updatedAIT);
                  double totalExpense = documentSnapshot.get('expense') + documentSnapshot.get('amountVat') + AIT;
                  double grossProfit = documentSnapshot.get('projectGoal') - totalExpense;

                  Map<String, dynamic> updateAitMap = {
                    'AIT': AIT,
                    'totalExpense' : totalExpense,
                    'grossProfit' : grossProfit,
                    'lastEditedBy': currentUserInfo?.name
                  };

                  documentSnapshot.reference.update(updateAitMap);
                }
              },
            ),

            DataCell(
                Text(docData.containsKey('expense') ? docData['expense'].toStringAsFixed(0) : ''),
                showEditIcon: true,
                onTap: () async {
                  final updatedExpense = await showTextDialog2(
                    context,
                    title: 'Change expense',
                    value: documentSnapshot.get('expense').toString(),
                  );

                  if(updatedExpense != null){
                    double expense = double.parse(updatedExpense);
                    double totalExpense = expense + documentSnapshot.get('amountVat') + documentSnapshot.get('AIT');
                    double grossProfit = documentSnapshot.get('projectGoal') - totalExpense;

                    Map<String, dynamic> updateAitMap = {
                      'expense' : expense,
                      'totalExpense' : totalExpense,
                      'grossProfit' : grossProfit,
                      'lastEditedBy': currentUserInfo?.name
                    };

                    documentSnapshot.reference.update(updateAitMap);
                  }

                }

            ),

            DataCell(
              Text(docData.containsKey('totalExpense')
                  ? docData['totalExpense'].toStringAsFixed(0)
                  : ''),
            ),

            DataCell(
              Text(docData.containsKey('grossProfit')
                  ? docData['grossProfit'].toStringAsFixed(0)
                  : ''),
            ),

            DataCell(
              Text(docData.containsKey('billSent')
                  ? docData['billSent'].toStringAsFixed(0)
                  : ''),
              showEditIcon: true,
              onTap: () async {
                final billSent = await showTextDialog2(
                  context,
                  title: 'Change bill sent',
                  value: documentSnapshot.get('billSent').toString(),
                );

                if(billSent!=null){
                  documentSnapshot.reference.update({'billSent': double.parse(billSent)});
                  documentSnapshot.reference.update({'lastEditedBy': currentUserInfo?.name});
                }

              },
            ),

            DataCell(
              Text(docData.containsKey('billReceived')
                  ? docData['billReceived'].toStringAsFixed(0)
                  : ''),
              showEditIcon: true,
              onTap: () async {
                final billReceived = await showTextDialog2(
                  context,
                  title: 'Change bill received',
                  value: documentSnapshot.get('billReceived').toString(),
                );


                if(billReceived!=null){
                  documentSnapshot.reference.update({'billReceived': double.parse(billReceived)});
                  documentSnapshot.reference.update({'lastEditedBy': currentUserInfo?.name});
                }

              },
            ),

            DataCell(
              Text(docData['billStatus']),

              showEditIcon: true,
              onTap: () async {
                final billStatus = await showTextDialog(
                  context,
                  title: 'Change Bill Status',
                  value: documentSnapshot.get('billStatus').toString(),
                );

                if(billStatus!=null){
                  documentSnapshot.reference.update({'billStatus': billStatus});
                  documentSnapshot.reference.update({'lastEditedBy': currentUserInfo?.name});
                }

              },
            ),

            DataCell(
                showEditIcon: true,
                onTap: () async{
                  await pickStartingDate(context);
                  if(formattedStartingDate != null){
                    documentSnapshot.reference.update({'startingDate': formattedStartingDate});
                  }
                },
                Text(docData['startingDate'] ?? '')),

            DataCell(
                showEditIcon: true,
                onTap: () async{
                  await pickEndingDate(context);
                  if(formattedEndingDate != null){
                    documentSnapshot.reference.update({'endingDate': formattedEndingDate});
                  }
                },
                Text(docData['endingDate'] ?? '')),

            // DataCell(
            //   showEditIcon: true,
            //   onTap: () async {
            //     await selectFile(context);
            //     if(pickedFile != null){
            //       showDialog(
            //           context: context,
            //           barrierDismissible: false,
            //           builder: (BuildContext context) {
            //             return const Center(child: CircularProgressIndicator());
            //           }
            //       );
            //
            //       await uploadFile();
            //       documentSnapshot.reference.update({'pdfLink': pdfFileUrl});
            //       Navigator.pop(context);
            //       var snackBar = const SnackBar(content: Text("File uploaded successfully"));
            //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //     }
            //
            //
            //   },
            //   SizedBox(
            //     width: 300,
            //     child: TextButton(
            //       onPressed: () {
            //         if(docData['pdfLink'] != null) {
            //           downloadFile(docData['pdfLink']);
            //         }
            //
            //       },
            //
            //
            //       child: Text(docData['pdfLink'] ?? '',
            //         overflow: TextOverflow.ellipsis,
            //         softWrap: true,
            //       ),
            //     ),
            //   ),
            // ),

            DataCell(
              Text(documentSnapshot.data().toString().contains('status')
                  ? docData['status']
                  : ''),
              showEditIcon: true,
              onTap: () async {
                final status = await showTextDialog(
                  context,
                  title: 'Change Status',
                  value: documentSnapshot.get('status'),
                );
                if(status!=null){
                  documentSnapshot.reference.update({'status': status});
                  documentSnapshot.reference.update({'lastEditedBy': currentUserInfo?.name});
                }

              },
            ),

            DataCell(
              Text(documentSnapshot.data().toString().contains('lastEditedBy')
                  ? docData['lastEditedBy']
                  : ''),
            ),

            DataCell(const Icon(Icons.delete), onTap: () {
              showDialog(
                //show confirm dialogue
                //the return value will be from "Yes" or "No" options
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Row'),
                  content:
                  const Text('Are you sure you want to delete this row?'),
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
                        documentSnapshot.reference.delete();
                      },
                      //return true when click on "Yes"
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
            })
          ]
      );
    }).toList();

    return newList;
  }

  static createColumns(){
    return const [
      DataColumn(label: Text("SL No")),
      DataColumn(label: Text("Bill No")),
      DataColumn(label: Text("Campaign Name")),
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
    ];
  }

  static void downloadFile(String url) {
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }

  static pickStartingDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), //get today's date
        firstDate:DateTime.now(), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2030)
    );

    if(pickedDate != null ){
      startingDate = pickedDate;
      formattedStartingDate = DateFormat('dd-MM-yyyy').format(startingDate);
      startingDateCounter++;
      flag = true;
    }

    else{
      debugPrint("Date is not selected");
    }

  }

  static pickEndingDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), //get today's date
        firstDate:DateTime.now(), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2030)
    );

    if(pickedDate != null ){
      endingDate = pickedDate;
      formattedEndingDate = DateFormat('dd-MM-yyyy').format(endingDate);
      endingDateCounter++;
      flag2 = true;
    }

    else{
      debugPrint("Date is not selected");
    }

  }

  static String getTodayDate(){
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return formattedDate; // prints today's date in the format dd/MM/yyyy
  }



}