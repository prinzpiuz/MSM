// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:msm/models/local_notification.dart';

enum SupportedMailers {
  sendgrid,
  mailchimp;
}

class SendTokindle {
  final Dio dio = Dio();
  final String fromEmail;
  final String kindleMailAddress;
  final String apiKey;
  final String fileName;
  SupportedMailers type = SupportedMailers.sendgrid;
  bool enabled = false;
  String base64EncodedData = "";
  late Notifications notifications;

  SendTokindle(
      {required this.base64EncodedData,
      required this.notifications,
      required this.enabled,
      required this.fromEmail,
      required this.kindleMailAddress,
      required this.apiKey,
      required this.fileName,
      required this.type});

  Future<Response<dynamic>?> sendMail(SupportedMailers type) async {
    if (enabled) {
      switch (type) {
        case SupportedMailers.sendgrid:
          try {
            final response = await dio.post(
              'https://api.sendgrid.com/v3/mail/send',
              options: Options(headers: {
                "Content-type": "application/json",
                "Authorization": "Bearer $apiKey"
              }),
              data: {
                "personalizations": [
                  {
                    "to": [
                      {"email": kindleMailAddress}
                    ]
                  }
                ],
                "from": {"email": fromEmail},
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

        case SupportedMailers.mailchimp:
          // TODO: Handle this case.
          break;
      }
    }
    return null;
  }
}
