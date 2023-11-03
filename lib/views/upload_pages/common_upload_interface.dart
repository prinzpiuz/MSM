// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/providers/upload_provider.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/views/upload_pages/upload_item_card.dart';
import 'package:msm/views/upload_pages/upload_page_utils.dart';

class CommonUploadPage extends StatefulWidget {
  const CommonUploadPage({Key? key}) : super(key: key);

  @override
  CommonUploadPageState createState() => CommonUploadPageState();
}

class CommonUploadPageState extends State<CommonUploadPage> {
  @override
  Widget build(BuildContext context) {
    UploadState uploadState = Provider.of<UploadState>(context);
    return handleBackButton(
        child: commonUpload(context, uploadState),
        context: context,
        backRoute: getBackPage(uploadState),
        uploadState: uploadState);
  }
}

Widget commonUpload(BuildContext context, UploadState uploadState) {
  return Scaffold(
      appBar: appBar(context, uploadState),
      backgroundColor: CommonColors.commonWhiteColor,
      body: body(context, uploadState));
}

Widget body(BuildContext context, UploadState uploadState) {
  return FutureBuilder<List<FileOrDirectory>>(
    future: FileManager.getAllFiles(uploadState),
    builder:
        (BuildContext context, AsyncSnapshot<List<FileOrDirectory>> snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.hasData) {
        if (snapshot.data!.isEmpty) {
          return Center(
            child: AppText.centerText(
                "No ${uploadState.getCategory.getTitle} Here",
                style: AppTextStyles.bold(CommonColors.commonBlackColor,
                    AppFontSizes.noDataFontSize.sp)),
          );
        } else {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return TextButton(
                  onPressed: () {
                    goInside(snapshot.data![index], uploadState, context);
                  },
                  child: uploadItemCard(
                      context, snapshot.data![index], uploadState),
                );
              });
        }
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        return commonCircularProgressIndicator;
      }
    },
  );
}

Widget uploadItemCard(
    BuildContext context, FileOrDirectory data, UploadState uploadState) {
  return Padding(
    padding: EdgeInsets.only(top: 10.h),
    child: Stack(
      children: [
        dataCard(data),
        UploadItemCard(data: data, fileUploadData: uploadState.fileUploadData)
      ],
    ),
  );
}

PreferredSizeWidget appBar(BuildContext context, UploadState uploadState) {
  return commonAppBar(
      context: context,
      text: uploadState.getCurrentListing,
      backroute: getBackPage(uploadState),
      actions: [
        Padding(
          padding: EdgeInsets.all(10.h),
          child: IconButton(
              onPressed: () {
                uploadState.fileAddOrRemove;
                uploadState.fileUploadData.clear;
              },
              icon: trashIcon),
        ),
        Padding(
          padding: EdgeInsets.all(10.h),
          child: IconButton(
              onPressed: (() {
                if (uploadState.fileUploadData.uploadData.isNotEmpty) {
                  uploadState.commonClear;
                  bottomSheet(context, uploadState, saveHere: true);
                } else {
                  showMessage(context: context, text: AppMessages.selectFiles);
                }
              }),
              icon: sendIcon),
        )
      ],
      uploadState: uploadState);
}

Widget get sendIcon => const Icon(
      Icons.send_outlined,
      color: CommonColors.commonBlackColor,
      size: AppFontSizes.appBarIconSize,
    );

Widget get trashIcon => const Icon(
      FontAwesomeIcons.trashCan,
      color: CommonColors.commonBlackColor,
      size: AppFontSizes.appBarIconSize,
    );

Widget fileName(FileOrDirectory data) {
  return AppText.singleLineText(data.name,
      style: AppTextStyles.medium(CommonColors.commonBlackColor, 15));
}

Widget fileMetaData(FileOrDirectory data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText.text(data.isFile ? data.location.toString() : "Folder",
          style: AppTextStyles.medium(CommonColors.commonGreyColor, 10)),
      AppText.text(
          data.isFile
              ? "${data.extension}, ${data.size}"
              : "Files: ${data.fileCount}",
          style: AppTextStyles.medium(CommonColors.commonGreyColor, 10))
    ],
  );
}

Widget dataCard(FileOrDirectory data) {
  return Center(
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
              children: [fileName(data), fileMetaData(data)]),
        ),
      ),
    ),
  );
}
