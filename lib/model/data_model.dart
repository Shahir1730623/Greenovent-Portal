import 'package:cloud_firestore/cloud_firestore.dart';

class CampaignData {
  final String id;
  final String billNo;
  final String campaignName;
  final String campaignLink;
  final String description;
  final String client;
  final double projectGoal;
  final double sales;
  final double asfPercentage;
  final double asf;
  final double subTotal;
  final double amountVat;
  final double ait;
  final double expense;
  final double totalExpense;
  final double grossProfit;
  final double billSent;
  final double billReceived;
  final String billStatus;
  final String startingDate;
  final String endingDate;
  final String pdfLink;
  final String status;
  final String lastEditedBy;

  // Add more fields as needed
  CampaignData({
    required this.id,
    required this.billNo,
    required this.campaignName,
    required this.campaignLink,
    required this.description,
    required this.client,
    required this.projectGoal,
    required this.sales,
    required this.asfPercentage,
    required this.asf,
    required this.subTotal,
    required this.amountVat,
    required this.ait,
    required this.expense,
    required this.totalExpense,
    required this.grossProfit,
    required this.billSent,
    required this.billReceived,
    required this.billStatus,
    required this.startingDate,
    required this.endingDate,
    required this.pdfLink,
    required this.status,
    required this.lastEditedBy
    // Add more fields as needed
  });

  // Factory method to create a CampaignData instance from a Firestore DocumentSnapshot
  factory CampaignData.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CampaignData(
      id: doc.id, // ID of the document
      billNo: data['billNo'],
      campaignName: data['campaignName'],
      campaignLink: data['campaignLink'],
      description: data['description'],
      client: data['client'],
      projectGoal: data['projectGoal'],
      sales: data['sales'],
      asfPercentage: data['ASF'],
      asf: data['ASF'] ?? "",
      subTotal: data['subTotal'],
      amountVat: data['amountVat'],
      ait: data['AIT'],
      expense: data['expense'],
      totalExpense: data['totalExpense'],
      grossProfit: data['grossProfit'],
      billSent: data['billSent'] ,
      billReceived: data['billReceived'],
      billStatus: data['billStatus'],
      startingDate: data['startingDate'],
      endingDate: data['endingDate'] ?? "",
      pdfLink: data['pdfLink'] ?? "",
      status: data['status'],
      lastEditedBy: data['lastEditedBy'],
      // Add more fields as needed
    );
  }
}
