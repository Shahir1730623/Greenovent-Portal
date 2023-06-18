import 'package:flutter/material.dart';

import 'data_model.dart';

class MyDataSource extends DataTableSource {
  final List<CampaignData> data;
  MyDataSource(this.data);

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(
        index: index,
        cells: [
          DataCell(
            Text((index + 1).toString()),
          ),

          DataCell(
            // data.id.toString()
            Text(data[index].billNo),
          ),

          DataCell(
            Text(data[index].campaignName),
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
          ),
          //
          DataCell(
            Text(data[index].asf.toStringAsFixed(0)),
          ),

          DataCell(
            Text(data[index].subTotal.toStringAsFixed(0)),
            showEditIcon: true,
          ),

          DataCell(
            Text(data[index].amountVat.toStringAsFixed(0)),
          ),

          DataCell(
            Text(data[index].ait.toStringAsFixed(0)),
            showEditIcon: true,
          ),

          DataCell(
            Text(data[index].expense.toStringAsFixed(0)),
            showEditIcon: true,
            // onTap: () async {
            //   final updatedExpense = await showTextDialog2(
            //     context,
            //     title: 'Change expense',
            //     value: documentSnapshot.get('expense').toString(),
            //   );
            //
            //   if(updatedExpense != null){
            //     double expense = double.parse(updatedExpense);
            //     double totalExpense = expense + documentSnapshot.get('amountVat') + documentSnapshot.get('AIT');
            //     double grossProfit = documentSnapshot.get('projectGoal') - totalExpense;
            //
            //     Map<String, dynamic> updateAitMap = {
            //       'expense' : expense,
            //       'totalExpense' : totalExpense,
            //       'grossProfit' : grossProfit,
            //       'lastEditedBy': currentUserInfo?.name
            //     };
            //
            //     documentSnapshot.reference.update(updateAitMap);
            //   }
            //
            // }
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
            // onTap: () async {
            //   final billSent = await showTextDialog2(
            //     context,
            //     title: 'Change bill sent',
            //     value: documentSnapshot.get('billSent').toString(),
            //   );
            //
            //   if(billSent!=null){
            //     documentSnapshot.reference.update({'billSent': double.parse(billSent)});
            //     documentSnapshot.reference.update({'lastEditedBy': currentUserInfo?.name});
            //   }
            //
            // },
          ),

          DataCell(
            Text(data[index].billReceived.toStringAsFixed(0)),
            showEditIcon: true,
            // onTap: () async {
            //   final billReceived = await showTextDialog2(
            //     context,
            //     title: 'Change bill received',
            //     value: documentSnapshot.get('billReceived').toString(),
            //   );
            //
            //
            //   if(billReceived!=null){
            //     documentSnapshot.reference.update({'billReceived': double.parse(billReceived)});
            //     documentSnapshot.reference.update({'lastEditedBy': currentUserInfo?.name});
            //   }
            //
            // },
          ),

          DataCell(
            Text(data[index].billStatus),
            showEditIcon: true,
            // onTap: () async {
            //   final billStatus = await showTextDialog(
            //     context,
            //     title: 'Change Bill Status',
            //     value: documentSnapshot.get('billStatus').toString(),
            //   );
            //
            //   if(billStatus!=null){
            //     documentSnapshot.reference.update({'billStatus': billStatus});
            //     documentSnapshot.reference.update({'lastEditedBy': currentUserInfo?.name});
            //   }
            //
            // },
          ),

          DataCell(
            showEditIcon: true,
            // onTap: () async{
            //   await pickStartingDate(context);
            //   if(formattedStartingDate != null){
            //     documentSnapshot.reference.update({'startingDate': formattedStartingDate});
            //   }
            // },
            Text(data[index].startingDate),
          ),

          DataCell(
              showEditIcon: true,
              // onTap: () async{
              //   await pickEndingDate(context);
              //   if(formattedEndingDate != null){
              //     documentSnapshot.reference.update({'endingDate': formattedEndingDate});
              //   }
              // },
              Text(data[index].endingDate)
          ),

          DataCell(
            showEditIcon: true,
            // onTap: () async {
            //   await selectFile(context);
            //   if(pickedFile != null){
            //     showDialog(
            //         context: context,
            //         barrierDismissible: false,
            //         builder: (BuildContext context) {
            //           return const Center(child: CircularProgressIndicator());
            //         }
            //     );
            //
            //     await uploadFile();
            //     documentSnapshot.reference.update({'pdfLink': pdfFileUrl});
            //     Navigator.pop(context);
            //     var snackBar = const SnackBar(content: Text("File uploaded successfully"));
            //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //   }
            //
            //
            // },
            SizedBox(
              width: 300,
              child: TextButton(
                onPressed: () {
                  // if(data[index].file.isNotEmpty) {
                  //   downloadFile(docData['pdfLink']);
                  // }

                },


                child: Text(data[index].pdfLink,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
            ),
          ),

          DataCell(
            Text(data[index].status),
            showEditIcon: true,
            // onTap: () async {
            //   final status = await showTextDialog(
            //     context,
            //     title: 'Change Status',
            //     value: documentSnapshot.get('status'),
            //   );
            //   if(status!=null){
            //     documentSnapshot.reference.update({'status': status});
            //     documentSnapshot.reference.update({'lastEditedBy': currentUserInfo?.name});
            //   }
            //
            // },
          ),

          DataCell(
            Text(data[index].lastEditedBy),
          ),

          // DataCell(const Icon(Icons.delete), onTap: () {
          //   showDialog(
          //     //show confirm dialogue
          //     //the return value will be from "Yes" or "No" options
          //     context: context,
          //     builder: (context) => AlertDialog(
          //       title: const Text('Delete Row'),
          //       content:
          //       const Text('Are you sure you want to delete this row?'),
          //       actions: [
          //         ElevatedButton(
          //           onPressed: () {
          //             Navigator.of(context).pop(false);
          //           },
          //           //return false when click on "NO"
          //           child: const Text('No'),
          //         ),
          //         ElevatedButton(
          //           onPressed: () {
          //             Navigator.of(context).pop(false);
          //             documentSnapshot.reference.delete();
          //           },
          //           //return true when click on "Yes"
          //           child: const Text('Yes'),
          //         ),
          //       ],
          //     ),
          //   );
          // }
          // )
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