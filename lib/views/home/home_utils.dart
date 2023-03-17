// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:msm/router/router_utils.dart';

void goToPage(int index, BuildContext context) {
  switch (index) {
    case 0:
      return GoRouter.of(context).go(Pages.upload.toPath);
    case 1:
      return GoRouter.of(context).go(Pages.systemTools.toPath);
    case 2:
      return GoRouter.of(context).go(Pages.fileList.toPath);
    case 3:
      return GoRouter.of(context).go(Pages.settings.toPath);
  }
}

void notificationsPage(BuildContext context, DragUpdateDetails details) {
  int sensitivity = 8;
  if (details.delta.dx > sensitivity) {
    GoRouter.of(context).go(Pages.notifications.toPath);
  }
}
