// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/views/file_listing/file_listing_utils.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class FileTile extends StatefulWidget {
  final FileOrDirectory fileOrDirectory;
  bool selected;
  FileTile({Key? key, required this.fileOrDirectory, required this.selected})
      : super(key: key);

  @override
  FileTileState createState() => FileTileState();
}

class FileTileState extends State<FileTile> {
  @override
  Widget build(BuildContext context) {
    // bool selected = widget.selected;
    FileListingState listingState = Provider.of<FileListingState>(context);
    return ListTile(
      onLongPress: (() {
        setState(() {
          listingState.selectOrRemoveItems(widget.fileOrDirectory);
          widget.selected = !widget.selected;
        });
      }),
      onTap: () {
        if (widget.selected) {
          setState(() {
            widget.selected = !widget.selected;
            listingState.selectOrRemoveItems(widget.fileOrDirectory);
          });
        } else {
          if (!widget.fileOrDirectory.isFile) {
            listingState.setSearchMode = false;
            listingState.clearSearchText;
            listingState.addPath = listingState.setNextPage =
                "${widget.fileOrDirectory.location}/${widget.fileOrDirectory.name}";
          }
        }
      },
      selected: widget.selected,
      dense: true,
      visualDensity: const VisualDensity(horizontal: -4.0, vertical: -2),
      horizontalTitleGap: 20,
      leading: widget.fileOrDirectory.isFile
          ? widget.fileOrDirectory.category!.categoryIcon(widget.selected)
          : leadingIcon(FontAwesomeIcons.folder, widget.selected),
      title: AppText.singleLineText(widget.fileOrDirectory.name,
          style: AppTextStyles.medium(
              widget.selected
                  ? CommonColors.commonGreenColor
                  : CommonColors.commonBlackColor,
              AppFontSizes.fileListTitleFontSize.sp)),
      subtitle: AppText.text(generateSubtitle(widget.fileOrDirectory),
          style: AppTextStyles.regular(
              widget.selected
                  ? CommonColors.commonGreenColor
                  : CommonColors.commonBlackColor,
              AppFontSizes.fileListSubtitleFontSize.sp)),
      trailing: const Icon(
        Icons.more_vert,
        color: CommonColors.commonBlackColor,
      ),
    );
  }
}
