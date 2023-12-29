import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:relative_time/relative_time.dart';

import 'auth/auth.dart';
import 'common/common.dart';
import 'firebase_options.dart';
import 'home/home.dart';
import 'todos/todos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  /// 初始化 Bloc 的观察者，用于监听 Bloc 的生命周期
  Bloc.observer = SimpleBlocObserver();
  // Ideal time to initialize
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static DeviceCalendarPlugin deviceCalendarPlugin = DeviceCalendarPlugin();

  @override
  Widget build(BuildContext context) {
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
      routes: {
        '/login': (context) => LoginPage(
              analytics: analytics,
              observer: observer,
              auth: auth,
            ),
        '/forgot_password': (context) => ForgotPasswordPage(
              auth: auth,
            ),
        '/register': (context) => RegistrationPage(
              auth: auth,
            ),
        '/home': (context) => HomePage(
              title: 'Firebase Analytics Demo',
              analytics: analytics,
              observer: observer,
            ),
        '/todos': (context) => TodoListPage(
              firestore: firestore,
              auth: auth,
              analytics: analytics,
              deviceCalendarPlugin: deviceCalendarPlugin,
            ),
        '/add_todo': (context) => AddTodoPage(
              analytics: analytics,
            ),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasData) {
            return HomePage(
              title: 'Firebase Analytics Demo',
              analytics: analytics,
              observer: observer,
            );
          } else {
            return LoginPage(
              analytics: analytics,
              observer: observer,
              auth: auth,
            );
          }
        },
      ),
      builder: (context, child) {
        EasyLoading.init();
        return FlutterEasyLoading(child: child);
      },
    );
  }
}
