import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Iterable<Widget> insertDivider(Iterable<Widget> ls) sync* {
  var it = ls.iterator;

  var zero = true;

  while (true) {
    if (zero) {
      zero = false;

      if (it.moveNext())
        yield it.current;
      else
        break;
    }

    if (it.moveNext()) {
      yield VerticalDivider();
      yield it.current;
    } else
      break;
  }
}
