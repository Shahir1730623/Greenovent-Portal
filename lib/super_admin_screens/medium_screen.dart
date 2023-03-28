import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import '../form/sub_admin_form.dart';
import '../global.dart';
import '../widget/dialog_widget.dart';
import '../widget/dialog_widget2.dart';
import '../widget/dialog_widget_add_client.dart';

class MediumScreenWidget extends StatefulWidget {
  const MediumScreenWidget({Key? key}) : super(key: key);

  @override
  State<MediumScreenWidget> createState() => _MediumScreenWidgetState();
}

class _MediumScreenWidgetState extends State<MediumScreenWidget> {
  //setting the expansion function for the navigation rail
  TextEditingController clientAddController = TextEditingController();
  TextEditingController searchTextEditingController = TextEditingController();
  bool isExpanded = false;
  int selectedIndex = 0;
  var search;
  var selectedClient;
  var selectedMonth;
  String? selectedStatus;
  String? selectedFilter;
  List<String> monthList = ["January","February","March","April","May","June","July","August","September","October","November","December"];
  List<String> filterByList = ["Date", "Revenue"];
  List<String> statusList = ["Ongoing", "Completed"];
  double totalEarning = 0,
      totalDue = 0,
      grossProfit = 0,
      ongoingCampaignRevenue = 0,
      pastCampaignRevenue = 0,
      pastCampaignGrossProfit = 0,
      totalSent = 0,
      totalReceived = 0;

  int totalClients = 0,
      totalCampaigns = 0,
      pastCampaigns = 0,
      ongoingCampaign = 0;

  int? sortColumnIndex;


  void downloadFile(String url) {
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }

  List<DataRow> _createRows(QuerySnapshot snapshot) {
    List<DataRow> newList =
    snapshot.docs.map((DocumentSnapshot documentSnapshot) {
      return DataRow(cells: [
        DataCell(
          Text(documentSnapshot.data().toString().contains('billNo') ? documentSnapshot.get('billNo') : ""),
        ),

        DataCell(
          Text(documentSnapshot.data().toString().contains('campaignName') ? documentSnapshot.get('campaignName') : ""),
        ),

        DataCell(
          SizedBox(
            width: 200,
            child: InkWell(
              onTap: (){
                launchUrl(Uri.parse(documentSnapshot.get('campaignLink')));
              },
              child: Text(documentSnapshot.data().toString().contains('campaignLink') ? documentSnapshot.get('campaignLink') : "",
                overflow: TextOverflow.clip,
                softWrap: true,
              ),
            ),
          ),
        ),

        DataCell(
          Text(documentSnapshot.data().toString().contains('description') ? documentSnapshot.get('description') : ""),
        ),

        DataCell(Text(documentSnapshot.data().toString().contains('client') ? documentSnapshot.get('client') : "")),

        DataCell(Text(documentSnapshot.data().toString().contains('projectGoal') ? documentSnapshot.get('projectGoal').toStringAsFixed(0) : "")),

        DataCell(
          Text(documentSnapshot.data().toString().contains('sales') ? documentSnapshot.get('sales').toStringAsFixed(0) : ""),
          showEditIcon: true,
          onTap: () async {
            final updatedSales = await showTextDialog2(
              context,
              title: 'Change sales',
              value: documentSnapshot.get('sales').toString(),
            );

            if(updatedSales != null){
              double sales = double.parse(updatedSales);
              double ASF = sales * 0.1;
              double subTotal = sales + ASF;
              double amountVat = subTotal * 0.05;
              double AIT = subTotal * (documentSnapshot.get('AITPercentage') / 100);
              double totalExpense = documentSnapshot.get('expense') + amountVat + AIT;
              double grossProfit = documentSnapshot.get('projectGoal') - totalExpense;

              documentSnapshot.reference.update({'sales': sales});
              documentSnapshot.reference.update({'ASF': ASF});
              documentSnapshot.reference.update({'subTotal': subTotal});
              documentSnapshot.reference.update({'amountVat': amountVat});
              documentSnapshot.reference.update({'AIT': AIT});
              documentSnapshot.reference.update({'totalExpense' : totalExpense});
              documentSnapshot.reference.update({'grossProfit' : grossProfit});
            }
          },
        ),

        DataCell(Text(documentSnapshot.data().toString().contains('ASF') ? documentSnapshot.get('ASF').toStringAsFixed(0) : ""),
        ),

        DataCell(Text(documentSnapshot.data().toString().contains('subTotal') ? documentSnapshot.get('subTotal').toStringAsFixed(0) : ""),
        ),

        DataCell(Text(documentSnapshot.data().toString().contains('amountVat') ? documentSnapshot.get('amountVat').toStringAsFixed(0) : ""),
        ),

        DataCell(Text(documentSnapshot.data().toString().contains('AIT')
            ? documentSnapshot.get('AIT').toStringAsFixed(0)
            : ''),
          showEditIcon: true,
          onTap: () async {
            final updatedAIT = await showTextDialog2(
              context,
              title: 'Change AIT',
              value: documentSnapshot.get('AIT').toString(),
            );

            if(updatedAIT != null){
              double AIT = double.parse(updatedAIT);
              double totalExpense = documentSnapshot.get('expense') + documentSnapshot.get('amountVat') + AIT;
              double grossProfit = documentSnapshot.get('projectGoal') - totalExpense;

              documentSnapshot.reference.update({'AIT': AIT});
              documentSnapshot.reference.update({'totalExpense' : totalExpense});
              documentSnapshot.reference.update({'grossProfit' : grossProfit});
            }

          },
        ),

        DataCell(Text(documentSnapshot.data().toString().contains('expense')
            ? documentSnapshot.get('expense').toStringAsFixed(0)
            : ''),

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

                documentSnapshot.reference.update({'expense': expense});
                documentSnapshot.reference.update({'totalExpense' : totalExpense});
                documentSnapshot.reference.update({'grossProfit' : grossProfit});
              }

            }

        ),

        DataCell(Text(documentSnapshot.data().toString().contains('totalExpense')
            ? documentSnapshot.get('totalExpense').toStringAsFixed(0)
            : ''),
        ),

        DataCell(Text(documentSnapshot.data().toString().contains('grossProfit')
            ? documentSnapshot.get('grossProfit').toStringAsFixed(0)
            : ''),
        ),

        DataCell(Text(documentSnapshot.data().toString().contains('billSent')
            ? documentSnapshot.get('billSent').toStringAsFixed(0)
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
            }

          },
        ),

        DataCell(Text(documentSnapshot.data().toString().contains('billReceived')
            ? documentSnapshot.get('billReceived').toStringAsFixed(0)
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
            }

          },
        ),

        DataCell(Text(
            documentSnapshot.data().toString().contains('startingDate')
                ? documentSnapshot.get('startingDate')
                : '')),

        DataCell(Text(documentSnapshot.data().toString().contains('endingDate')
            ? documentSnapshot.get('endingDate')
            : '')),

        DataCell(
          SizedBox(
            width: 300,
            child: TextButton(
              onPressed: () {
                downloadFile(documentSnapshot.get('pdfLink'));
              },
              child: Text(
                documentSnapshot.data().toString().contains('pdfLink')
                    ? documentSnapshot.get('pdfLink')
                    : '',
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ),
        ),

        DataCell(
          Text(documentSnapshot.data().toString().contains('status')
              ? documentSnapshot.get('status')
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
            }

          },
        ),

        DataCell(
          Text(documentSnapshot.data().toString().contains('lastEditedBy')
              ? documentSnapshot.get('lastEditedBy')
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
          ) ??
              false;
        })
      ]);
    }).toList();

    return newList;
  }

  String idGenerator() {
    final now = DateTime.now();
    return now.microsecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Row(children: [
        Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20.0,
                      ),

                      // Campaign Containers
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('campaignData')
                            .where('client', isEqualTo: selectedClient)
                            .where('month', isEqualTo: selectedMonth)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error = ${snapshot.error}');
                          }

                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          } else {
                            totalEarning = 0;
                            totalDue = 0;
                            grossProfit = 0;
                            ongoingCampaign = 0;
                            pastCampaigns = 0;
                            totalCampaigns = 0;
                            for (var result in snapshot.data!.docs) {
                              totalEarning += (result.data()['projectGoal']);
                              totalDue += ((result.data()['billSent']) - (result.data()['billReceived']));
                              grossProfit += (result.data()['grossProfit']);
                              totalCampaigns++;

                              if (result.data()['status'] == "Ongoing") {
                                ongoingCampaign++;
                              }
                              else {
                                pastCampaigns++;
                              }
                            }

                            return StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('clientList').snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error = ${snapshot.error}');
                                }

                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }

                                else{
                                  totalClients = 0;
                                  for (var result in snapshot.data!.docs) {
                                    totalClients++;
                                  }

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: const [
                                                  Icon(
                                                    Icons.article,
                                                    size: 26.0,
                                                  ),
                                                  SizedBox(
                                                    width: 15.0,
                                                  ),
                                                  Text(
                                                    "Total Campaigns",
                                                    style: TextStyle(
                                                      fontSize: 26.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              Text(
                                                totalCampaigns.toString() + " campaigns",
                                                style: const TextStyle(
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: const [
                                                  Icon(
                                                    Icons.comment,
                                                    size: 26.0,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(
                                                    width: 15.0,
                                                  ),
                                                  Text(
                                                    "Ongoing Campaigns",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 26.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              Text(
                                                "$ongoingCampaign campaigns",
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: const [
                                                  Icon(
                                                    Icons.people,
                                                    size: 26.0,
                                                    color: Colors.amber,
                                                  ),
                                                  SizedBox(
                                                    width: 15.0,
                                                  ),
                                                  Text(
                                                    "Total Clients",
                                                    style: TextStyle(
                                                      fontSize: 26.0,
                                                      color: Colors.amber,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              Text(
                                                totalClients.toString() + " Clients",
                                                style: const TextStyle(
                                                  fontSize: 36,
                                                  color: Colors.amber,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: const [
                                                  Icon(
                                                    Icons.monetization_on_outlined,
                                                    size: 26.0,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(
                                                    width: 15.0,
                                                  ),
                                                  Text(
                                                    "Total Earning (৳)",
                                                    style: TextStyle(
                                                      fontSize: 26.0,
                                                      color: Colors.green,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              Text(
                                                '৳${totalEarning.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 36,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: const [
                                                  Icon(
                                                    Icons.monetization_on_outlined,
                                                    size: 26.0,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(
                                                    width: 15.0,
                                                  ),
                                                  Text(
                                                    "Total Due (৳)",
                                                    style: TextStyle(
                                                      fontSize: 26.0,
                                                      color: Colors.red,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              Text(
                                                '৳${totalDue.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 36,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: const [
                                                  Icon(
                                                    Icons.monetization_on_outlined,
                                                    size: 26.0,
                                                    color: Colors.purple,
                                                  ),
                                                  SizedBox(
                                                    width: 15.0,
                                                  ),
                                                  Text(
                                                    "Gross profit (৳)",
                                                    style: TextStyle(
                                                      fontSize: 26.0,
                                                      color: Colors.purple,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              Text(
                                                '৳${grossProfit.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 36,
                                                  color: Colors.purple,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                              },
                            );
                          }
                        },
                      ),

                      SizedBox(
                        height: height * 0.05,
                      ),

                      // Filter Options
                      Column(
                        children: [
                          // Campaign Status
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('campaignData')
                                .where('client', isEqualTo: selectedClient)
                                .where('month', isEqualTo: selectedMonth)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container(
                                    alignment: FractionalOffset.center,
                                    child: const CircularProgressIndicator());
                              }

                              else {
                                ongoingCampaign = 0;
                                pastCampaignRevenue = 0;
                                ongoingCampaignRevenue = 0;
                                pastCampaignGrossProfit = 0;
                                for (var result in snapshot.data!.docs) {
                                  if (result.data()['status'] == "Ongoing") {
                                    ongoingCampaign++;
                                    ongoingCampaignRevenue += (result.data()['projectGoal']);
                                  }

                                  else if(result.data()['status'] == "Completed"){
                                    pastCampaignRevenue += (result.data()['projectGoal']);
                                    pastCampaignGrossProfit += (result.data()['grossProfit']);
                                  }

                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Campaign",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 35.0,
                                      ),
                                    ),

                                    const SizedBox(height: 10,),

                                    // Select
                                    SizedBox(
                                      width: width,
                                      child: DropdownButtonFormField(
                                        items: statusList.map((status) {
                                          return DropdownMenuItem(
                                            value: status,
                                            child: Text(status),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          isDense: true,
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                              BorderRadius.circular(10)),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1.5,
                                                color: Colors.grey.shade300),
                                          ),
                                        ),
                                        iconSize: 26,
                                        dropdownColor: Colors.white,
                                        isExpanded: true,
                                        value: selectedStatus,
                                        hint: const Text(
                                          "Select campaign status",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedStatus = newValue;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null) {
                                            return "Select status";
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 20.0,
                                    ),

                                    (selectedStatus == "Ongoing") ?
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Number of Campaigns: $ongoingCampaign",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        Text(
                                          "Earning: ৳$ongoingCampaignRevenue",
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ) :

                                    (selectedStatus == "Completed") ?
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Number of Campaigns: $pastCampaigns",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),

                                        Text(
                                          "Earning: ৳$pastCampaignRevenue",
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w400),
                                        ),

                                        const SizedBox(
                                          height: 20.0,
                                        ),

                                        Text(
                                          "Gross Profit: ৳$pastCampaignGrossProfit",
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ) :
                                    Container()
                                  ],
                                );
                              }
                            },
                          ),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('clientList')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error = ${snapshot.error}');
                              }
                              if (!snapshot.hasData) {
                                // if snapshot has no data this is going to run
                                return Container(
                                    alignment: FractionalOffset.center,
                                    child: const CircularProgressIndicator());
                              }

                              else {
                                //selectedClient = snapshot.data!.docs[0].get('name');
                                totalClients = 0;
                                for (var result in snapshot.data!.docs) {
                                  totalClients++;
                                }
                                return SizedBox(
                                  width: width,
                                  height: 50,
                                  child: DropdownButtonFormField(
                                    items: snapshot.data!.docs.map((value) {
                                      return DropdownMenuItem(
                                        value: value.get('name'),
                                        child: Text('${value.get('name')}'),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1.5,
                                              color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1.5,
                                            color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    iconSize: 26,
                                    dropdownColor: Colors.white,
                                    isExpanded: true,
                                    value: selectedClient,
                                    hint: const Text(
                                      "Select a client",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedClient = newValue;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return "Select a client";
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                );
                              }
                            },
                          ), // Select Client
                          SizedBox(height: height * 0.02,),
                          SizedBox(
                            width: width,
                            height: 50,
                            child: DropdownButtonFormField(
                              items: monthList.map((month) {
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(
                                    month,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1.5,
                                        color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.5,
                                      color: Colors.grey.shade300),
                                ),
                              ),
                              iconSize: 26,
                              dropdownColor: Colors.white,
                              isExpanded: true,
                              value: selectedMonth,
                              hint: const Text(
                                "Select a month",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black,
                                ),
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedMonth = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return "Select a month";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ), // Select Month
                          SizedBox(height: height * 0.02,),
                          SizedBox(
                            width: width,
                            child: TextFormField(
                              controller: searchTextEditingController,
                              onChanged: (textTyped) {
                                setState(() {
                                  search = textTyped;
                                });
                              },

                              decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.search,color: Colors.black,),
                                  hintText: "Search by Bill No",
                                  suffixStyle: const TextStyle(color: Colors.black),
                                  fillColor: Colors.white,
                                  filled: true,
                                  suffixIcon: searchTextEditingController.text.isEmpty ?
                                  Container(width: 0) : IconButton(
                                    icon: const Icon(Icons.close,color: Colors.black,),
                                    onPressed: () {
                                      searchTextEditingController.clear();
                                      search = null;
                                      setState(() {
                                      });
                                    },
                                  ),
                                  enabledBorder:OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1.5,
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10)
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1.5,
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  contentPadding: const EdgeInsets.all(15)),

                            ),
                          ), // Search bar
                        ],
                      ),

                      SizedBox(
                        height: height * 0.02,
                      ),

                      // Add Campaign Data
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (currentUserInfo?.userType == "Super Admin") ?
                          Row(
                            children: [
                              SizedBox(
                                width: width * 0.2,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => DataInputForm(totalCampaigns: totalCampaigns,)));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: (Colors.blue),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10))),
                                  child: Text(
                                    "Add Campaign Data",
                                    style: GoogleFonts.raleway(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.01,
                              ),
                              SizedBox(
                                width: width * 0.15,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        builder: (context){
                                          return AddClientDialog(title: "Add Client");
                                        }
                                    );

                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: (Colors.blue),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10))),
                                  child: Text(
                                    "Add Client",
                                    style: GoogleFonts.raleway(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.01,
                              ),
                              SizedBox(
                                width: width * 0.15,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    selectedClient = null;
                                    final status = await showTextDialog(
                                      context,
                                      title: 'Delete client',
                                      value: '',
                                    );

                                    if (status != null) {
                                      var snackBar = const SnackBar(
                                          content: Text('Client deleted'));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      var snapshot = await FirebaseFirestore.instance
                                          .collection('clientList')
                                          .where('name', isEqualTo: status)
                                          .get();
                                      await snapshot.docs.first.reference.delete();
                                    }
                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: (Colors.blue),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10))),
                                  child: Text(
                                    "Delete Client",
                                    style: GoogleFonts.raleway(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.01,
                              ),
                              SizedBox(
                                width: width * 0.15,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    selectedClient = null;
                                    showDialog(
                                        context: context,
                                        builder: (context){
                                          return AddClientDialog(title: "Change AIT");
                                        }
                                    );

                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: (Colors.blue),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10))),
                                  child: Text(
                                    "Change AIT",
                                    style: GoogleFonts.raleway(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ) :

                          Row(
                            children: [
                              SizedBox(
                                width: width * 0.2,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => DataInputForm(totalCampaigns: totalCampaigns,)));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: (Colors.blue),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10))),
                                  child: Text(
                                    "Add Campaign Data",
                                    style: GoogleFonts.raleway(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.01,
                              ),
                              SizedBox(
                                width: width * 0.15,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    selectedClient = null;
                                    showDialog(
                                        context: context,
                                        builder: (context){
                                          return AddClientDialog(title: "Change AIT");
                                        }
                                    );

                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: (Colors.blue),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10))),
                                  child: Text(
                                    "Change AIT",
                                    style: GoogleFonts.raleway(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          InkWell(
                            onTap: (){
                              search = null;
                              selectedClient = null;
                              selectedMonth = null;
                              selectedStatus = null;
                              searchTextEditingController.clear();
                              setState(() {

                              });
                            },
                            child: Column(
                              children: const [
                                Text('Clear Filter',style: TextStyle(color: Colors.blue,fontSize: 17,fontWeight: FontWeight.bold),),
                              ],
                            ),
                          )
                        ],
                      ),

                      SizedBox(
                        height: height * 0.03,
                      ),

                      //Now let's add the Table
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StreamBuilder(
                            stream: FirebaseFirestore.instance.collection('campaignData')
                                .where('client', isEqualTo: selectedClient)
                                .where('month', isEqualTo: selectedMonth)
                                .where('billNo', isEqualTo: search)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error = ${snapshot.error}');
                              }

                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              else{
                                return SizedBox(
                                  height: height,
                                  child: InteractiveViewer(
                                      constrained : false,
                                      scaleEnabled: false,
                                      child: DataTable(
                                        sortColumnIndex: sortColumnIndex,
                                        headingRowColor: MaterialStateProperty.resolveWith(
                                                (states) => Colors.grey.shade200),
                                        columns: const [
                                          DataColumn(label: Text("Bill No")),
                                          DataColumn(label: Text("Campaign Name")),
                                          DataColumn(label: Text("Post Link")),
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
                                          DataColumn(label: Text("Starting Date")),
                                          DataColumn(label: Text("Ending Date")),
                                          DataColumn(label: Text("File")),
                                          DataColumn(label: Text("Status")),
                                          DataColumn(label: Text("Last Edited By")),
                                          DataColumn(label: Text("")),
                                        ],
                                        rows: _createRows(snapshot.data!),
                                      )
                                  ),
                                );
                              }

                            },
                          ),
                        ],
                      ),

                      SizedBox(
                        height: height * 0.05,
                      ),
                    ]),
              ),
            )),
      ]),
    );
  }
}

