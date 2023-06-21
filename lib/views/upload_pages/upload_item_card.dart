// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/models/file_upload.dart';

class UploadItemCard extends StatefulWidget {
  final FileOrDirectory data;
  final FileUploadData fileUploadData;
  const UploadItemCard(
      {Key? key, required this.data, required this.fileUploadData})
      : super(key: key);

  @override
  UploadItemCardState createState() => UploadItemCardState();
}

class UploadItemCardState extends State<UploadItemCard> {
  bool selected = false;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 15.h,
      right: 50.w,
      child: widget.data.isFile
          ? Container(
              width: 60.w,
              height: 60.h,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: CommonColors.commonGreenColor),
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      selected = !selected;
                      widget.fileUploadData.addOrRemove(widget.data);
                    });
                  },
                  icon: Icon(
                    selected ? Icons.remove : Icons.add,
                    color: CommonColors.commonWhiteColor,
                    size: 30.h,
                  )),
            )
          : Icon(
              Icons.folder,
              color: CommonColors.commonGreyColor,
              size: 40.h,
            ),
    );
  }
}
