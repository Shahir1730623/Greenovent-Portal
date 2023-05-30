import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget largeScreen;
  final Widget? mediumLargeScreen;
  final Widget? mediumSmallScreen;
  final Widget? mediumScreen;
  final Widget? smallScreen;

  const ResponsiveWidget({
    Key? key,
    required this.largeScreen,
    this.mediumLargeScreen,
    this.mediumSmallScreen,
    this.mediumScreen,
    this.smallScreen,
  }) : super(key: key);

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1300;
  }

  static bool isMediumSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1300 &&
        MediaQuery.of(context).size.width < 1450;
  }


  static bool isMediumLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1450 && MediaQuery.of(context).size.width <= 1780;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1780;
  }



  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return largeScreen;
        }

        else if (constraints.maxWidth <= 1780 && constraints.maxWidth >= 1450) {
          return mediumLargeScreen ?? largeScreen;
        }

        else if (constraints.maxWidth < 1450 && constraints.maxWidth >= 1300) {
          return mediumSmallScreen ?? largeScreen;
        }

        else if (constraints.maxWidth <= 1300 &&
            constraints.maxWidth >= 600) {
          return mediumScreen ?? largeScreen;
        }

        else {
          return smallScreen ?? largeScreen;
        }
      },
    );
  }
}