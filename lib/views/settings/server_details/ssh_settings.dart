import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart' show AppMessages;
import 'package:msm/ui_components/textfield/textfield.dart';
import 'package:msm/ui_components/textfield/validators.dart';
import 'package:msm/utils/server.dart' show uploadPublicKey;
import 'package:msm/utils/server_details.dart';
import 'package:msm/utils/ssh_keypair.dart';

Widget sshKeyField(
    BuildContext context,
    ServerData serverData,
    void Function(ServerData, {String? fileSelected}) onSSHFileSelected,
    TextEditingController sshKeyController) {
  return AppTextField.commonTextField(
    controller: sshKeyController,
    readOnly: true,
    suffixIcon: IconButton(
      icon: const Icon(
        Icons.folder_open,
        color: CommonColors.commonBlackColor,
      ),
      tooltip: "Browse",
      onPressed: () => onSSHFileSelected(serverData),
    ),
    validator: valueNeeded,
    keyboardType: TextInputType.none,
    labelText: 'SSH Private Key',
    hintText: 'Select your private key file',
  );
}

Future<void> generateAndSaveSSHKey(BuildContext context, ServerData serverData,
    void Function(ServerData, {String? fileSelected}) onSSHFileSelected) async {
  if (!serverData.detailsForKeyUploadAvailable) {
    showMessage(context: context, text: AppMessages.fillDetails);
    return;
  }
  final password = await askPassword(context: context);
  if (password == null || password.isEmpty) return;

  final keyPair = generateRSAKeyPair();

  try {
    await uploadPublicKey(
      host: serverData.serverHost,
      port: int.parse(serverData.portNumber),
      username: serverData.username,
      password: password,
      publicKey: keyPair.publicKeyOpenSSH,
    );
    if (context.mounted) {
      showMessage(context: context, text: AppMessages.sshKeyUploaded);
    }
    final localKeyPath = await savePrivateKeyLocally(keyPair.privateKeyPem);
    onSSHFileSelected(serverData, fileSelected: localKeyPath);
  } catch (e) {
    if (context.mounted) {
      showMessage(context: context, text: AppMessages.sshKeyNotUploaded);
    }
    return;
  }
}

Widget generateKeyPairButton(
  BuildContext context,
  ServerData serverData,
  void Function(ServerData, {String? fileSelected}) onSSHFileSelected,
) {
  return Padding(
    padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
    child: outlinedTextButton(
        text: "Generate SSH Key Pair",
        onPressed: () => generateAndSaveSSHKey(
              context,
              serverData,
              onSSHFileSelected,
            ),
        icon: Icon(
          Icons.vpn_key,
          color: CommonColors.commonBlackColor,
        )),
  );
}
