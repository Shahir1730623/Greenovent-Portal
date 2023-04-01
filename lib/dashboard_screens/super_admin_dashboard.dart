import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenovent_portal/super_admin_screens/medium_large_screen.dart';
import 'package:greenovent_portal/super_admin_screens/medium_screen.dart';
import 'package:greenovent_portal/super_admin_screens/small_screen.dart';
import '../super_admin_screens/large_screen.dart';
import '../widget/responsive_layout.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({Key? key}) : super(key: key);

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
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

      (ResponsiveWidget.isMediumLargeScreen(context)) ?
      const MediumLargeScreenWidget() :

      const LargeScreenWidget()
    );
  }
}
