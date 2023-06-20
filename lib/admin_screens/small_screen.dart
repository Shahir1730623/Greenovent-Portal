import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenovent_portal/assistant_method/assistant_method.dart';
import 'dart:html' as html;
import '../form/sub_admin_form.dart';
import '../model/data_model.dart';
import '../model/table_data.dart';
import '../widget/dialog_widget.dart';
import '../widget/dialog_widget_add_client.dart';

class SmallScreenWidget extends StatefulWidget {
  const SmallScreenWidget({Key? key}) : super(key: key);

  @override
  State<SmallScreenWidget> createState() => _SmallScreenWidgetState();
}

class _SmallScreenWidgetState extends State<SmallScreenWidget> {
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
                        stream: FirebaseFirestore.instance.collection('campaignData')
                            .where('client', isEqualTo: selectedClient)
                            .where('month', isEqualTo: selectedMonth)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error = ${snapshot.error}');
                          }

                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          else {
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
                                                    size: 22.0,
                                                  ),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    "Total campaigns",
                                                    style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              Text(
                                                "$totalCampaigns campaigns",
                                                style: const TextStyle(
                                                  fontSize: 30,
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
                                                    size: 22.0,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "Ongoing Campaigns",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 20.0,
                                                        fontWeight: FontWeight.bold,
                                                      ),
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
                                                  fontSize: 30,
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
                                                    size: 22.0,
                                                    color: Colors.amber,
                                                  ),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    "Total Clients",
                                                    style: TextStyle(
                                                      fontSize: 20.0,
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
                                                "$totalClients Clients",
                                                style: const TextStyle(
                                                  fontSize: 30,
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
                                                    size: 22.0,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    "Total Earning (৳)",
                                                    style: TextStyle(
                                                      fontSize: 20.0,
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
                                                "৳${totalEarning.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 30,
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
                                                    size: 22.0,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    "Total Due (৳)",
                                                    style: TextStyle(
                                                      fontSize: 20.0,
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
                                                "৳${totalDue.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 30,
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
                                                    size: 22.0,
                                                    color: Colors.purple,
                                                  ),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    "Gross profit (৳)",
                                                    style: TextStyle(
                                                      fontSize: 20.0,
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
                                                "৳${grossProfit.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 30,
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
                                        fontSize: 25.0,
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
                                        fontSize: 13.0,
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
                                  fontSize: 13.0,
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
                                  search = textTyped.toUpperCase();
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width * 0.32,
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
                                "Add Data",
                                style: GoogleFonts.raleway(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width * 0.01,
                          ),
                          SizedBox(
                            width: width * 0.32,
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
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width * 0.32,
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
                            width: width * 0.32 ,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () async {
                                selectedClient = null;
                                showDialog(
                                    context: context,
                                    builder: (context){
                                      return AddClientDialog(title: "Change Params");
                                    }
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: (Colors.blue),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: Text(
                                "Change Params",
                                style: GoogleFonts.raleway(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          )

                        ],
                      ),

                      const SizedBox(height: 10,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                            child: const Text('Clear Filter',style: TextStyle(color: Colors.blue,fontSize: 15,fontWeight: FontWeight.bold),),
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
                                .orderBy('billNo')
                                .where('billNo', isGreaterThanOrEqualTo: search ?? '')
                                .where('billNo', isLessThan: (search ?? '') + 'z')  // assuming 'z' as the last possible character
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                debugPrint('Error = ${snapshot.error}');
                                return Text('Error = ${snapshot.error}');
                              }

                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              else{
                                var myData = snapshot.data?.docs.map((e) => CampaignData.fromDocument(e)).toList();
                                return PaginatedDataTable(
                                    rowsPerPage: 10,
                                    columnSpacing: 30,
                                    sortColumnIndex: sortColumnIndex,
                                    columns: AssistantMethods.createColumns(),
                                    source: MyDataSource(myData!,context)
                                  // rows: AssistantMethods.createRows(snapshot.data!,context),
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
