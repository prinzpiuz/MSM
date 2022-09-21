// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/common_utils.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/providers/upload_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/ui_components/text.dart';
import 'package:msm/views/ui_components/textstyles.dart';
import 'package:provider/provider.dart';

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
  UploadState uploadState = Provider.of<UploadState>(context);
  return Scaffold(
      appBar:
          commonAppBar(context: context, text: uploadState.getCurrentListing),
      backgroundColor: CommonColors.commonWhiteColor,
      body: FutureBuilder<List<FileOrDirectory>>(
        future: FileManager.getAllFiles(uploadState),
        builder: (BuildContext context,
            AsyncSnapshot<List<FileOrDirectory>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return uploadItemCard(context, snapshot.data![index]);
                });
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return commonCircularProgressIndicator;
          } else {
            return commonCircularProgressIndicator;
          }
        },
      ));
}

Widget uploadItemCard(BuildContext context, FileOrDirectory data) {
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
                          AppText.text(data.location.toString(),
                              style: AppTextStyles.medium(
                                  CommonColors.commonGreyColor, 10)),
                          AppText.text(
                              data.isFile
                                  ? "${data.extention}, ${data.size}"
                                  : "Files: ${data.fileCount}",
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
          child: data.isFile
              ? Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: CommonColors.commonGreenColor),
                  child: IconButton(
                      onPressed: (() => debugPrint("added")),
                      icon: Icon(
                        Icons.add,
                        color: CommonColors.commonWhiteColor,
                        size: 30.h,
                      )),
                )
              : Icon(
                  Icons.folder,
                  color: CommonColors.commonGreyColor,
                  size: 40.h,
                ),
        )
      ],
    ),
  );
}
