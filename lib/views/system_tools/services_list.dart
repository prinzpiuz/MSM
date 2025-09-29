// ignore_for_file: use_build_context_synchronously

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/utils.dart';
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/utils/commands/command_executer.dart';
import 'package:msm/utils/commands/services.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';

class ServicesList extends StatelessWidget {
  const ServicesList({super.key});

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
  final Future<List<Services>> servicesList =
      commandExecuter.availableServices();
  if (connected) {
    return FutureBuilder(
        future: servicesList,
        builder: (context, AsyncSnapshot<List<Services>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            if (snapshot.data!.isNotEmpty) {
              return serviceListView(snapshot.data!, context);
            }
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

Widget serviceListView(List<Services> services, BuildContext context) {
  final AppService appService = Provider.of<AppService>(context);
  CommandExecuter commandExecuter = appService.commandExecuter;
  return ListView.builder(
      itemCount: services.length,
      itemBuilder: (context, i) {
        services[i].client = commandExecuter.client!;
        return serviceCard(services[i], context);
      });
}

Widget serviceCard(Services service, BuildContext context) {
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
          height: 133.h,
          child: Padding(
            padding: EdgeInsets.all(15.h),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  serviceName(service),
                  serviceStatus(service),
                  serviceDesc(service),
                  buttonRow(service, context)
                ]),
          ),
        ),
      ),
    ),
  );
}

Widget serviceName(Services service) {
  return AppText.singleLineText(service.serviceName,
      style: AppTextStyles.medium(CommonColors.commonBlackColor, 20));
}

Widget serviceStatus(Services service) {
  return AppText.singleLineText("Status: ${service.serviceStatus}",
      style: AppTextStyles.medium(CommonColors.commonBlackColor, 15));
}

Widget serviceDesc(Services service) {
  return AppText.singleLineText(service.description,
      style: AppTextStyles.medium(CommonColors.commonBlackColor, 15));
}

Widget buttonRow(Services service, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      service.isActive
          ? stopButton(service, context)
          : startButton(service, context),
      statusButton(service, context),
      restartButton(service, context)
    ],
  );
}

Widget startButton(Services service, BuildContext context) {
  final AppService appService = Provider.of<AppService>(context);
  return Padding(
    padding: EdgeInsets.only(right: 8.w),
    child: IconButton(
      onPressed: () async {
        await service.start.then((value) {
          showMessage(
              duration: 5,
              context: context,
              text: actionStatus(service, "start", value));
          appService.pageRefresh;
        });
      },
      icon: const Icon(
        FontAwesomeIcons.circlePlay,
        color: CommonColors.commonBlackColor,
      ),
    ),
  );
}

Widget stopButton(Services service, BuildContext context) {
  final AppService appService = Provider.of<AppService>(context);
  return IconButton(
    onPressed: () async {
      await service.stop.then((value) {
        showMessage(
            duration: 5,
            context: context,
            text: actionStatus(service, "stop", value));
        appService.pageRefresh;
      });
    },
    icon: const Icon(FontAwesomeIcons.circleStop,
        color: CommonColors.commonBlackColor),
  );
}

Widget statusButton(Services service, BuildContext context) {
  return IconButton(
      onPressed: () async {
        String status = await service.status;
        dailogBox(
            onlycancel: true,
            context: context,
            title: service.serviceName,
            content: actionContent(status));
      },
      icon: const Icon(FontAwesomeIcons.circleInfo,
          color: CommonColors.commonBlackColor));
}

Widget restartButton(Services service, BuildContext context) {
  return IconButton(
      onPressed: () async {
        await service.restart.then((value) => showMessage(
            duration: 5,
            context: context,
            text: actionStatus(service, "restart", value)));
      },
      icon: const Icon(
        FontAwesomeIcons.rotate,
        color: CommonColors.commonBlackColor,
      ));
}

Widget actionContent(String content) {
  return SingleChildScrollView(
    child: Text(content,
        style: AppTextStyles.medium(CommonColors.commonBlackColor, 15)),
  );
}

String actionStatus(Services service, String action, bool status) {
  if (status) {
    return "${service.serviceName} ${action}ed successfully";
  }
  return "${service.serviceName} ${action}ing failed";
}
