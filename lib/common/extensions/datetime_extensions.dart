import 'package:device_calendar/device_calendar.dart';

extension DateTimeExtensions on DateTime {
  TZDateTime toTZDateTime() {
    return TZDateTime.from(this, local);
  }
}
