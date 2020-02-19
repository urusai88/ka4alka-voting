import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class MaxMinInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    try {
      int v = int.parse(newValue.text);

      return newValue.copyWith(text: '${math.min(math.max(1, v), 15)}');
    } on FormatException catch (e) {}

    return newValue;
  }
}
