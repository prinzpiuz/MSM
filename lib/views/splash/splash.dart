// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:msm/constants/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: CommonColors.commonGreenColor,
      ),
    );
  }
}
