// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/font_sizes.dart';
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

// TODO need to consider the case of custom folders
// TODO also need to find an algorithm to handle the grids size when custom folders come

Widget uploadMenu(BuildContext context) {
  return Scaffold(
      backgroundColor: CommonColors.commonWhiteColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.h),
          child: StaggeredGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 4.h,
            crossAxisSpacing: 4.h,
            children: tiles(context),
          ),
        ),
      ));
}

Widget menuBox(
    {required IconData icon,
    required Function onPressed,
    required double iconSize}) {
  return Container(
    color: CommonColors.commonGreenColor,
    child: OutlinedButton(
      onPressed: () => onPressed(),
      child: Center(
          child:
              Icon(icon, color: CommonColors.commonWhiteColor, size: iconSize)),
    ),
  );
}

List<StaggeredGridTile> tiles(BuildContext context) {
  return [
    StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 2,
      child: menuBox(
          icon: Icons.movie_filter_outlined,
          onPressed: () => goToPage(UploadCatogories.movies, context),
          iconSize: AppFontSizes.homePageIconFontSize.h),
    ),
    StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 3,
      child: menuBox(
          icon: Icons.tv,
          onPressed: () => goToPage(UploadCatogories.tvShows, context),
          iconSize: AppFontSizes.homePageIconFontSize.h),
    ),
    StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: menuBox(
          icon: FontAwesomeIcons.book,
          onPressed: () => goToPage(UploadCatogories.books, context),
          iconSize: AppFontSizes.smallTileIconSize.h),
    ),
    StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: menuBox(
          icon: FontAwesomeIcons.image,
          onPressed: () => goToPage(UploadCatogories.pictures, context),
          iconSize: AppFontSizes.smallTileIconSize.h),
    )
  ];
}
