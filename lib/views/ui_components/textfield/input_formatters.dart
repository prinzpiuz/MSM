import 'package:flutter/services.dart';

class IpAddressInputFormatter extends TextInputFormatter {
  //for reference look here
  //https://stackoverflow.com/questions/69230821/how-to-make-a-textinputformatter-mask-for-ipaddress-in-flutter

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    int dotCounter = 0;
    var buffer = StringBuffer();
    String ipField = "";

    for (int i = 0; i < text.length; i++) {
      if (dotCounter < 4) {
        if (text[i] != ".") {
          ipField += text[i];
          if (ipField.length < 3) {
            buffer.write(text[i]);
          } else if (ipField.length == 3) {
            if (int.parse(ipField) <= 255) {
              buffer.write(text[i]);
            } else {
              if (dotCounter < 3) {
                buffer.write(".");
                dotCounter++;
                buffer.write(text[i]);
                ipField = text[i];
              }
            }
          } else if (ipField.length == 4) {
            if (dotCounter < 3) {
              buffer.write(".");
              dotCounter++;
              buffer.write(text[i]);
              ipField = text[i];
            }
          }
        } else {
          if (dotCounter < 3) {
            buffer.write(".");
            dotCounter++;
            ipField = "";
          }
        }
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  //for reference look here
  //https://stackoverflow.com/a/49239762/8368092
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class MACAddressInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    int colonCounter = 0;
    var buffer = StringBuffer();
    String macField = "";

    for (int i = 0; i < text.length; i++) {
      if (colonCounter < 6 && buffer.toString().length < 17) {
        if (text[i] != ":") {
          macField += text[i];
          if (macField.length < 3) {
            buffer.write(text[i]);
          } else if (macField.length == 3) {
            buffer.write(":");
            colonCounter++;
            buffer.write(text[i]);
            macField = "";
          }
        } else {
          if (colonCounter < 6) {
            buffer.write(":");
            colonCounter++;
            macField = "";
          }
        }
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
