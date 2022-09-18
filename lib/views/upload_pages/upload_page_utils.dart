// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:msm/router/router_utils.dart';

enum UploadCatogories { movies, tvShows, books }

void goToPage(UploadCatogories catogories, BuildContext context) {
  switch (catogories) {
    case UploadCatogories.movies:
      return GoRouter.of(context).go(Pages.commonUpload.toPath);
    case UploadCatogories.tvShows:
      // TODO: Handle this case.
      break;
    case UploadCatogories.books:
      // TODO: Handle this case.
      break;
  }
}
