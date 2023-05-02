// Project imports:
import 'package:msm/constants/constants.dart';

String? validateServerName(String? value) {
  if (value!.isEmpty) {
    return "Name can't be empty";
  }
  if (value.length > 15) {
    return "Name should be less 15 chars";
  }
  return null;
}

String? validatePortNumber(String? value) {
  if (value!.isEmpty) {
    return "Port can't be empty";
  }
  if (value.contains(RegExp(AppConstants.alphaAndSpecialChars))) {
    return "Only numbers can be used";
  }
  if (value.length > 5 || int.parse(value) > 65535) {
    return "Length should be < 5 and Value should less than 65535";
  }
  return null;
}

String? valueNeeded(String? value) {
  if (value!.isEmpty) {
    return "Value can't be empty";
  }
  return null;
}

String? macValidation(String? value) {
  if (value!.length < 17 && value.length > 1) {
    return "MAC address length will be 17 including :";
  }
  return null;
}

String? validateEmail(String? value) {
  if (RegExp(AppConstants.emailvalidationRegex).hasMatch(value!)) {
    return null;
  }
  return "Invalid Email Address";
}
