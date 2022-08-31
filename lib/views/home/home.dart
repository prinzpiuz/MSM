// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/views/home/home_common_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => const HomePageScaffold();
}

class HomePageScaffold extends StatefulWidget {
  const HomePageScaffold({Key? key}) : super(key: key);

  @override
  State<HomePageScaffold> createState() => _HomePageScaffoldState();
}

class _HomePageScaffoldState extends State<HomePageScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.all(16.h),
              crossAxisCount: 2,
              children: List.generate(4, (index) {
                return Container(
                  color: CommonColors.commonGreenColor,
                  margin: EdgeInsets.all(8.h),
                  child: OutlinedButton(
                      onPressed: () => {print(index)},
                      child: Center(
                        child: HomeCommonWidgets.homeIconList[index],
                      )),
                );
              }),
            ),
            Stack(children: <Widget>[
              SizedBox(
                width: 200.w,
                height: 200.w,
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.0, end: .7),
                  duration: const Duration(milliseconds: 3500),
                  builder: (context, double value, _) =>
                      CircularProgressIndicator(
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
                child: HomeCommonWidgets.serverDetails(),
              )
            ]),
          ],
        ));
  }
}
