import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenovent_portal/dashboard_screens/profile_screen_edit.dart';
import 'dart:html' as html;
import '../app_colors.dart';
import '../assistant_method/assistant_method.dart';
import '../authentication_screens/login_screen.dart';
import '../form/sub_admin_form.dart';
import '../global.dart';
import '../model/data_model.dart';
import '../model/table_data.dart';
import '../widget/dialog_widget.dart';
import '../widget/dialog_widget2.dart';
import '../widget/dialog_widget_add_client.dart';

class MediumSmallScreenWidget extends StatefulWidget {
  const MediumSmallScreenWidget({Key? key}) : super(key: key);

  @override
  State<MediumSmallScreenWidget> createState() => _MediumSmallScreenWidgetState();
}

class _MediumSmallScreenWidgetState extends State<MediumSmallScreenWidget> {
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



  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Row(children: [
        NavigationRail(
          extended: isExpanded,
          selectedIndex: selectedIndex,
          backgroundColor: AppColors.mainBlueColor,
          selectedLabelTextStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          unselectedLabelTextStyle: TextStyle(color: Colors.grey.shade300),
          selectedIconTheme: const IconThemeData(color: Colors.white),
          unselectedIconTheme:
          const IconThemeData(color: Colors.white, opacity: 0.5),
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
              if(index == 1){
                var snackBar = const SnackBar(content: Text('Work in progress!'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              else if (index == 2){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreenEdit()));
              }
              else if (index == 3) {
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
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const LoginScreen()));
                        },
                        //return true when click on "Yes"
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                ) ??
                    false;
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
        Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Size:$width"),

                      // Icon button and Circle Avatar
                      IconButton(
                        onPressed: () {
                          //let's trigger the navigation expansion
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        icon: const Icon(Icons.menu),
                      ),

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
                              builder: (context, snapshot){
                                if (snapshot.hasError) {
                                  return Text('Error = ${snapshot.error}');
                                }

                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }

                                else {
                                  totalClients = 0;
                                  for (var result in snapshot.data!.docs) {
                                    totalClients++;
                                  }

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(18.0),
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
                                                    Expanded(
                                                      child: Text(
                                                        "Total Campaigns",
                                                        style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Text(
                                                  "$totalCampaigns campaigns",
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(18.0),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.comment,
                                                      size: 20.0,
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
                                                          fontSize: 14.0,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Text(
                                                  "$ongoingCampaign campaigns",
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(18.0),
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
                                                        fontSize: 15.0,
                                                        color: Colors.amber,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Text(
                                                  "$totalClients Clients",
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.amber,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(18.0),
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
                                                    Expanded(
                                                      child: Text(
                                                        'Total Earning (৳)',
                                                        style: TextStyle(
                                                          fontSize: 15.0,
                                                          color: Colors.green,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Text(
                                                  '৳${totalEarning.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(18.0),
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
                                                    Expanded(
                                                      child: Text(
                                                        'Total Due (৳)',
                                                        style: TextStyle(
                                                          fontSize: 15.0,
                                                          color: Colors.red,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Text(
                                                  '৳${totalDue.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(18.0),
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
                                                    Expanded(
                                                      child: Text(
                                                        'Gross profit (৳)',
                                                        style: TextStyle(
                                                          fontSize: 15.0,
                                                          color: Colors.purple,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Text(
                                                  '৳${grossProfit.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.purple,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
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

                                // Select Status
                                SizedBox(
                                  width: width * 0.2,
                                  child: DropdownButtonHideUnderline(
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
                                        prefixIcon: const Icon(Icons.campaign,color: Colors.black,),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1.5,
                                                color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(15)
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

                      SizedBox(
                        height: height * 0.02,
                      ),

                      // Filter Options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width * 0.2,
                            child: StreamBuilder(
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
                                        prefixIcon: Icon(Icons.people_alt_rounded,color: Colors.black,),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1.5,
                                                color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(15)
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
                            ),
                          ),   // Select Month
                          SizedBox(
                            width: width * 0.2,
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
                                prefixIcon: const Icon(Icons.calendar_month_outlined,color: Colors.black,),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1.5,
                                        color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(15)
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
                          ),  // Select Client
                          SizedBox(
                            width: width * 0.2,
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
                        height: height * 0.03,
                      ),

                      // Add Campaign Data
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: width * 0.13,
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
                                width: width * 0.11,
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
                              SizedBox(
                                width: width * 0.01,
                              ),
                              SizedBox(
                                width: width * 0.11,
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
                                width: width * 0.11,
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
                        height: height * 0.02,
                      ),

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
            ))
      ]),
    );
  }
}
