import 'package:flutter_bloc/flutter_bloc.dart';

import 'notification_events.dart';
import 'notification_states.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationState()) {
    on<NotificationReceived>(
        (event, emit) => _mapNotificationReceivedEventToState(event, emit));
  }

  void _mapNotificationReceivedEventToState(
      NotificationReceived event, Emitter<NotificationState> emit) async {
    final notification = event.notification;

    emit(NotificationState(
        notifications: [notification, ...state.notifications]));
  }
}
