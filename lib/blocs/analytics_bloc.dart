import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'analytics_events.dart';
import 'analytics_states.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final FirebaseAnalytics analytics;

  AnalyticsBloc({
    required this.analytics,
  }) : super(const AnalyticsState()) {
    on<AnalyticsEventAppStarted>(_onAppStarted);
    on<AnalyticsEventPageView>(_onPageView);
    on<AnalyticsEventLogEvent>(_onLogEvent);
  }

  Future<void> _onAppStarted(
    AnalyticsEventAppStarted event,
    Emitter<AnalyticsState> emit,
  ) async {
    await analytics.logAppOpen();
    emit(state.copyWith(isAppStarted: true));
  }

  Future<void> _onPageView(
    AnalyticsEventPageView event,
    Emitter<AnalyticsState> emit,
  ) async {
    await analytics.setCurrentScreen(
      screenName: event.screenName,
      screenClassOverride: event.screenClassOverride,
    );
    emit(state.copyWith(currentScreenName: event.screenName));
  }

  Future<void> _onLogEvent(
    AnalyticsEventLogEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    await analytics.logEvent(
      name: event.eventName,
      parameters: event.eventParameters,
    );
    emit(state.copyWith(currentEventName: event.eventName));
  }
}
