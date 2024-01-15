import 'package:equatable/equatable.dart';

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.isAnalyticsEnabled = true,
    this.isAppStarted = false,
    this.currentScreenName = '',
    this.currentEventName = '',
  });

  final bool isAnalyticsEnabled;
  final bool isAppStarted;
  final String currentScreenName;
  final String currentEventName;

  @override
  List<Object> get props => [
        isAnalyticsEnabled,
        isAppStarted,
        currentScreenName,
        currentEventName,
      ];

  AnalyticsState copyWith({
    bool? isAnalyticsEnabled,
    bool? isAppStarted,
    String? currentScreenName,
    String? currentEventName,
  }) {
    return AnalyticsState(
      isAnalyticsEnabled: isAnalyticsEnabled ?? this.isAnalyticsEnabled,
      isAppStarted: isAppStarted ?? this.isAppStarted,
      currentScreenName: currentScreenName ?? this.currentScreenName,
      currentEventName: currentEventName ?? this.currentEventName,
    );
  }

  @override
  String toString() {
    return 'AnalyticsState{isAnalyticsEnabled: $isAnalyticsEnabled, isAppStarted: $isAppStarted, currentScreenName: $currentScreenName, currentEventName: $currentEventName}';
  }
}
