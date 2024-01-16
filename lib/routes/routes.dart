import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth.dart';
import '../blocs/blocs.dart';
import '../common/common.dart';
import '../todos/todos.dart';

final GoRouter goRouter = GoRouter(routes: [
  GoRoute(
    path: '/',
    redirect: (context, state) {
      final auth = context.read<FirebaseAuth>();
      return auth.currentUser == null ? '/login' : '/todos';
    },
  ),
  GoRoute(
    path: '/login',
    builder: (context, state) {
      final auth = context.read<FirebaseAuth>();
      return MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(auth: auth),
          ),
          BlocProvider<AnalyticsBloc>(
            create: (context) => AnalyticsBloc(
              analytics: context.read<FirebaseAnalytics>(),
            ),
          ),
        ],
        child: LoginPage(auth: auth),
      );
    },
  ),
  GoRoute(
    path: '/forgot_password',
    builder: (context, state) {
      final auth = context.read<FirebaseAuth>();
      return MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(auth: auth),
          ),
          BlocProvider<AnalyticsBloc>(
            create: (context) => AnalyticsBloc(
              analytics: context.read<FirebaseAnalytics>(),
            ),
          ),
        ],
        child: ForgotPasswordPage(auth: auth),
      );
    },
  ),
  GoRoute(
    path: '/register',
    builder: (context, state) {
      final auth = context.read<FirebaseAuth>();
      return MultiBlocProvider(
        providers: [
          BlocProvider<RegisterBloc>(
            create: (context) => RegisterBloc(auth: auth),
          ),
          BlocProvider<AnalyticsBloc>(
            create: (context) => AnalyticsBloc(
              analytics: context.read<FirebaseAnalytics>(),
            ),
          ),
        ],
        child: RegistrationPage(auth: auth),
      );
    },
  ),
  ShellRoute(
    builder: (context, state, child) => MultiBlocProvider(
      providers: [
        BlocProvider<AnalyticsBloc>(
          create: (context) => AnalyticsBloc(
            analytics: context.read<FirebaseAnalytics>(),
          ),
        ),
      ],
      child: Scaffold(
        body: child,
        bottomNavigationBar: const MyBottomBar(),
      ),
    ),
    routes: [
      GoRoute(
        path: '/todos',
        builder: (context, state) {
          final auth = context.read<FirebaseAuth>();
          final firestore = context.read<FirebaseFirestore>();
          final deviceCalendarPlugin = DeviceCalendarPlugin();
          return MultiBlocProvider(
            providers: [
              BlocProvider<TodoBloc>(
                create: (context) => TodoBloc(
                  firestore: firestore,
                  auth: auth,
                  deviceCalendarPlugin: deviceCalendarPlugin,
                )..add(const LoadTodos()),
              ),
            ],
            child: TodoListPage(
              auth: auth,
              firestore: firestore,
              deviceCalendarPlugin: deviceCalendarPlugin,
            ),
          );
        },
      ),
      GoRoute(
        path: '/select_day',
        builder: (context, state) {
          final selectedDate =
              DateTime.parse(state.uri.queryParameters['selected_date']!);
          final todos = state.extra! as List<Todo>;
          return SelectDayPage(
            selectedDate: selectedDate,
            todos: todos,
          );
        },
      ),
      GoRoute(
        path: '/add_todo',
        builder: (context, state) {
          final topTags =
              state.uri.queryParameters['top_tags']?.split(',') ?? [];
          return AddTodoPage(topTags: topTags);
        },
      ),
    ],
  )
]);
