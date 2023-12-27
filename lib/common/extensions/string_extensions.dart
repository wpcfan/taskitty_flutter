import 'package:flutter/material.dart';

extension StringExtensions on String {
  Widget toChip({
    required VoidCallback onPressed,
  }) {
    return Chip(
      label: Text(this),
      onDeleted: onPressed,
    );
  }
}
