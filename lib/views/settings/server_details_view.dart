// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/server_details.dart';
import 'package:msm/models/storage.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/settings/settings_utils.dart';
import 'package:msm/ui_components/textfield/input_formatters.dart';
import 'package:msm/ui_components/textfield/textfield.dart';
import 'package:msm/ui_components/textfield/validators.dart';

class ServerDetails extends StatefulWidget {
  const ServerDetails({super.key});

  @override
  State<ServerDetails> createState() => _ServerDetailsState();
}

class _ServerDetailsState extends State<ServerDetails> {
  @override
  Widget build(BuildContext context) {
    return serverDetailsForm(context);
  }
}

Widget serverDetailsForm(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  ServerData serverData = Storage().getServerData;
  return Scaffold(
      appBar: commonAppBar(
          backroute: Pages.settings.toPath,
          context: context,
          text: SettingsSubRoute.serverDetails.toTitle),
      backgroundColor: CommonColors.commonWhiteColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: saveButton(
        onPressed: () =>
            {hideKeyboard(context), saveServerDetails(formKey, serverData)},
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              nameField(serverData),
              hostField(serverData),
              passwordField(serverData),
              portField(serverData),
              macField(serverData)
            ],
          ),
        ),
      ));
}

Widget nameField(ServerData serverData) => AppTextField.commonTextFeild(
      onsaved: (data) {
        serverData.serverName = data;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(AppConstants.upperLower)),
      ],
      initialValue: serverData.serverName,
      validator: validateServerName,
      keyboardType: TextInputType.text,
      labelText: "Server Name",
      hintText: "Name Of Your Server",
    );

Widget hostField(ServerData serverData) => AppTextField.commonTextFeild(
      onsaved: (data) {
        serverData.serverHost = data;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(AppConstants.ipFormat)),
        LengthLimitingTextInputFormatter(15),
        IpAddressInputFormatter()
      ],
      initialValue: serverData.serverHost,
      validator: valueNeeded,
      keyboardType: TextInputType.number,
      labelText: "Server Host",
      hintText: "IP Address Of The Server",
    );

Widget passwordField(ServerData serverData) => AppTextField.commonTextFeild(
    onsaved: (data) {
      serverData.rootPassword = data;
    },
    initialValue: serverData.rootPassword,
    validator: valueNeeded,
    keyboardType: TextInputType.visiblePassword,
    labelText: "Root Password",
    hintText: "Root Password Of The Server",
    obscureText: true);

Widget portField(ServerData serverData) => AppTextField.commonTextFeild(
      onsaved: (data) {
        serverData.portNumber = data;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(AppConstants.numberOnly)),
      ],
      initialValue: serverData.portNumber,
      validator: validatePortNumber,
      keyboardType: TextInputType.number,
      labelText: "Port Number",
      hintText: "SSH Port Number Of The Server",
    );

Widget macField(ServerData serverData) => AppTextField.commonTextFeild(
      onsaved: (data) {
        serverData.macAddress = data;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(AppConstants.macFormat)),
        UpperCaseTextFormatter(),
        MACAddressInputFormatter(),
      ],
      initialValue: serverData.macAddress,
      validator: macValidation,
      keyboardType: TextInputType.text,
      labelText: "MAC Address",
      hintText: "MAC Address Of Your Server In Upper Case",
    );
