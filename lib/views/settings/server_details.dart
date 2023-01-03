// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/settings/settings_utils.dart';
import 'package:msm/views/ui_components/textfield/textfield.dart';

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
  return Scaffold(
      appBar: commonAppBar(
          backroute: Pages.settings.toPath,
          context: context,
          text: SettingsSubRoute.serverDetails.toTitle),
      backgroundColor: CommonColors.commonWhiteColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: saveButton(
        onPressed: () => print("save"),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            AppTextField.commonTextFeild(
              onsaved: (data) {
                print(data);
              },
              keyboardType: TextInputType.text,
              labelText: "Server Name",
              hintText: "Name Of Your Server",
            ),
            AppTextField.commonTextFeild(
              onsaved: (data) {
                print(data);
              },
              keyboardType: TextInputType.number,
              labelText: "Server Address",
              hintText: "IP Address Of The Server",
            ),
            AppTextField.commonTextFeild(
                onsaved: (data) {
                  print(data);
                },
                keyboardType: TextInputType.visiblePassword,
                labelText: "Root Password",
                hintText: "Root Password Of The Server",
                obscureText: true),
            AppTextField.commonTextFeild(
                onsaved: (data) {
                  print(data);
                },
                keyboardType: TextInputType.number,
                labelText: "Port Number",
                hintText: "SSH Port Number Of The Server",
                initialValue: "22"),
          ],
        ),
      ));
}
