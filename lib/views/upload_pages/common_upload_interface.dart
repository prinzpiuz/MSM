// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/font_sizes.dart';
import 'package:msm/helpers/common_utils.dart';
import 'package:msm/helpers/file_manager.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/ui_components/text.dart';
import 'package:msm/views/ui_components/textstyles.dart';
import 'package:msm/views/upload_pages/upload_page_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class CommonUploadPage extends StatefulWidget {
  const CommonUploadPage({Key? key}) : super(key: key);

  @override
  CommonUploadPageState createState() => CommonUploadPageState();
}

class CommonUploadPageState extends State<CommonUploadPage> {
  @override
  Widget build(BuildContext context) {
    return handleBackButton(
        child: commonUpload(context),
        context: context,
        backRoute: Pages.upload.toPath);
  }
}

Widget commonUpload(BuildContext context) {
  return Scaffold(
      appBar: commonAppBar(context: context, text: "Movies"),
      backgroundColor: CommonColors.commonWhiteColor,
      body: FutureBuilder<List<FileObject>>(
        future: FileManager
            .getAllFiles(), // a previously-obtained Future<String> or null
        builder:
            (BuildContext context, AsyncSnapshot<List<FileObject>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return uploadItemCard(context, snapshot.data![index]);
                });
          } else {
            return commonCircularProgressIndicator;
          }
        },
      ));
}

Widget uploadItemCard(BuildContext context, FileObject data) {
  return Padding(
    padding: EdgeInsets.only(top: 10.h),
    child: Stack(
      children: [
        Center(
          child: Card(
            elevation: 3,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: SizedBox(
              width: 300.w,
              height: 122.h,
              child: Padding(
                padding: EdgeInsets.all(15.h),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.singleLineText(data.name,
                          style: AppTextStyles.medium(
                              CommonColors.commonBlackColor, 15)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.text(data.location,
                              style: AppTextStyles.medium(
                                  CommonColors.commonGreyColor, 10)),
                          AppText.text("${data.extention}, ${data.size}",
                              style: AppTextStyles.medium(
                                  CommonColors.commonGreyColor, 10))
                        ],
                      )
                    ]),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 15.h,
          right: 50.w,
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: CommonColors.commonGreenColor),
            child: IconButton(
                onPressed: (() => debugPrint("added")),
                icon: Icon(
                  Icons.add,
                  color: CommonColors.commonWhiteColor,
                  size: 30.h,
                )),
          ),
        )
      ],
    ),
  );
}
