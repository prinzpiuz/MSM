// Flutter imports:
import 'package:flutter/material.dart' show TextStyle, FontWeight, Color;

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:msm/constants/colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle inputTextStyle() {
    return medium(
      TextFormColors.inputTextColor,
      14,
    );
  }

  static TextStyle inputHintTextStyle() {
    return medium(
      TextFormColors.inputHintTextColor,
      14,
    );
  }

  static TextStyle inputHelperTextStyle() {
    return medium(
      TextFormColors.inputHelperTextColor,
      11,
    );
  }

  static TextStyle inputErrorTextStyle() {
    return medium(TextFormColors.inputErrorTextColor, 11, height: 2);
  }

  // static TextStyle buttonTextStyle() {
  //   return bold(ButtonColors.buttonTextColor, 14);
  // }

  // static TextStyle secondaryButtonTextStyle() {
  //   return bold(ButtonColors.secondaryButtonTextColor, 14);
  // }

  static TextStyle extraBold(Color textColor, double fontSize,
      {double? letterSpacing, double? height}) {
    return GoogleFonts.openSans(
      textStyle: TextStyle(
          color: textColor,
          fontSize: fontSize.sp,
          letterSpacing: letterSpacing,
          height: height?.sp,
          fontWeight: FontWeight.w800),
    );
  }

  static TextStyle bold(Color textColor, double fontSize,
      {double? letterSpacing, double? height}) {
    return GoogleFonts.openSans(
      textStyle: TextStyle(
          color: textColor,
          fontSize: fontSize.sp,
          letterSpacing: letterSpacing,
          height: height?.sp,
          fontWeight: FontWeight.w700),
    );
  }

  static TextStyle medium(Color textColor, double fontSize,
      {double? letterSpacing, double? height}) {
    return GoogleFonts.openSans(
      textStyle: TextStyle(
          color: textColor,
          fontSize: fontSize.sp,
          letterSpacing: letterSpacing,
          height: height?.sp,
          fontWeight: FontWeight.w500),
    );
  }

  static TextStyle regular(Color textColor, double fontSize,
      {double? letterSpacing, double? height}) {
    return GoogleFonts.openSans(
      textStyle: TextStyle(
          color: textColor,
          fontSize: fontSize.sp,
          letterSpacing: letterSpacing,
          height: height?.sp,
          fontWeight: FontWeight.w400),
    );
  }

  static TextStyle light(Color textColor, double fontSize,
      {double? letterSpacing, double? height}) {
    return GoogleFonts.openSans(
      textStyle: TextStyle(
          color: textColor,
          fontSize: fontSize.sp,
          letterSpacing: letterSpacing,
          height: height?.sp,
          fontWeight: FontWeight.w300),
    );
  }
}
