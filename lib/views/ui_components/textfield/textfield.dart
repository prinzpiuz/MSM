// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:msm/constants/colors.dart';
import 'package:msm/views/ui_components/textfield/textfield_decoration.dart';

class AppTextField {
  static TextField simpleTextField(
      {required TextEditingController controller}) {
    return TextField(
        controller: controller,
        decoration: AppTextFieldDecoratoion.simpleTextFieldDecoration());
  }

  static Padding commonTextFeild(
      {required FormFieldSetter onsaved,
      required TextInputType keyboardType,
      required String labelText,
      required String hintText,
      FormFieldValidator<String>? validator,
      IconData? iconData,
      int? maxLength,
      String? errorText,
      String? initialValue,
      bool obscureText = false}) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, left: 18.w, right: 18.w),
      child: TextFormField(
          validator: validator,
          onSaved: onsaved,
          keyboardType: keyboardType,
          maxLength: maxLength,
          initialValue: initialValue,
          obscureText: obscureText,
          obscuringCharacter: "*",
          decoration: InputDecoration(
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
