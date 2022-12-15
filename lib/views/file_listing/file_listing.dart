import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:msm/common_utils.dart';
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/font_sizes.dart';
import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/router/router_utils.dart';
import 'package:msm/views/file_listing/fab.dart';
import 'package:msm/views/file_listing/file_listing_utils.dart';
import 'package:provider/provider.dart';

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
    return fileList(context, _searchController, fileListState);
  }
}

Widget fileList(BuildContext context, TextEditingController searchController,
    FileListingState listingState) {
  return Scaffold(
    appBar: listingState.isInSearchMode
        ? searchBar(
            searchController: searchController, listingState: listingState)
        : commonAppBar(
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
    body: listings(),
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

Widget listings() {
  return ListView.builder(
    // Must have an item count equal to the number of items!
    itemCount: 1,
    // A callback that will return a widget.
    itemBuilder: (context, i) {
      // In our case, a DogCard for each doggo.
      return const SizedBox();
    },
  );
}
