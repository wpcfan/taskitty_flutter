import 'package:equatable/equatable.dart';

import '../models/models.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
}

class NotificationReceived extends NotificationEvent {
  final ReceivedNotification notification;

  const NotificationReceived(this.notification);

  @override
  List<Object> get props => [notification];
}

class NotificationSelected extends NotificationEvent {
  final ReceivedNotification notification;

  const NotificationSelected(this.notification);

  @override
  List<Object> get props => [notification];
}

class NotificationSelectedAction extends NotificationEvent {
  final ReceivedNotification notification;

  const NotificationSelectedAction(this.notification);

  @override
  List<Object> get props => [notification];
}
