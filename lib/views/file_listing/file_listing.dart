// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:msm/common_widgets.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/providers/app_provider.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/ui_components/floating_action_button/fab.dart';
import 'package:msm/ui_components/loading/loading_overlay.dart';
import 'package:msm/ui_components/text/text.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/utils.dart';
import 'package:msm/utils/commands/command_executer.dart';
import 'package:msm/utils/file_manager.dart';
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
    return Consumer<FileListingState>(
      builder: (context, fileListState, child) {
        return handleBackButton(
          context: context,
          child: LoadingOverlay(
            child: _buildFileList(context, _searchController, fileListState),
          ),
        );
      },
    );
  }
}

Widget _buildFileList(BuildContext context, TextEditingController searchController,
    FileListingState listingState) {
  return Scaffold(
    key: const Key('fileListingScaffold'),
    appBar: _buildAppBar(context, searchController, listingState),
    backgroundColor: CommonColors.commonWhiteColor,
    resizeToAvoidBottomInset: false,
    floatingActionButton: floatingActionButton(listingState),
    body: _buildBody(context, listingState),
  );
}

PreferredSizeWidget _buildAppBar(BuildContext context, TextEditingController searchController,
    FileListingState listingState) {
  if (listingState.isInSearchMode) {
    return searchBar(searchController: searchController, listingState: listingState);
  }
  return commonAppBar(
    text: Pages.fileList.toTitle,
    backroute: listingState.firstPage ? Pages.home.toPath : "",
    actions: [
      actionIconButton(
        icon: Icons.delete_outline_rounded,
        onTap: () => deleteSelected(listingState),
      ),
      actionIconButton(
        icon: Icons.clear_all,
        onTap: () => listingState.clearSelection,
      ),
      actionIconButton(
        icon: Icons.search,
        onTap: () => listingState.setSearchMode = true,
      ),
      commonPopUpMenu(
        onSelected: (selectedMenu) {
          selectedMenu.applyFilter(listingState);
        },
        menuListValues: FileListPopMenu.values,
        size: AppFontSizes.appBarIconSize,
      ),
    ],
    context: context,
    fileListState: listingState,
  );
}

Widget _buildBody(BuildContext context, FileListingState listingState) {
  return listings(context, listingState);
}

Widget actionIconButton({
  required IconData icon,
  required VoidCallback onTap,
  double size = AppFontSizes.appBarIconSize,
}) {
  return IconButton(
    onPressed: onTap,
    icon: Icon(
      icon,
      color: CommonColors.commonBlackColor,
      size: size.sp,
    ),
  );
}

Widget floatingActionButton(FileListingState fileListingState) {
  return ExpandableFab(
    fileListingState: fileListingState,
    distance: 112.0,
    children: [
      ActionButton(
        onPressed: () => FileSorting.date.sort(),
        icon: const Icon(Icons.date_range_outlined),
      ),
      ActionButton(
        onPressed: () => FileSorting.size.sort(),
        icon: const Icon(FontAwesomeIcons.database),
      ),
      ActionButton(
        onPressed: () => FileSorting.name.sort(),
        icon: const Icon(FontAwesomeIcons.arrowDownAZ),
      ),
    ],
  );
}

Widget listings(BuildContext context, FileListingState listingState) {
  final appService = context.select<AppService, AppService>((value) => value);
  final bool isConnected = appService.connectionState;

  if (!isConnected) {
    return _buildDisconnectedView(appService);
  }

  if (listingState.isInSearchMode) {
    return _buildSearchView(listingState);
  }

  if (listingState.filterApplied) {
    return _buildFilterView(listingState);
  }

  return _buildFileListFutureView(appService, listingState);
}

Widget _buildDisconnectedView(AppService appService) {
  return Center(child: serverNotConnected(appService, text: false));
}

Widget _buildSearchView(FileListingState listingState) {
  final filteredList = filterBasedOnSearchText(listingState);
  return fileListView(
    fileOrDirectoryList: filteredList,
    listingState: listingState,
  );
}

Widget _buildFilterView(FileListingState listingState) {
  return fileListView(
    fileOrDirectoryList: listingState.currentList,
    listingState: listingState,
  );
}

Widget _buildFileListFutureView(
    AppService appService, FileListingState listingState) {
  final CommandExecuter commandExecuter = appService.commandExecuter;
  final Future<List<FileOrDirectory>?> fileListFuture =
      commandExecuter.listAllRemoteDirectories(path: listingState.nextPage);

  return FutureBuilder<List<FileOrDirectory>?>(
    future: fileListFuture,
    builder: (context, AsyncSnapshot<List<FileOrDirectory>?> snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasData && snapshot.data != null) {
          return _handleDataLoaded(snapshot.data!, listingState);
        } else if (snapshot.hasError) {
          return _handleError(snapshot.error, appService);
        }
      }
      return _buildLoadingView();
    },
  );
}

Widget _handleDataLoaded(
    List<FileOrDirectory> data, FileListingState listingState) {
  if (data.isEmpty) {
    return _buildNoFilesView();
  }

  // Update state with the loaded data
  listingState.originalList = data;
  listingState.currentList = data;

  return listingState.isLoading
      ? _buildLoadingView()
      : fileListView(
          fileOrDirectoryList: data,
          listingState: listingState,
        );
}

Widget _handleError(Object? error, AppService appService) {
  // Log the error for debugging
  debugPrint('Error loading file list: $error');

  // Show user-friendly error message
  String errorMessage = 'Failed to load files. Please try again.';
  if (error is Exception) {
    // Handle specific exceptions if needed
    errorMessage = 'An error occurred while loading files.';
  }

  // Optionally, show a snackbar or dialog
  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        serverNotConnected(appService, text: false),
        const SizedBox(height: 16),
        AppText.centerSingleLineText(
          errorMessage,
          style: AppTextStyles.medium(
            CommonColors.commonBlackColor,
            AppFontSizes.noFilesFontSize.sp,
          ),
        ),
      ],
    ),
  );
}

Widget _buildLoadingView() {
  return Center(child: commonCircularProgressIndicator);
}

Widget _buildNoFilesView() {
  return Center(
    child: AppText.centerSingleLineText(
      "No Files",
      style: AppTextStyles.medium(
        CommonColors.commonBlackColor,
        AppFontSizes.noFilesFontSize.sp,
      ),
    ),
  );
}

Widget fileListView({
  required List<FileOrDirectory>? fileOrDirectoryList,
  required FileListingState listingState,
}) {
  listingState.turnOffFilter;
  return ListView.builder(
    itemCount: fileOrDirectoryList!.length,
    itemBuilder: (context, i) {
      final fileOrDir = fileOrDirectoryList[i];
      return FileTile(
        key: ValueKey(fileOrDir.fullPath), // Add key for performance
        fileOrDirectory: fileOrDir,
        selected: listingState.selectedList.contains(fileOrDir),
      );
    },
  );
}
