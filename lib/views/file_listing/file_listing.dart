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
import 'package:msm/context_keys.dart';
import 'package:msm/models/commands/command_executer.dart';
import 'package:msm/models/file_manager.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/ui_components/floating_action_button/fab.dart';
import 'package:msm/ui_components/loading/loading_overlay.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/views/file_listing/file_listing_utils.dart';
import 'package:msm/views/file_listing/file_tile.dart';

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
        child: LoadingOverlay(
            child: fileList(context, _searchController, fileListState)));
  }
}

Widget fileList(BuildContext context, TextEditingController searchController,
    FileListingState listingState) {
  return Scaffold(
    key: ContextKeys.fileListingPageKey,
    appBar: listingState.isInSearchMode
        ? searchBar(
            searchController: searchController, listingState: listingState)
        : commonAppBar(
            text: Pages.fileList.toTitle,
            backroute: listingState.firstPage ? Pages.home.toPath : "",
            actions: [
              actionIconButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: () => deletedSelected(listingState)),
              actionIconButton(
                  icon: Icons.clear_all,
                  onTap: () => listingState.clearSelection),
              actionIconButton(
                  icon: Icons.search,
                  onTap: () => listingState.setSearchMode = true),
              commonPopUpMenu(
                  onSelected: (selectedMenu) {
                    selectedMenu.applyFilter(listingState);
                  },
                  menuListValues: FileListPopMenu.values,
                  size: AppFontSizes.appBarIconSize)
            ],
            context: context,
            fileListState: listingState),
    backgroundColor: CommonColors.commonWhiteColor,
    floatingActionButton: floatingActionButton(),
    body: listings(context, listingState),
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

Widget listings(BuildContext context, FileListingState listingState) {
  final AppService appService = Provider.of<AppService>(context);
  final bool connected = appService.connectionState;
  CommandExecuter commandExecuter = appService.commandExecuter;
  final Future<List<FileOrDirectory>?>? fileListFuture =
      commandExecuter.listAllRemoteDirectories(path: listingState.nextPage);
  if (connected) {
    if (listingState.isInSearchMode) {
      return fileListView(
          fileOrDirectoryList: filterBasedOnSearchText(listingState),
          listingState: listingState);
    }
    if (listingState.filterApplied) {
      return fileListView(
          fileOrDirectoryList: listingState.currentList,
          listingState: listingState);
    }
    return FutureBuilder<List<FileOrDirectory>?>(
        future: fileListFuture,
        builder: (context, AsyncSnapshot<List<FileOrDirectory>?> snapshot) {
          print("calling");
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            if (snapshot.data!.isNotEmpty) {
              List<FileOrDirectory>? fileOrDirectoryList = listingState
                  .originalList = listingState.currentList = snapshot.data!;
              return fileListView(
                  fileOrDirectoryList: fileOrDirectoryList,
                  listingState: listingState);
            }
            return Center(
              child: AppText.centerSingleLineText("No Files",
                  style: AppTextStyles.medium(CommonColors.commonBlackColor,
                      AppFontSizes.noFilesFontSize.sp)),
            );
          } else if (snapshot.hasError) {
            return Center(child: serverNotConnected(appService, text: false));
          } else {
            return commonCircularProgressIndicator;
          }
        });
  } else {
    return Center(child: serverNotConnected(appService, text: false));
  }
}

Widget fileListView(
    {required List<FileOrDirectory>? fileOrDirectoryList,
    required FileListingState listingState}) {
  listingState.turnOffFilter;
  return ListView.separated(
      separatorBuilder: (context, index) => commonDivider,
      itemCount: fileOrDirectoryList!.length,
      itemBuilder: (context, i) {
        return FileTile(
            fileOrDirectory: fileOrDirectoryList[i],
            selected:
                listingState.selectedList.contains(fileOrDirectoryList[i]));
      });
}
