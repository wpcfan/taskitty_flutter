import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  TZDateTime toTZDateTime() {
    return TZDateTime.from(this, local);
  }

  String get formatted {
    return DateFormat.yMMMEd(Platform.localeName).format(this);
  }

  String format({String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern, Platform.localeName).format(this);
  }
}
