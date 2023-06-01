import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:msm/common_utils.dart';
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/commands/command_executer.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:provider/provider.dart';

class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    return handleBackButton(context: context, child: serviceList(context));
  }
}

Widget serviceList(BuildContext context) {
  return Scaffold(
    appBar: commonAppBar(
        text: SystemToolsSubRoute.services.toTitle,
        backroute: Pages.systemTools.toPath,
        context: context),
    backgroundColor: CommonColors.commonWhiteColor,
    body: serviceFetcher(context),
  );
}

Widget serviceFetcher(BuildContext context) {
  final AppService appService = Provider.of<AppService>(context);
  final bool connected = appService.connectionState;
  CommandExecuter commandExecuter = appService.commandExecuter;
  final Future<List> servicesList = commandExecuter.availableServices();
  if (connected) {
    return FutureBuilder(
        future: servicesList,
        builder: (context, AsyncSnapshot<List?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            if (snapshot.data!.isNotEmpty) {}
            return Center(
              child: AppText.centerSingleLineText("No Services",
                  style: AppTextStyles.medium(CommonColors.commonBlackColor,
                      AppFontSizes.noFilesFontSize.sp)),
            );
          } else if (snapshot.hasError) {
            return Center(child: serverNotConnected(appService, text: false));
          } else {
            return commonCircularProgressIndicator;
          }
        });
  } else {
    return Center(child: serverNotConnected(appService, text: false));
  }
}

Widget serviceCard() {
  return Padding(
    padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
    child: Center(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.r)),
        ),
        child: SizedBox(
          width: 300.w,
          height: 122.h,
          child: Padding(
            padding: EdgeInsets.all(15.h),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [serviceName(), serviceStatus(), buttonRow()]),
          ),
        ),
      ),
    ),
  );
}

Widget serviceName() {
  return AppText.singleLineText("Mysql",
      style: AppTextStyles.medium(CommonColors.commonBlackColor, 20));
}

Widget serviceStatus() {
  return AppText.singleLineText("Status: Running",
      style: AppTextStyles.medium(CommonColors.commonBlackColor, 15));
}

Widget buttonRow() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [startButton(), stopButton()],
  );
}

Widget startButton() {
  return Padding(
    padding: EdgeInsets.only(right: 8.w),
    child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(
          FontAwesomeIcons.circlePlay,
          color: CommonColors.commonBlackColor,
        ),
        label: Text("Start",
            style: AppTextStyles.medium(CommonColors.commonBlackColor, 13))),
  );
}

Widget stopButton() {
  return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(FontAwesomeIcons.circleStop,
          color: CommonColors.commonBlackColor),
      label: Text("Stop",
          style: AppTextStyles.medium(CommonColors.commonBlackColor, 13)));
}

Widget restartButton() {
  return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(
        FontAwesomeIcons.rotate,
        color: CommonColors.commonBlackColor,
      ),
      label: Text("Restart",
          style: AppTextStyles.medium(CommonColors.commonBlackColor, 13)));
}
