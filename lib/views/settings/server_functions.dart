// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/settings/settings_utils.dart';

class ServerFunctions extends StatefulWidget {
  const ServerFunctions({super.key});

  @override
  State<ServerFunctions> createState() => _ServerFunctionsState();
}

class _ServerFunctionsState extends State<ServerFunctions> {
  @override
  Widget build(BuildContext context) {
    return wolDetailsForm(context);
  }
}

Widget wolDetailsForm(BuildContext context) {
  return Scaffold(
      appBar: commonAppBar(
          backroute: Pages.settings.toPath,
          context: context,
          text: SettingsSubRoute.serverFunctions.toTitle),
      backgroundColor: CommonColors.commonWhiteColor,
      floatingActionButton: saveButton(onPressed: () => {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          commonSwitch(
            value: false,
            text: 'Wake On Lan',
            onChange: (bool data) {
              print(data);
            },
          ),
          commonSwitch(
            value: true,
            text: 'AutoUpdate Server',
            onChange: (bool data) {
              print(data);
            },
          )
        ],
      ));
}
