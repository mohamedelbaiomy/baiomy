import 'package:flutter/material.dart';

InputDecoration inputDecoration(
  String hintText,
  ThemeData theme, {
  Widget? suffixIcon,
  bool isOutlined = false,
  String? helperText,
}) => isOutlined
    ? InputDecoration(
        hintText: hintText,
        helperText: helperText,
        hintStyle: .new(color: theme.shadowColor),
        helperStyle: .new(color: theme.shadowColor, fontSize: 12),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const .new(color: Colors.red, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: .new(color: theme.shadowColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const .new(color: Colors.red),
        ),
        suffixIcon: suffixIcon,
      )
    : InputDecoration(
        hintText: hintText,
        helperText: helperText,
        hintStyle: .new(color: theme.shadowColor),
        helperStyle: .new(color: theme.shadowColor, fontSize: 12),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: .new(color: Colors.red, width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: .new(color: theme.primaryColor, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: .new(color: theme.shadowColor),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: .new(color: Colors.red),
        ),
        suffixIcon: suffixIcon,
      );
