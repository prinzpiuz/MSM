// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/router/router_utils.dart';

class SystemTools extends StatelessWidget {
  const SystemTools({super.key});

  @override
  Widget build(BuildContext context) {
    return handleBackButton(context: context, child: systemToolsMenu(context));
  }
}

Widget systemToolsMenu(BuildContext context) {
  return Scaffold(
      appBar: commonAppBar(
          text: Pages.systemTools.toTitle,
          backroute: Pages.home.toPath,
          context: context),
      backgroundColor: CommonColors.commonWhiteColor,
      body: ListView(
        padding: commonListViewTopPadding,
        children: [
          commonTile(
              icon: FontAwesomeIcons.terminal,
              title: 'Live Terminal',
              subtitle: 'To live interact with server terminal',
              onTap: () =>
                  context.goNamed(SystemToolsSubRoute.liveTerminal.toName)),
          commonTile(
              icon: FontAwesomeIcons.gears,
              title: 'Services',
              subtitle: 'Systemd services available in server',
              onTap: () =>
                  context.goNamed(SystemToolsSubRoute.services.toName)),
          commonTile(
              icon: FontAwesomeIcons.floppyDisk,
              title: 'Saved Commands',
              subtitle: 'Pre-saved commands to run instantly',
              onTap: () {
                print("pressed2");
              }),
          commonTile(
              icon: FontAwesomeIcons.user,
              title: 'User Management',
              subtitle: 'Linux user management(Experimental)',
              onTap: () {
                print("pressed2");
              }),
          commonTile(
              icon: FontAwesomeIcons.download,
              title: 'Sytem Upgrade',
              subtitle: 'Commands to update system OS',
              onTap: () {
                print("pressed2");
              }),
          commonTile(
              icon: FontAwesomeIcons.gaugeHigh,
              title: 'Speed Test',
              subtitle: 'Test your network speed',
              onTap: () {
                print("pressed2");
              }),
          commonTile(
              icon: FontAwesomeIcons.tableTennisPaddleBall,
              title: 'Ping Test',
              subtitle: 'Send ICMP echo request to configured host',
              onTap: () {
                print("pressed2");
              }),
          commonTile(
              icon: FontAwesomeIcons.chartColumn,
              title: 'Charts',
              subtitle: 'See your system perfomance in graphs',
              onTap: () {
                print("pressed2");
              })
        ],
      ));
}
