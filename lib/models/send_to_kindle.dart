// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:msm/models/local_notification.dart';

class KindleData {
  String fromEmail = "";
  String kindleMailAddress = "";
  String apiKey = "";
  SupportedMailers mailer = SupportedMailers.sendgrid;

  KindleData();

  bool get dataAvailable {
    return fromEmail.isNotEmpty &&
        kindleMailAddress.isNotEmpty &&
        apiKey.isNotEmpty;
  }

  static SupportedMailers _getMailer(String mailerName) {
    if (mailerName == SupportedMailers.sendgrid.name) {
      return SupportedMailers.sendgrid;
    }
    return SupportedMailers.sendgrid;
  }

  KindleData.fromJson(Map<String, dynamic> json)
      : fromEmail = json['fromEmail'],
        kindleMailAddress = json['kindleMailAddress'],
        apiKey = json['apiKey'],
        mailer = _getMailer(json['mailer']);

  Map<String, dynamic> toJson() => {
        'fromEmail': fromEmail,
        'kindleMailAddress': kindleMailAddress,
        'apiKey': apiKey,
        'mailer': mailer.name
      };
}

enum SupportedMailers {
  sendgrid;

  String get getName {
    switch (this) {
      case SupportedMailers.sendgrid:
        return "Sendgrid";
    }
  }

  String get baseUrl {
    switch (this) {
      case SupportedMailers.sendgrid:
        return "https://api.sendgrid.com/v3/mail/send";
    }
  }
}

class SendTokindle {
  final Dio dio = Dio();
  final KindleData kindleData;
  final String fileName;
  SupportedMailers type = SupportedMailers.sendgrid;
  bool enabled = false;
  String base64EncodedData = "";
  late Notifications notifications;

  SendTokindle(
      {required this.base64EncodedData,
      required this.notifications,
      required this.enabled,
      required this.kindleData,
      required this.fileName,
      required this.type});

  Future<Response<dynamic>?> sendMail(SupportedMailers type) async {
    if (enabled) {
      switch (type) {
        case SupportedMailers.sendgrid:
          try {
            final response = await dio.post(
              type.baseUrl,
              options: Options(headers: {
                "Content-type": "application/json",
                "Authorization": "Bearer ${kindleData.apiKey}"
              }),
              data: {
                "personalizations": [
                  {
                    "to": [
                      {"email": kindleData.kindleMailAddress}
                    ]
                  }
                ],
                "from": {"email": kindleData.fromEmail},
                "subject": "Kindle Ebook $fileName",
                "content": [
                  {
                    "type": "text/html",
                    "value": "Hey,<br>Please find attachment."
                  }
                ],
                "attachments": [
                  {
                    "content": base64EncodedData,
                    "type": "text/plain",
                    "filename": fileName
                  }
                ]
              },
              onSendProgress: (int sent, int total) async {
                notifications.sendToKindle(
                    id: fileName.hashCode.toString(),
                    name: fileName,
                    progress: sent,
                    notificationType: NotificationType.kindle,
                    total: total);
              },
            );
            return response;
          } catch (_) {
            return null;
          }
      }
    }
    return null;
  }
}
