// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/font_sizes.dart';
import 'package:msm/helpers/common_utils.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/upload_pages/upload_page_utils.dart';

class UploadMenuPage extends StatefulWidget {
  const UploadMenuPage({Key? key}) : super(key: key);

  @override
  UploadMenuPageState createState() => UploadMenuPageState();
}

class UploadMenuPageState extends State<UploadMenuPage> {
  @override
  Widget build(BuildContext context) {
    return handleBackButton(
        child: uploadMenu(context),
        context: context,
        backRoute: Pages.home.toPath);
  }
}

Widget uploadMenu(BuildContext context) {
  return Scaffold(
      backgroundColor: CommonColors.commonWhiteColor,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              menuBox(
                  icon: Icons.movie_filter_outlined,
                  onPressed: () => goToPage(UploadCatogories.movies, context)),
              menuBox(
                  icon: Icons.tv,
                  onPressed: () => goToPage(UploadCatogories.movies, context)),
              menuBox(
                  icon: FontAwesomeIcons.book,
                  onPressed: () => goToPage(UploadCatogories.movies, context))
            ],
          ),
        ),
      ));
}

Widget menuBox({required IconData icon, required Function onPressed}) {
  return Padding(
    padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
    child: Container(
      height: 204.h,
      width: 304.h,
      color: CommonColors.commonGreenColor,
      child: OutlinedButton(
        onPressed: () => onPressed(),
        child: Center(
            child: Icon(icon,
                color: CommonColors.commonWhiteColor,
                size: AppFontSizes.homePageIconFontSize.h)),
      ),
    ),
  );
}
