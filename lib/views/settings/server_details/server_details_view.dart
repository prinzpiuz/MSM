// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/ui_components/switch/switch.dart';
import 'package:msm/ui_components/textfield/input_formatters.dart';
import 'package:msm/ui_components/textfield/textfield.dart';
import 'package:msm/ui_components/textfield/validators.dart';
// Project imports:
import 'package:msm/utils/server_details.dart';
import 'package:msm/views/settings/server_details/ssh_settings.dart';
import 'package:msm/views/settings/settings_utils.dart';

class ServerDetails extends StatefulWidget {
  const ServerDetails({super.key});

  @override
  State<ServerDetails> createState() => _ServerDetailsState();
}

class _ServerDetailsState extends State<ServerDetails> {
  bool usePassword = false;
  final formKey = GlobalKey<FormState>();
  late TextEditingController sshKeyController;
  late ServerData serverData;

  void toggleUseSSHKey(bool? value) {
    if (value != null) {
      setState(() {
        usePassword = value;
      });
    }
  }

  @override
  void dispose() {
    sshKeyController.dispose();
    super.dispose();
  }

  void onSSHFileSelected(ServerData serverData, {String? fileSelected}) async {
    if (fileSelected == null) {
      final result = await file_picker.FilePicker.platform.pickFiles(
        type: file_picker.FileType.custom,
        allowedExtensions: ['pem', 'key', 'txt'],
      );
      if (result != null && result.files.single.path != null) {
        sshKeyController.text = result.files.single.path!.split('/').last;
        serverData.privateKeyPath = result.files.single.path!;
      }
    } else {
      serverData.privateKeyPath = fileSelected;
      sshKeyController.text = fileSelected.split('/').last;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    serverData =
        Provider.of<AppService>(context, listen: false).storage.getServerData;
    sshKeyController = TextEditingController(text: serverData.privateKeyPath);
  }

  @override
  Widget build(BuildContext context) {
    return serverDetailsForm(context);
  }

  Widget serverDetailsForm(BuildContext context) {
    return Scaffold(
        appBar: commonAppBar(
            backroute: Pages.settings.toPath,
            context: context,
            text: SettingsSubRoute.serverDetails.toTitle),
        backgroundColor: CommonColors.commonWhiteColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: saveButton(
          onPressed: () => saveServerDetails(formKey, serverData, context),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                nameField(serverData),
                hostField(serverData),
                usernameField(serverData),
                if (usePassword)
                  passwordField(serverData)
                else ...[
                  sshKeyField(
                      context, serverData, onSSHFileSelected, sshKeyController),
                  generateKeyPairButton(context, serverData, onSSHFileSelected),
                ],
                switchField(),
                portField(serverData),
                macField(serverData)
              ],
            ),
          ),
        ));
  }

  Widget switchField() => Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
        child: CommonSwitch(
            text: 'Use Password Instead of SSH?',
            value: usePassword,
            onChanged: toggleUseSSHKey),
      );

  Widget nameField(ServerData serverData) => AppTextField.commonTextField(
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

  Widget usernameField(ServerData serverData) => AppTextField.commonTextField(
        onsaved: (data) {
          serverData.username = data;
        },
        onChanged: (data) => serverData.username = data,
        initialValue: serverData.username,
        validator: validateServerName,
        keyboardType: TextInputType.text,
        labelText: "Username",
        hintText: "User Name Of Server",
      );

  Widget hostField(ServerData serverData) => AppTextField.commonTextField(
        onsaved: (data) {
          serverData.serverHost = data;
        },
        onChanged: (data) => serverData.serverHost = data,
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

  Widget passwordField(ServerData serverData) => AppTextField.commonTextField(
      onsaved: (data) {
        serverData.rootPassword = data;
      },
      initialValue: serverData.rootPassword,
      validator: valueNeeded,
      keyboardType: TextInputType.visiblePassword,
      labelText: "Root Password",
      hintText: "Root Password Of The Server",
      obscureText: true);

  Widget portField(ServerData serverData) => AppTextField.commonTextField(
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

  Widget macField(ServerData serverData) => AppTextField.commonTextField(
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
}
