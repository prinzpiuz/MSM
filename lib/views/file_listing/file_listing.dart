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
import 'package:msm/models/commands/command_executer.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/ui_components/floating_action_button/fab.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/views/file_listing/file_listing_utils.dart';

//todo this is supposed to be removed when server file model will be created
const List fileListItems = [
  {
    "name": "air force one",
    "size": "1GB",
    "date": "08-07-2022",
    "category": FileCategory.movieOrTv,
    "extention": "MKV"
  },
  {
    "name": "aliens",
    "size": "32kb",
    "date": "08-06-2022",
    "category": FileCategory.subtitle,
    "extention": "SRT"
  },
  {
    "name": "stranger things",
    "size": "32GB",
    "date": "07-12-2020",
    "category": FileCategory.movieOrTv,
    "extention": "MKV"
  },
  {
    "name": "sapiens",
    "size": "30MB",
    "date": "08-07-2022",
    "category": FileCategory.book,
    "extention": "EPUB"
  },
  {
    "name": "Image00231",
    "size": "1GB",
    "date": "08-07-2022",
    "category": FileCategory.image,
    "extention": "JPEG"
  }
];

//todo fileinfo option in individual list menu

class FileListing extends StatefulWidget {
  const FileListing({super.key});

  @override
  State<FileListing> createState() => _FileListingState();
}

class _FileListingState extends State<FileListing> {
  late TextEditingController _searchController;

  @override
  void initState() {
    _searchController = TextEditingController(text: '');
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FileListingState fileListState = Provider.of<FileListingState>(context);
    return handleBackButton(
        context: context,
        child: fileList(context, _searchController, fileListState));
  }
}

Widget fileList(BuildContext context, TextEditingController searchController,
    FileListingState listingState) {
  return Scaffold(
    appBar: listingState.isInSearchMode
        ? searchBar(
            searchController: searchController, listingState: listingState)
        : commonAppBar(
            text: Pages.fileList.toTitle,
            backroute: Pages.home.toPath,
            actions: [
              actionIconButton(
                  icon: Icons.search,
                  onTap: () => listingState.setSearchMode = true),
              commonPopUpMenu(FileListPopMenu.values)
            ],
            context: context,
          ),
    backgroundColor: CommonColors.commonWhiteColor,
    floatingActionButton: floatingActionButton(),
    body: listings(context),
  );
}

Widget actionIconButton(
    {required IconData icon,
    required void Function() onTap,
    double size = AppFontSizes.appBarIconSize}) {
  return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: CommonColors.commonBlackColor,
        size: size.sp,
      ));
}

Widget floatingActionButton() {
  return ExpandableFab(
    distance: 112.0,
    children: [
      ActionButton(
        onPressed: () => {},
        icon: const Icon(Icons.date_range_outlined),
      ),
      ActionButton(
        onPressed: () => {},
        icon: const Icon(FontAwesomeIcons.database),
      ),
      ActionButton(
        onPressed: () => {},
        icon: const Icon(FontAwesomeIcons.arrowDownAZ),
      ),
    ],
  );
}

Widget listings(BuildContext context) {
  final AppService appService = Provider.of<AppService>(context);
  final bool connected = appService.connectionState;
  CommandExecuter commandExecuter = appService.commandExecuter;
  final Future<List<FileOrDirectory>?>? fileListFuture =
      commandExecuter.listAllRemoteDirectories;
  if (connected) {
    return FutureBuilder<List<FileOrDirectory>?>(
        future: fileListFuture,
        builder: (context, AsyncSnapshot<List<FileOrDirectory>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            if (snapshot.data!.isNotEmpty) {
              return ListView.separated(
                  separatorBuilder: (context, index) => const Divider(
                        color: CommonColors.commonBlackColor,
                      ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    FileOrDirectory fileOrDirectory = snapshot.data![i];
                    return fileTile(
                        leading: fileOrDirectory.category!.categoryIcon,
                        title: fileOrDirectory.name,
                        subtitle: generateSubtitle(fileOrDirectory));
                  });
            }
            return AppText.centerSingleLineText("No Files",
                style:
                    AppTextStyles.medium(CommonColors.commonBlackColor, 25.sp));
          } else if (snapshot.hasError) {
            return serverNotConnected(appService);
          } else {
            return commonCircularProgressIndicator;
          }
        });
  } else {
    return serverNotConnected(appService);
  }
}

//todo need to pass server file opject
Widget fileTile(
    {required Widget leading,
    required String title,
    required String subtitle}) {
  return ListTile(
    onLongPress: (() {
      print("need to implement");
    }),
    dense: true,
    visualDensity: const VisualDensity(horizontal: -4.0, vertical: -2),
    horizontalTitleGap: 20,
    leading: leading,
    title: AppText.singleLineText(title,
        style: AppTextStyles.medium(CommonColors.commonBlackColor, 18.sp)),
    subtitle: AppText.text(subtitle,
        style: AppTextStyles.regular(CommonColors.commonBlackColor, 12.sp)),
    trailing: const Icon(
      Icons.more_vert,
      color: CommonColors.commonBlackColor,
    ),
  );
}
