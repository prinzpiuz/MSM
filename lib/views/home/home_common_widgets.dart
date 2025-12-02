// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/utils/commands/basic_details.dart';

/// Data class representing an icon configuration for the home page.
class HomeIconData {
  final IconData icon;
  final bool fontAwesome;
  final Color color;

  const HomeIconData(this.icon,
      {this.fontAwesome = false, this.color = Colors.white});
}

/// Builds an icon widget for the home page.
///
/// [icon] The icon data to display.
/// [fontAwesome] Whether to use FontAwesome icon. Defaults to false.
/// [color] The color of the icon. Defaults to white.
Widget homePageIcon(IconData icon,
    {bool fontAwesome = false, Color color = Colors.white}) {
  final double iconSize = AppFontSizes.homePageIconFontSize.h;
  if (fontAwesome) {
    return FaIcon(icon, size: iconSize, color: color);
  } else {
    return Icon(icon, size: iconSize, color: color);
  }
}

/// Configuration data for home page icons. Order matters for display/navigation.
const List<HomeIconData> homeIconDataList = [
  HomeIconData(Icons.cloud_upload_outlined),
  HomeIconData(FontAwesomeIcons.screwdriverWrench, fontAwesome: true),
  HomeIconData(Icons.folder_outlined),
  HomeIconData(Icons.settings),
];

/// Computed list of home page icon widgets from the data configuration.
List<Widget> get homeIconList => homeIconDataList
    .map((data) => homePageIcon(data.icon,
        fontAwesome: data.fontAwesome, color: data.color))
    .toList();

Widget serverStats(IconData icon, String text) {
  return Padding(
    padding: EdgeInsets.only(right: 8.w),
    child: Wrap(
      spacing: 6.0, // gap between adjacent chips
      children: <Widget>[
        Icon(icon, size: 18.h, color: CommonColors.commonBlackColor),
        AppText.singleLineText(text,
            style: AppTextStyles.bold(CommonColors.commonBlackColor,
                AppFontSizes.serverStatFontSize.toDouble()))
      ],
    ),
  );
}

/// Builds the server header section with icon and user name.
Widget _buildServerHeader(BasicDetails data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      homePageIcon(Icons.cloud, color: CommonColors.commonGreenColor),
      Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: AppText.centerSingleLineText(
          data.user,
          style: AppTextStyles.bold(
            CommonColors.commonBlackColor,
            AppFontSizes.serverStatFontSize,
          ),
        ),
      ),
    ],
  );
}

/// Builds the server statistics section with RAM, disk, temperature, and uptime.
Widget _buildServerStats(BasicDetails data) {
  return Column(
    children: [
      serverStats(
        FontAwesomeIcons.brain,
        data.cpu.formattedModelName,
      ),
      SizedBox(height: AppMeasurements.serverStatGap.h),
      serverStats(
        FontAwesomeIcons.microchip,
        '${data.cpu.loadFormatted}, @${data.cpu.freqGhz}',
      ),
      SizedBox(height: AppMeasurements.serverStatGap.h),
      serverStats(
        FontAwesomeIcons.memory,
        '${data.ramUsed}/${data.ramSize} (${data.ram.usagePercentage})',
      ),
      SizedBox(height: AppMeasurements.serverStatGap.h),
      serverStats(
        Icons.sd_card_outlined,
        '${data.totalDiskUsed}/${data.totalDiskSize} (${data.diskUsagePercentageString})',
      ),
      SizedBox(height: AppMeasurements.serverStatGap.h),
      serverStats(
        Icons.lan_outlined,
        'Down:${data.network.primaryDownload}, Up:${data.network.primaryUpload}',
      ),
      SizedBox(height: AppMeasurements.serverStatGap.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          serverStats(Icons.thermostat, data.getTemperature),
          serverStats(Icons.sports_tennis, data.network.primaryPing),
          serverStats(Icons.alarm, data.getUptime),
        ],
      ),
    ],
  );
}

Widget serverDetails(BasicDetails? data) {
  if (data == null) {
    return commonCircularProgressIndicator;
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _buildServerHeader(data),
      _buildServerStats(data),
    ],
  );
}

Stream<BasicDetails> fetchBasicDetailsLive(AppService appService) {
  final controller = StreamController<BasicDetails>();
  Timer? timer;
  bool isFetching = false;

  void fetch() async {
    if (controller.isClosed || isFetching || !appService.connectionState) {
      return;
    }

    isFetching = true;
    try {
      final BasicDetails? basicDetails =
          await appService.commandExecuter.basicDetails;
      if (basicDetails != null && !controller.isClosed) {
        controller.add(basicDetails);
      } else if (!controller.isClosed) {
        // Handle null response - could log or emit error, but for now skip
        // Optionally: controller.addError('Failed to fetch basic details');
      }
    } catch (e) {
      // Log the error instead of silently catching
      // Assuming a logging mechanism exists, e.g., logger.e('Error fetching basic details', e);
      if (!controller.isClosed) {
        controller.addError(e);
      }
    } finally {
      isFetching = false;
      if (!controller.isClosed) {
        timer = Timer(const Duration(seconds: 5), fetch);
      }
    }
  }

  controller.onListen = fetch;
  controller.onCancel = () {
    timer?.cancel();
    controller.close();
  };

  return controller.stream;
}
