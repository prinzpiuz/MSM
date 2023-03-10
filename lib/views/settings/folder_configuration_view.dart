// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/models/folder_configuration.dart';
import 'package:msm/models/storage.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/folder_configuration_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/settings/settings_utils.dart';

class FolderConfigurationForm extends StatefulWidget {
  const FolderConfigurationForm({super.key});

  @override
  State<FolderConfigurationForm> createState() =>
      _FolderConfigurationFormState();
}

class _FolderConfigurationFormState extends State<FolderConfigurationForm> {
  @override
  Widget build(BuildContext context) {
    return folderConfigurationForm(context);
  }
}

Widget folderConfigurationForm(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  FolderConfiguration folderConfiguration =
      Provider.of<AppService>(context).storage.getFolderConfigurations;
  getFoldersList(context, folderConfiguration, formKey);
  List<Widget> folders = Provider.of<FolderConfigState>(context).pathTextFields;
  return Scaffold(
      appBar: commonAppBar(
          backroute: Pages.settings.toPath,
          context: context,
          text: SettingsSubRoute.folderConfiguration.toTitle),
      backgroundColor: CommonColors.commonWhiteColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: saveButton(
        onPressed: () =>
            saveFolderConfigurations(formKey, folderConfiguration, context),
      ),
      body: Form(
        key: formKey,
        child: ListView.builder(
            itemCount: folders.length,
            itemBuilder: (BuildContext context, int index) {
              return folders[index];
            }),
      ));
}
