import 'package:equatable/equatable.dart';

import '../models/models.dart';

class NotificationState extends Equatable {
  final List<ReceivedNotification> notifications;
  const NotificationState({
    this.notifications = const <ReceivedNotification>[],
  });

  @override
  List<Object> get props => [notifications];
}
