import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenovent_portal/dashboard_screens/profile_screen_edit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import '../app_colors.dart';
import '../authentication_screens/login_screen.dart';
import '../dashboard_screens/profile_screen.dart';
import '../form/sub_admin_form.dart';
import '../global.dart';
import '../model/campaign_model.dart';
import '../widget/dialog_widget.dart';
import '../widget/dialog_widget2.dart';

class LargeScreenWidget extends StatefulWidget {
  const LargeScreenWidget({Key? key}) : super(key: key);

  @override
  State<LargeScreenWidget> createState() => _LargeScreenWidgetState();
}

class _LargeScreenWidgetState extends State<LargeScreenWidget> {
  //setting the expansion function for the navigation rail
  TextEditingController clientAddController = TextEditingController();
  bool isExpanded = false;
  int selectedIndex = 0;
  var selectedClient;
  String? selectedStatus;
  String? selectedFilter;
  List<CampaignDataModel> campaignList = [];
  List<String> filterByList = ["Date", "Revenue"];
  List<String> statusList = ["Ongoing", "Completed"];
  int totalEarning = 0,
      totalClients = 0,
      totalCampaigns = 0,
      ongoingCampaign = 0,
      ongoingCampaignRevenue = 0,
      pastCampaignRevenue = 0,
      pastCampaigns = 0;

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
          Text(documentSnapshot.data().toString().contains('campaignName')
              ? documentSnapshot.get('campaignName')
              : ''),
        ),
        DataCell(
          SizedBox(
            width: 300,
            child: InkWell(
              onTap: (){
                launchUrl(Uri.parse(documentSnapshot.get('campaignLink')));
              },
              child: Text(
                documentSnapshot.data().toString().contains('campaignLink')
                    ? documentSnapshot.get('campaignLink')
                    : '',
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ),
        ),
        DataCell(Text(documentSnapshot.data().toString().contains('client')
            ? documentSnapshot.get('client')
            : '')),
        DataCell(Text(documentSnapshot.data().toString().contains('budget')
            ? documentSnapshot.get('budget')
            : '')),
        DataCell(Text(documentSnapshot.data().toString().contains('totalSpent')
            ? documentSnapshot.get('totalSpent')
            : ''),
          showEditIcon: true,
          onTap: () async {
            final total_spent = await showTextDialog2(
              context,
              title: 'Change total spent',
              value: documentSnapshot.get('totalSpent'),
            );
            if(total_spent!=null){
              documentSnapshot.reference.update({'totalSpent': total_spent});
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
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error = ${snapshot.error}');
                          }

                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          } else {
                            totalEarning = 0;
                            ongoingCampaign = 0;
                            pastCampaigns = 0;
                            totalCampaigns = 0;
                            for (var result in snapshot.data!.docs) {
                              totalEarning += int.parse(result.data()['budget']);
                              totalCampaigns++;
                              if (result.data()['status'] == "Ongoing") {
                                ongoingCampaign++;
                              }
                              else {
                                pastCampaigns++;
                              }
                            }

                            return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('clientList')
                                  .snapshots(),

                              builder: (context, snapshot){
                                if (snapshot.hasError) {
                                  return Text('Error = ${snapshot.error}');
                                }

                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                } else {
                                  totalClients = 0;
                                  for (var result in snapshot.data!.docs) {
                                    totalClients++;
                                  }

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Flexible(
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
                                                      size: 26.0,
                                                    ),
                                                    SizedBox(
                                                      width: 15.0,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        "Total Campaigns",
                                                        style: TextStyle(
                                                          fontSize: 26.0,
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
                                      ),
                                      Flexible(
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
                                                      size: 26.0,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(
                                                      width: 15.0,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        "Past Campaigns",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 26.0,
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
                                                  pastCampaigns.toString() + " campaigns",
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
                                      ),
                                      Flexible(
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
                                      ),
                                      Flexible(
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
                                                      size: 26.0,
                                                      color: Colors.green,
                                                    ),
                                                    SizedBox(
                                                      width: 15.0,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'Total Sales Amount (\$)',
                                                        style: TextStyle(
                                                          fontSize: 26.0,
                                                          color: Colors.green,
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
                                                  '\$'+ totalEarning.toString(),
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
                                      ),
                                    ],
                                  );;
                                }
                              },
                            );
                          }
                        },
                      ),

                      SizedBox(
                        height: height * 0.05,
                      ),

                      // Campaign & Clients
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Ongoing campaign
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('campaignData')
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
                                for (var result in snapshot.data!.docs) {
                                  if (result.data()['status'] == "Ongoing") {
                                    ongoingCampaign++;
                                    ongoingCampaignRevenue += int.parse(result.data()['budget']);
                                  }

                                  else if(result.data()['status'] == "Completed"){
                                    pastCampaignRevenue += int.parse(result.data()['budget']);
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
                                            prefixIcon: Icon(Icons.campaign,color: Colors.black,),
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
                                      ],
                                    ) :
                                    Container()
                                  ],
                                );
                              }
                            },
                          ),
                          SizedBox(
                            width: width * 0.3,
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
                          ),
                        ],
                      ),

                      SizedBox(
                        height: height * 0.03,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            SizedBox(
                              width: width * 0.11,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const DataInputForm()));
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
                                  final status = await showTextDialog2(
                                    context,
                                    title: 'Add client',
                                    value: '',
                                  );
                                  if (status != null) {
                                    Map<String, dynamic> data = {'name': status};
                                    FirebaseFirestore.instance
                                        .collection('clientList')
                                        .doc(idGenerator())
                                        .set(data);
                                  }
                                  setState(() {
                                  });
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
                          ]),

                          // Filter By
                          /*Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            width: width / 3,
                            height: 55,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    width: 1.5, color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                iconSize: 26,
                                dropdownColor: Colors.white,
                                isExpanded: true,
                                hint: const Text(
                                  "Filter by",
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.black,
                                  ),
                                ),
                                value: selectedFilter,
                                onChanged: (newValue) async {
                                  setState(() {
                                    selectedFilter = newValue;
                                  });
                                },
                                items: filterByList.map((filter) {
                                  return DropdownMenuItem(
                                    value: filter,
                                    child: Text(
                                      filter,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          )*/
                        ],
                      ),

                      SizedBox(
                        height: height * 0.02,
                      ),

                      //Now let's add the Table
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StreamBuilder(
                            stream: FirebaseFirestore.instance.collection('campaignData').where('client', isEqualTo: selectedClient).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error = ${snapshot.error}');
                              }

                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              return SingleChildScrollView(
                                  child: FittedBox(
                                    child: DataTable(
                                      sortColumnIndex: sortColumnIndex,
                                      headingRowColor: MaterialStateProperty.resolveWith(
                                              (states) => Colors.grey.shade200),
                                      columns: const [
                                        DataColumn(label: Text("Campaign Name")),
                                        DataColumn(label: Text("Post Link")),
                                        DataColumn(label: Text("Client Name")),
                                        DataColumn(label: Text("Budget (\$)")),
                                        DataColumn(label: Text("Total spent (\$)")),
                                        DataColumn(label: Text("Starting Date")),
                                        DataColumn(label: Text("Ending Date")),
                                        DataColumn(label: Text("PDF File")),
                                        DataColumn(label: Text("Status")),
                                        DataColumn(label: Text("")),
                                      ],
                                      rows: _createRows(snapshot.data!),
                                    ),
                                  )
                              );
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