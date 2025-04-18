// Package imports:
// import 'package:dio/dio.dart';

// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Package imports:
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:msm/models/local_notification.dart';

class KindleData {
  String fromEmail = "";
  String kindleMailAddress = "";

  KindleData();

  bool get dataAvailable {
    return fromEmail.isNotEmpty && kindleMailAddress.isNotEmpty;
  }

  KindleData.fromJson(Map<String, dynamic> json)
      : fromEmail = json['fromEmail'],
        kindleMailAddress = json['kindleMailAddress'];

  Map<String, dynamic> toJson() =>
      {'fromEmail': fromEmail, 'kindleMailAddress': kindleMailAddress};
}

Future<File> _getDecodedFile(String filename) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$filename');
  return file;
}

Future<String> _decodeBase64ToFile(String base64String, String filename) async {
  Uint8List decodedBytes = base64Decode(base64String);
  File decodedFile = await _getDecodedFile(filename);
  await decodedFile.writeAsBytes(decodedBytes);
  return decodedFile.path;
}

class SendTokindle {
  final KindleData kindleData;
  final String fileName;
  bool enabled = false;
  String base64EncodedData = "";
  late Notifications notifications;

  SendTokindle(
      {required this.base64EncodedData,
      required this.notifications,
      required this.enabled,
      required this.kindleData,
      required this.fileName});

  Future<bool> sendMail() async {
    if (enabled) {
      String filePath = await _decodeBase64ToFile(base64EncodedData, fileName);
      final Email email = Email(
        subject: "Kindle Ebook $fileName",
        cc: [kindleData.fromEmail],
        recipients: [kindleData.kindleMailAddress],
        attachmentPaths: [filePath],
        isHTML: false,
      );
      try {
        await FlutterEmailSender.send(email);
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }
}
