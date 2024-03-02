// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/common_widgets.dart';
import 'package:msm/models/commands/basic_details.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/views/home/home_common_widgets.dart';

class RealTimeBasicDetails extends StatefulWidget {
  final AppService appService;
  final BasicDetails basicDetails;
  const RealTimeBasicDetails(
      {super.key, required this.appService, required this.basicDetails});

  @override
  RealTimeBasicDetailsState createState() => RealTimeBasicDetailsState();
}

class RealTimeBasicDetailsState extends State<RealTimeBasicDetails> {
  StreamController<BasicDetails> basicDetailsStreamController =
      StreamController.broadcast();

  @override
  void dispose() {
    basicDetailsStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BasicDetails>(
        initialData: widget.basicDetails,
        stream: fetchBasicDetailsLive(
            basicDetailsStreamController, widget.appService),
        builder: (
          BuildContext context,
          AsyncSnapshot<BasicDetails> snapshot,
        ) {
          if (snapshot.hasData) {
            return serverDetails(snapshot.data);
          }
          return commonCircularProgressIndicator;
        });
  }
}
