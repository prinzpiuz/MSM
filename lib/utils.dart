// Flutter imports:
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

import 'package:msm/providers/file_listing_provider.dart';
import 'package:msm/providers/upload_provider.dart';
// Project imports:

bool get appENV {
  bool isProd = const bool.fromEnvironment('dart.vm.product');
  return isProd;
}

PopScope handleBackButton({
  String? backRoute,
  required Widget child,
  required BuildContext context,
  UploadState? uploadState,
  FileListingState? fileListState,
}) {
  // to handle the backroutes of the app
  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (bool didPop, dynamic result) async {
      if (didPop && backRoute != null) {
        handleBack(context, uploadState, fileListState, backRoute);
      }
    },
    child: child,
  );
}

void handleBack(BuildContext context, UploadState? uploadState,
    FileListingState? fileListState, String backRoute) {
  if (uploadState != null) {
    uploadState.commonCalls;
  }
  if (fileListState != null) {
    fileListState.popPath;
    fileListState.clearSelection;
    fileListState.setNextPage = fileListState.lastPage;
  }
  if (backRoute.isNotEmpty) {
    GoRouter.of(context).go(backRoute);
  }
}

void hideKeyboard(BuildContext ctx) {
  try {
    FocusManager.instance.primaryFocus?.unfocus();
  } catch (_) {}
}

String fileNameFromPath(String path) {
  return path.split('/').last.toString();
}

String decodeOutput(Uint8List output) {
  return utf8.decode(output);
}
