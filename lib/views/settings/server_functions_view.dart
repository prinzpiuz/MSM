// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/server_functions.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/ui_components/switch/switch.dart';
import 'package:msm/views/settings/settings_utils.dart';

class ServerFunctions extends StatefulWidget {
  const ServerFunctions({super.key});

  @override
  State<ServerFunctions> createState() => _ServerFunctionsState();
}

class _ServerFunctionsState extends State<ServerFunctions> {
  @override
  Widget build(BuildContext context) {
    AppService appService = Provider.of<AppService>(context);
    return functions(context, appService);
  }
}

Widget functions(BuildContext context, AppService appService) {
  ServerFunctionsData serverFunctionsData =
      appService.storage.getServerFunctions;
  return Scaffold(
      key: ContextKeys.serverFunctionsPagekey,
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
              onChanged: (value) => serverFunctionsData.wakeOnLan = value),
          // CommonSwitch(
          //     text: 'AutoUpdate Server',
          //     value: serverFunctionsData.autoUpdate,
          //     onChanged: (value) => serverFunctionsData.autoUpdate = value),
          serverFunctionsData.sendTokindle
              ? editSendToKindle(serverFunctionsData.sendTokindle)
              : CommonSwitch(
                  text: 'Send To Kindle',
                  value: serverFunctionsData.sendTokindle,
                  onChanged: (value) => setKindleDetails(value)),
        ],
      ));
}
