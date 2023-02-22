// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/server.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/views/home/home_common_widgets.dart';
import 'package:msm/views/home/home_utils.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return handleBackButton(child: home(context), context: context);
  }
}

Widget home(BuildContext context) {
  return GestureDetector(
    onHorizontalDragUpdate: (details) => notificationsPage(context, details),
    child: Scaffold(
        backgroundColor: CommonColors.commonWhiteColor,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              menuGrid(context),
              serverDetailsBuilder(context),
            ],
          ),
        )),
  );
}

Widget menuGrid(BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(top: 18.h, bottom: 30.h),
    child: GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.all(16.h),
      crossAxisCount: 2,
      children: List.generate(4, (index) {
        return Container(
          color: CommonColors.commonGreenColor,
          margin: EdgeInsets.all(8.h),
          child: OutlinedButton(
              onPressed: () => goToPage(index, context),
              child: Center(
                child: homeIconList[index],
              )),
        );
      }),
    ),
  );
}

Widget serverDetailsBuilder(BuildContext context) {
  Server server = Provider.of<AppService>(context).server;
  final Future basicDetails =
      BasicDetails(serverData: server.serverData).getUser;
  return FutureBuilder(
      future: basicDetails,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return serverdetails(snapshot.data);
        } else {
          return connectionState;
        }
      });
}

Widget serverdetails(dynamic data) {
  return Stack(children: <Widget>[
    SizedBox(
      width: 200.w,
      height: 200.w,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: .7),
        duration: const Duration(milliseconds: 3500),
        builder: (context, double value, _) => CircularProgressIndicator(
          strokeWidth: 15.sp,
          color: CommonColors.commonGreenColor,
          backgroundColor: CommonColors.diskUsageBackgroundColor,
          value: value,
          semanticsLabel: 'System Disk Usage Data',
        ),
      ),
    ),
    Positioned(
      top: 15.h,
      left: 10.w,
      right: 10.w,
      child: serverDetails(data),
    )
  ]);
}

Widget get connectionState => Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20.h),
          child: const CircularProgressIndicator(
              color: CommonColors.commonGreenColor),
        ),
        AppText.centerSingleLineText(AppConstants.connecting,
            style: AppTextStyles.regular(CommonColors.commonBlackColor,
                AppFontSizes.connectingFontSize)),
      ],
    );
