import 'package:flutter/material.dart';
import 'package:msm/views/ui_components/textfield/textfield_decoration.dart';

class AppTextField {
  static TextField simpleTextField(
      {required TextEditingController controller}) {
    return TextField(
        controller: controller,
        decoration: AppTextFieldDecoratoion.simpleTextFieldDecoration());
  }

  AppTextField._();
}
