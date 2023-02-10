// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/router/router_utils.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return settingsMenu(context);
  }
}

Widget settingsMenu(BuildContext context) {
  return Scaffold(
      appBar: commonAppBar(backroute: Pages.home.toPath, context: context),
      backgroundColor: CommonColors.commonWhiteColor,
      body: ListView(
        padding: commonListViewTopPadding,
        children: [
          commonTile(
              icon: FontAwesomeIcons.computer,
              title: 'Server Details',
              onTap: () {
                context.goNamed(SettingsSubRoute.serverDetails.toName);
              }),
          commonTile(
              icon: FontAwesomeIcons.folderClosed,
              title: 'Folder Configurations',
              onTap: () {
                context.goNamed(SettingsSubRoute.folderConfiguration.toName);
              }),
          commonTile(
              icon: FontAwesomeIcons.gears,
              title: 'Server Functions',
              onTap: () {
                context.goNamed(SettingsSubRoute.serverFunctions.toName);
              }),
          commonTile(
              icon: FontAwesomeIcons.circleInfo,
              title: 'App Info',
              onTap: () {
                context.goNamed(SettingsSubRoute.appInfo.toName);
              }),
        ],
      ));
}
