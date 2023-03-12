import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenovent_portal/model/campaign_model.dart';
import 'package:greenovent_portal/super_admin_screens/medium_screen.dart';
import 'package:greenovent_portal/super_admin_screens/small_screen.dart';
import 'package:greenovent_portal/widget/dialog_widget.dart';
import 'dart:html' as html;
import '../form/sub_admin_form.dart';
import '../super_admin_screens/large_screen.dart';
import '../widget/dialog_widget2.dart';
import '../widget/responsive_layout.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({Key? key}) : super(key: key);

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
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
                child: Text(
                  documentSnapshot.data().toString().contains('campaignLink')
                      ? documentSnapshot.get('campaignLink')
                      : '',
                  overflow: TextOverflow.visible,
                  softWrap: true,
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (ResponsiveWidget.isSmallScreen(context)) ?
      const SmallScreenWidget() :

      (ResponsiveWidget.isMediumScreen(context)) ?
      const MediumScreenWidget():

      const LargeScreenWidget()
    );
  }
}
