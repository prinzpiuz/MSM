// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/background_tasks.dart';
import 'package:msm/router/router_utils.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return handleBackButton(context: context, child: notifications(context));
  }
}

Widget notifications(BuildContext context) {
  return Scaffold(
      appBar: commonAppBar(
          text: Pages.notifications.toTitle,
          backroute: Pages.home.toPath,
          actions: [
            IconButton(
                color: CommonColors.commonBlackColor,
                onPressed: () {
                  showMessage(
                      context: context,
                      text: AppMessages.clearingTasks,
                      duration: 5);
                  BackgroundTasks.cancel;
                },
                icon: const Icon(FontAwesomeIcons.broom))
          ],
          context: context),
      backgroundColor: CommonColors.commonWhiteColor,
      body: const Center(
        child: Text("Notifications"),
      ));
}
