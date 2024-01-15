import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {}

class AnalyticsEventAppStarted extends AnalyticsEvent {
  @override
  List<Object> get props => [];
}

class AnalyticsEventPageView extends AnalyticsEvent {
  AnalyticsEventPageView({
    required this.screenName,
    required this.screenClassOverride,
  });

  final String screenName;
  final String screenClassOverride;

  @override
  List<Object> get props => [screenName, screenClassOverride];
}

class AnalyticsEventLogEvent extends AnalyticsEvent {
  AnalyticsEventLogEvent({
    required this.eventName,
    required this.eventParameters,
  });

  final String eventName;
  final Map<String, dynamic> eventParameters;

  @override
  List<Object> get props => [eventName, eventParameters];
}

class AnalyticsEventSetUserId extends AnalyticsEvent {
  AnalyticsEventSetUserId({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

class AnalyticsEventLogin extends AnalyticsEvent {
  AnalyticsEventLogin({required this.method});

  final String method;

  @override
  List<Object> get props => [method];
}

class AnalyticsEventLogout extends AnalyticsEvent {
  @override
  List<Object> get props => [];
}
