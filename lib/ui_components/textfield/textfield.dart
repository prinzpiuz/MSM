// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/constants/constants.dart';
import 'package:msm/ui_components/text/textstyles.dart';
import 'package:msm/ui_components/textfield/textfield_decoration.dart';

class AppTextField {
  static TextField simpleTextField(
      {required TextEditingController controller, FormFieldSetter? onChanged}) {
    return TextField(
        // controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.regular(
            CommonColors.commonBlackColor, AppFontSizes.fileSearchFontSize.sp),
        decoration: AppTextFieldDecoratoion.simpleTextFieldDecoration());
  }

  static Widget commonTextFeild(
      {required TextInputType keyboardType,
      required String labelText,
      required String hintText,
      FormFieldSetter? onsaved,
      FormFieldSetter? onChanged,
      List<TextInputFormatter>? inputFormatters,
      FormFieldValidator<String>? validator,
      IconData? iconData,
      int? maxLength,
      String? errorText,
      String? initialValue,
      bool obscureText = false,
      bool suffix = false,
      bool disableLeftRightPadding = false,
      void Function()? onSuffixIconPressed}) {
    double leftRightPadding = disableLeftRightPadding ? 0 : 18.w;
    return Padding(
      padding: EdgeInsets.only(
          top: 20.h, left: leftRightPadding, right: leftRightPadding),
      child: TextFormField(
          validator: validator,
          onSaved: onsaved,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLength: maxLength,
          initialValue: initialValue,
          obscureText: obscureText,
          obscuringCharacter: "*",
          inputFormatters: inputFormatters,
          style: const TextStyle(color: CommonColors.commonBlackColor),
          decoration: InputDecoration(
            suffix: suffix
                ? InkWell(
                    onTap: onSuffixIconPressed,
                    child: Icon(Icons.clear, size: 14.sp),
                  )
                : null,
            contentPadding: EdgeInsets.all(20.h),
            labelText: labelText,
            hintText: hintText,
            errorText: errorText,
            hintTextDirection: TextDirection.rtl,
            labelStyle: const TextStyle(color: TextFormColors.inputTextColor),
            hintStyle:
                const TextStyle(color: TextFormColors.inputHintTextColor),
            errorStyle:
                const TextStyle(color: TextFormColors.inputErrorTextColor),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: CommonColors.commonBlackColor,
              ),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: CommonColors.commonBlackColor,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: TextFormColors.inputErrorTextColor,
              ),
            ),
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: CommonColors.commonBlackColor)),
          )),
    );
  }

  AppTextField._();
}
