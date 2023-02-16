// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/models/server_functions.dart';
import 'package:msm/models/storage.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/settings/settings_utils.dart';
import 'package:msm/ui_components/switch/switch.dart';

class ServerFunctions extends StatefulWidget {
  const ServerFunctions({super.key});

  @override
  State<ServerFunctions> createState() => _ServerFunctionsState();
}

class _ServerFunctionsState extends State<ServerFunctions> {
  @override
  Widget build(BuildContext context) {
    ServerFunctionsData serverFunctionsData = Storage().getServerFunctions;
    return functions(context, serverFunctionsData);
  }
}

Widget functions(
    BuildContext context, ServerFunctionsData serverFunctionsData) {
  return Scaffold(
      appBar: commonAppBar(
          backroute: Pages.settings.toPath,
          context: context,
          text: SettingsSubRoute.serverFunctions.toTitle),
      backgroundColor: CommonColors.commonWhiteColor,
      floatingActionButton: saveButton(
          onPressed: () => saveServerFunctions(serverFunctionsData, context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          CommonSwitch(
            text: 'Wake On Lan',
            value: serverFunctionsData.wakeOnLan,
            onChanged: (value) => {serverFunctionsData.wakeOnLan = value},
          ),
          CommonSwitch(
              text: 'AutoUpdate Server',
              value: serverFunctionsData.autoUpdate,
              onChanged: (value) => serverFunctionsData.autoUpdate = value),
        ],
      ));
}
