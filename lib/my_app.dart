import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nested/nested.dart';
import 'package:relative_time/relative_time.dart';

import 'routes/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.notificationAppLaunchDetails,
    required this.flutterLocalNotificationsPlugin,
  });
  final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: buildProviders,
      child: Builder(builder: (context) {
        return MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate, // Add this line
            RelativeTimeLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          routerConfig: goRouter,
          builder: (context, child) {
            EasyLoading.init();
            return FlutterEasyLoading(child: child);
          },
        );
      }),
    );
  }

  List<SingleChildWidget> get buildProviders {
    return [
      RepositoryProvider<FirebaseAuth>(
        create: (context) => FirebaseAuth.instance,
      ),
      RepositoryProvider<FirebaseAnalytics>(
        create: (context) => FirebaseAnalytics.instance,
      ),
      RepositoryProvider<FirebaseFirestore>(
        create: (context) => FirebaseFirestore.instance,
      ),
      RepositoryProvider<DeviceCalendarPlugin>(
        create: (context) => DeviceCalendarPlugin(),
      ),
      RepositoryProvider<FirebaseAnalyticsObserver>(
        create: (context) => FirebaseAnalyticsObserver(
            analytics: context.read<FirebaseAnalytics>()),
      ),
    ];
  }
}
