import 'dart:math';

import 'package:flutter/material.dart';
import 'package:taskitty_flutter/common/extensions/extensions.dart';

extension StringExtensions on String {
  Widget toChip({
    required VoidCallback onPressed,
  }) {
    return Chip(
      // random color from primary swatch
      color: MaterialStateColor.resolveWith(
        (states) => Colors.primaries[Random().nextInt(Colors.primaries.length)],
      ),
      label: Text(this),
      labelStyle: const TextStyle(
        color: Colors.white,
      ),
    ).inkWell(
      onTap: onPressed,
    );
  }
}
