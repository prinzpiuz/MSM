// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/settings/settings_utils.dart';
import 'package:msm/views/ui_components/textfield/textfield.dart';

class WOLDetails extends StatefulWidget {
  const WOLDetails({super.key});

  @override
  State<WOLDetails> createState() => _WOLDetailsState();
}

class _WOLDetailsState extends State<WOLDetails> {
  @override
  Widget build(BuildContext context) {
    return wolDetailsForm(context);
  }
}

Widget wolDetailsForm(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  return Scaffold(
      appBar: commonAppBar(
          backroute: Pages.settings.toPath,
          context: context,
          text: SettingsSubRoute.wakeOnLan.toTitle),
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
              labelText: "MAC Address",
              hintText: "MAC Address Of Your Server",
            ),
          ],
        ),
      ));
}
