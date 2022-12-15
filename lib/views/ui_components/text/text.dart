// Flutter imports:
import 'package:flutter/material.dart' show Text, TextAlign, TextOverflow;
import 'package:flutter/material.dart' show TextStyle;

class AppText {
  static Text singleLineText(String text,
      {TextAlign textAlign = TextAlign.left,
      TextStyle? style,
      TextOverflow overflow = TextOverflow.ellipsis}) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: 1,
      style: style,
      overflow: overflow,
    );
  }

  static Text centerSingleLineText(String text,
      {TextStyle? style, TextOverflow overflow = TextOverflow.ellipsis}) {
    return singleLineText(text,
        textAlign: TextAlign.center, style: style, overflow: overflow);
  }

  static Text text(String str,
      {TextAlign textAlign = TextAlign.left,
      int? maxLines,
      TextStyle? style,
      TextOverflow overflow = TextOverflow.visible}) {
    return Text(
      str,
      overflow: overflow,
      textAlign: textAlign,
      maxLines: maxLines,
      style: style,
    );
  }

  static Text centerText(String str,
      {int? maxLines,
      TextStyle? style,
      TextOverflow overflow = TextOverflow.visible}) {
    return text(str,
        textAlign: TextAlign.center,
        maxLines: maxLines,
        style: style,
        overflow: overflow);
  }

  AppText._();
}
