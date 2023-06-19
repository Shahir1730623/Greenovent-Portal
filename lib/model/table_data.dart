import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greenovent_portal/assistant_method/assistant_method.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../global.dart';
import '../widget/dialog_widget.dart';
import '../widget/dialog_widget2.dart';
import 'data_model.dart';

class MyDataSource extends DataTableSource {
  final List<CampaignData> data;
  final BuildContext context;
  MyDataSource(this.data,this.context);

  DateTime startingDate = DateTime.now();
  DateTime endingDate = DateTime.now();
  String? formattedStartingDate,formattedEndingDate;
  int startingDateCounter = 0, endingDateCounter = 0;
  bool flag = false, flag2 = false;

  pickStartingDate(BuildContext context) async {
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


  pickEndingDate(BuildContext context) async {
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

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  DataRow getRow(int index) {
    final CollectionReference campaignCollectionReference = FirebaseFirestore.instance.collection('campaignData');
    return DataRow.byIndex(
        index: index,
        color: data[index].billStatus == 'Received'
            ? MaterialStateColor.resolveWith((states) => Colors.green)
            : data[index].billStatus  == 'Sent'
            ? MaterialStateColor.resolveWith((states) => Colors.yellow)
            : data[index].billStatus  == 'Processing' ?
        MaterialStateColor.resolveWith((states) => Colors.orange)
            : MaterialStateColor.resolveWith((states) => Colors.transparent),
        cells: [
          DataCell(
            Text((index + 1).toString()),
          ),

          DataCell(
            Text(data[index].billNo),
          ),

          DataCell(
            Text(data[index].campaignName),
          ),

          DataCell(
              SizedBox(
                width: 200,
                child: TextButton(
                  onLongPress: () async{
                    final updatedLink = await showTextDialog2(
                        context,
                        title: 'Change Link',
                        value: data[index].campaignLink
                    );
                    if (updatedLink != null) {
                      Map<String, dynamic> updatedLinkMap = {
                        'campaignLink' : updatedLink,
                        'lastEditedBy': currentUserInfo?.name
                      };
                      campaignCollectionReference.doc(data[index].id).update(updatedLinkMap);
                    }
                  },
                  onPressed: () async{
                    _launchURL(data[index].campaignLink);
                  },
                  child: Text(
                    data[index].campaignLink,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
              ),
          ),

          DataCell(
            Text(data[index].description),
          ),

          DataCell(
            Text(data[index].client),
          ),

          DataCell(
            Text(data[index].projectGoal.toStringAsFixed(0)),
          ),

          DataCell(
            Text(data[index].sales.toStringAsFixed(0)),
            showEditIcon: true,
            onTap: () async {
              {
                final updatedSales = await showTextDialog2(
                  context,
                  title: 'Change sales',
                  value: data[index].sales.toString(),
                );

                if(updatedSales!=null){
                  double sales = double.parse(updatedSales);

                  // Get the document from the 'clients' collection
                  var snapshot = await FirebaseFirestore.instance
                      .collection('clientList')
                      .where('name', isEqualTo: data[index].client)
                      .get();
                  DocumentSnapshot clientSnapshot = snapshot.docs.first;
                  Map<String, dynamic> clientData = clientSnapshot.data() as Map<String, dynamic>;
                  // Extract the vat and ait fields from the document
                  double asfPercentage = clientData['ASF'] ?? 0.0;
                  int vatPercentage = clientData['vat'] ?? 0;
                  double aitPercentage = clientData['AIT'] ?? 0.0;

                  double ASF = sales * (asfPercentage / 100);
                  double subTotal = sales + ASF;
                  double amountVat = subTotal * (vatPercentage / 100);
                  double projectGoal = subTotal + amountVat;
                  double AIT = subTotal * (aitPercentage / 100);
                  double totalExpense = data[index].expense + amountVat + AIT;
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

                  campaignCollectionReference.doc(data[index].id).update(updatedSalesMap);
                }
              }
            }
          ),
          //
          DataCell(
            Text(data[index].asf.toStringAsFixed(0)),
          ),

          DataCell(
            Text(data[index].subTotal.toStringAsFixed(0)),
          ),

          DataCell(
            Text(data[index].amountVat.toStringAsFixed(0)),
          ),

          DataCell(
            Text(data[index].ait.toStringAsFixed(0)),
          ),

          DataCell(
              Text(data[index].expense.toStringAsFixed(0)),
              showEditIcon: true,
              onTap: () async {
                final updatedExpense = await showTextDialog2(
                  context,
                  title: 'Change expense',
                  value: data[index].expense.toString(),
                );

                if(updatedExpense != null){
                  double expense = double.parse(updatedExpense);

                  // Get the document from the 'clients' collection
                  var snapshot = await FirebaseFirestore.instance
                      .collection('clientList')
                      .where('name', isEqualTo: data[index].client)
                      .get();
                  DocumentSnapshot clientSnapshot = snapshot.docs.first;
                  Map<String, dynamic> clientData = clientSnapshot.data() as Map<String, dynamic>;
                  // Extract the vat and ait fields from the document
                  int vatPercentage = clientData['vat'] ?? 0;
                  double aitPercentage = clientData['AIT'] ?? 0.0;

                  // Use these values to calculate totalExpense and grossProfit
                  double totalExpense = expense + (data[index].subTotal * (vatPercentage / 100))  + (data[index].subTotal * (aitPercentage/100));
                  double grossProfit = data[index].projectGoal - totalExpense;

                  Map<String, dynamic> updatedMap = {
                    'expense' : expense,
                    'totalExpense' : totalExpense,
                    'grossProfit' : grossProfit,
                    'lastEditedBy': currentUserInfo?.name
                  };

                  campaignCollectionReference.doc(data[index].id).update(updatedMap);
                }
              }
          ),


          DataCell(
            Text(data[index].totalExpense.toStringAsFixed(0)),
          ),

          DataCell(
            Text(data[index].grossProfit.toStringAsFixed(0)),
          ),

          DataCell(
            Text(data[index].billSent.toStringAsFixed(0)),
            showEditIcon: true,
            onTap: () async {
              final billSent = await showTextDialog2(
                context,
                title: 'Change bill sent',
                value: data[index].billSent.toString(),
              );

              if(billSent!=null){
                Map<String, dynamic> updateBillSentMap = {
                  'billSent' : double.parse(billSent),
                  'lastEditedBy': currentUserInfo?.name
                };

                campaignCollectionReference.doc(data[index].id).update(updateBillSentMap);
              }

            },
          ),

          DataCell(
            Text(data[index].billReceived.toStringAsFixed(0)),
            showEditIcon: true,
            onTap: () async {
              final billSent = await showTextDialog2(
                context,
                title: 'Change bill received',
                value: data[index].billSent.toString(),
              );

              if(billSent!=null){
                Map<String, dynamic> updateBillSentMap = {
                  'billReceived' : double.parse(billSent),
                  'lastEditedBy': currentUserInfo?.name
                };

                campaignCollectionReference.doc(data[index].id).update(updateBillSentMap);
              }

            },
          ),

          DataCell(
            Text(data[index].billStatus),
            showEditIcon: true,
            onTap: () async {
              final billStatus = await showTextDialog(
                context,
                title: 'Change Bill Status',
                value: data[index].billStatus.toString(),
              );

              if(billStatus!=null){
                Map<String, dynamic> updateBillStatusMap = {
                  'billStatus' : billStatus,
                  'lastEditedBy': currentUserInfo?.name
                };

                campaignCollectionReference.doc(data[index].id).update(updateBillStatusMap);
              }

            },
          ),

          DataCell(
            Text(data[index].startingDate),
            showEditIcon: true,
            onTap: () async {
              await pickStartingDate(context);
              if(formattedStartingDate != null){
                Map<String, dynamic> updatedDateMap = {
                  'startingDate' : formattedStartingDate,
                  'lastEditedBy': currentUserInfo?.name
                };

                campaignCollectionReference.doc(data[index].id).update(updatedDateMap);
              }
            },
          ),

          DataCell(
              Text(data[index].endingDate),
              showEditIcon: true,
              onTap: () async{
                await pickEndingDate(context);
                if(formattedEndingDate != null){
                  Map<String, dynamic> updatedDateMap = {
                    'endingDate' : formattedEndingDate,
                    'lastEditedBy': currentUserInfo?.name
                  };

                  campaignCollectionReference.doc(data[index].id).update(updatedDateMap);
                }
              },
          ),

          DataCell(
            onTap: () async {
              await AssistantMethods.selectFile(context);
              if(AssistantMethods.pickedFile != null){
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(child: CircularProgressIndicator());
                    }
                );

                await AssistantMethods.uploadFile();
                campaignCollectionReference.doc(data[index].id).update({'pdfLink': AssistantMethods.pdfFileUrl});
                Navigator.pop(context);
                var snackBar = const SnackBar(content: Text("File uploaded successfully"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }


            },
            SizedBox(
              width: 300,
              child: TextButton(
                onPressed: () {
                  if(data[index].pdfLink.isNotEmpty) {
                    AssistantMethods.downloadFile(data[index].pdfLink);
                  }

                },
                child: Text(
                  data[index].pdfLink,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
            ),
          ),

          DataCell(
            Text(data[index].status),
            showEditIcon: true,
            onTap: () async {
              final status = await showTextDialog(
                context,
                title: 'Change Status',
                value: data[index].status,
              );
              if(status!=null){
                Map<String, dynamic> updatedStatusMap = {
                  'status' : status,
                  'lastEditedBy': currentUserInfo?.name
                };

                campaignCollectionReference.doc(data[index].id).update(updatedStatusMap);
              }

            },
          ),

          DataCell(
            Text(data[index].lastEditedBy),
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
                      campaignCollectionReference.doc(data[index].id).delete();
                    },
                    //return true when click on "Yes"
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );
          }
          )
        ]
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}