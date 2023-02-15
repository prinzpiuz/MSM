// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
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
              subtitle: 'Details Regarding Server',
              onTap: () {
                context.goNamed(SettingsSubRoute.serverDetails.toName);
              }),
          commonTile(
              icon: FontAwesomeIcons.folderClosed,
              title: 'Folder Configurations',
              subtitle: 'Folder Locations In Server',
              onTap: () {
                context.goNamed(SettingsSubRoute.folderConfiguration.toName);
              }),
          commonTile(
              icon: FontAwesomeIcons.gears,
              title: 'Server Functions',
              subtitle: 'Extra Functions In Server',
              onTap: () {
                context.goNamed(SettingsSubRoute.serverFunctions.toName);
              }),
          commonTile(
              icon: FontAwesomeIcons.circleInfo,
              title: 'App Info',
              subtitle: 'Application Details',
              onTap: () {
                context.goNamed(SettingsSubRoute.appInfo.toName);
              }),
        ],
      ));
}
