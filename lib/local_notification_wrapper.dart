import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'blocs/blocs.dart';
import 'models/models.dart';
import 'my_app.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

class LocalNotificationWrapper extends StatelessWidget {
  const LocalNotificationWrapper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final flutterLocalNotificationsPlugin =
        context.read<FlutterLocalNotificationsPlugin>();
    final bloc = context.read<NotificationBloc>();
    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        'text_category',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'text_1',
            'Action 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
      DarwinNotificationCategory(
        'plain_category',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            'id_3',
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        bloc.add(NotificationReceived(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        ));
      },
      notificationCategories: darwinNotificationCategories,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    fetchFlutterLocalNotificationPluginFutureBuilder(
        context, notificationAppLaunchDetailsSnapshot) {
      final initialize = flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
          switch (notificationResponse.notificationResponseType) {
            case NotificationResponseType.selectedNotification:
              bloc.add(NotificationSelected(ReceivedNotification(
                  id: notificationResponse.id!,
                  title: notificationResponse.input ?? '',
                  payload: notificationResponse.payload)));
              break;
            case NotificationResponseType.selectedNotificationAction:
              break;
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      return FutureBuilder(
        future: initialize,
        builder: (context, snapshot) {
          return MyApp(
            notificationAppLaunchDetails:
                notificationAppLaunchDetailsSnapshot.data,
            flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
          );
        },
      );
    }

    return FutureBuilder(
        future:
            flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails(),
        builder: fetchFlutterLocalNotificationPluginFutureBuilder);
  }
}
