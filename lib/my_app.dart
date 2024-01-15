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

import 'auth/auth.dart';
import 'home/home.dart';
import 'todos/todos.dart';

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
        final auth = context.read<FirebaseAuth>();
        final firestore = context.read<FirebaseFirestore>();
        final analytics = context.read<FirebaseAnalytics>();
        final observer = context.read<FirebaseAnalyticsObserver>();
        final deviceCalendarPlugin = context.read<DeviceCalendarPlugin>();

        final homePage = HomePage(
          title: 'Firebase Analytics Demo',
          analytics: analytics,
          observer: observer,
          notificationAppLaunchDetails: notificationAppLaunchDetails,
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        );
        final loginPage = LoginPage(auth: auth);
        final forgotPage = ForgotPasswordPage(auth: auth);
        final registerPage = RegistrationPage(auth: auth);
        final todoPage = TodoListPage(
          firestore: firestore,
          auth: auth,
          deviceCalendarPlugin: deviceCalendarPlugin,
        );
        const selectDayPage = SelectDayPage();
        const addTodoPage = AddTodoPage();
        final routeMap = {
          '/login': (context) => loginPage,
          '/forgot_password': (context) => forgotPage,
          '/register': (context) => registerPage,
          '/home': (context) => homePage,
          '/todos': (context) => todoPage,
          '/add_todo': (context) => addTodoPage,
          '/select_day': (context) => selectDayPage,
        };
        return MaterialApp(
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
          navigatorObservers: <NavigatorObserver>[observer],
          routes: routeMap,
          home: StreamBuilder<User?>(
            stream: auth.authStateChanges(),
            builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
              return snapshot.hasData ? homePage : loginPage;
            },
          ),
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
