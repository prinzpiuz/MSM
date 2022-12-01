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
  }
}
