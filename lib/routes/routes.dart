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
      final analytics = context.read<FirebaseAnalytics>();
      return MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(
              auth: auth,
              analytics: analytics,
            ),
          ),
          BlocProvider<AnalyticsBloc>(
            create: (context) => AnalyticsBloc(
              analytics: context.read<FirebaseAnalytics>(),
            ),
          ),
        ],
        child: const LoginPage().builder(
          preBuild: (context) {
            final analyticsBloc = context.read<AnalyticsBloc>();
            analyticsBloc.add(AnalyticsEventPageView(
              screenName: 'LoginPage',
              screenClassOverride: 'LoginPage',
            ));
          },
        ),
      );
    },
  ),
  GoRoute(
    path: '/forgot_password',
    builder: (context, state) {
      final auth = context.read<FirebaseAuth>();
      final analytics = context.read<FirebaseAnalytics>();
      return MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(
              auth: auth,
              analytics: analytics,
            ),
          ),
          BlocProvider<AnalyticsBloc>(
            create: (context) => AnalyticsBloc(
              analytics: context.read<FirebaseAnalytics>(),
            ),
          ),
        ],
        child: const ForgotPasswordPage().builder(
          preBuild: (context) {
            final analyticsBloc = context.read<AnalyticsBloc>();
            analyticsBloc.add(AnalyticsEventPageView(
              screenName: 'ForgotPasswordPage',
              screenClassOverride: 'ForgotPasswordPage',
            ));
          },
        ),
      );
    },
  ),
  GoRoute(
    path: '/register',
    builder: (context, state) {
      final auth = context.read<FirebaseAuth>();
      final analytics = context.read<FirebaseAnalytics>();
      return MultiBlocProvider(
        providers: [
          BlocProvider<RegisterBloc>(
            create: (context) => RegisterBloc(
              auth: auth,
              analytics: analytics,
            ),
          ),
          BlocProvider<AnalyticsBloc>(
            create: (context) => AnalyticsBloc(
              analytics: context.read<FirebaseAnalytics>(),
            ),
          ),
        ],
        child: const RegistrationPage().builder(
          preBuild: (context) {
            final analyticsBloc = context.read<AnalyticsBloc>();
            analyticsBloc.add(AnalyticsEventPageView(
              screenName: 'RegistrationPage',
              screenClassOverride: 'RegistrationPage',
            ));
          },
        ),
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
            child: const TodoListPage().builder(preBuild: (context) {
              final analyticsBloc = context.read<AnalyticsBloc>();
              analyticsBloc.add(AnalyticsEventPageView(
                screenName: 'TodoListPage',
                screenClassOverride: 'TodoListPage',
              ));
            }),
          );
        },
      ),
      GoRoute(
        path: '/select_day',
        builder: (context, state) {
          final queryParam = state.uri.queryParameters['selected_date'];
          final selectedDate =
              queryParam == null ? DateTime.now() : DateTime.parse(queryParam);
          final todos = state.extra as List<Todo>? ?? [];
          return SelectDayPage(
            selectedDate: selectedDate,
            todos: todos,
          ).builder();
        },
      ),
      GoRoute(
        path: '/add_todo',
        builder: (context, state) {
          final topTags =
              state.uri.queryParameters['top_tags']?.split(',') ?? [];
          return AddTodoPage(topTags: topTags).builder();
        },
      ),
    ],
  )
]);
