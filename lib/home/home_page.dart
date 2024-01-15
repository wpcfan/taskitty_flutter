import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../blocs/blocs.dart';
import 'tabs_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
    required this.analytics,
    required this.observer,
    this.notificationAppLaunchDetails,
    required this.flutterLocalNotificationsPlugin,
  });

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String _message = '';
  bool _notificationsEnabled = false;
  int id = 0;

  @override
  void initState() {
    super.initState();
    _isAndroidPermissionGranted();
    _requestPermissions();
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    setState(() {
      id++;
    });
    await widget.flutterLocalNotificationsPlugin.show(
        id, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await widget.flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await widget.flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await widget.flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          widget.flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      setState(() {
        _notificationsEnabled = grantedNotificationPermission ?? false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  Future<void> _setDefaultEventParameters() async {
    if (kIsWeb) {
      setMessage(
        '"setDefaultEventParameters()" is not supported on web platform',
      );
    } else {
      // Only strings, numbers & null (longs & doubles for android, ints and doubles for iOS) are supported for default event parameters:
      await widget.analytics.setDefaultEventParameters(<String, dynamic>{
        'string': 'string',
        'int': 42,
        'long': 12345678910,
        'double': 42.0,
        'bool': true.toString(),
      });
      setMessage('setDefaultEventParameters succeeded');
    }
  }

  Future<void> _sendAnalyticsEvent() async {
    // Only strings and numbers (longs & doubles for android, ints and doubles for iOS) are supported for GA custom event parameters:
    // https://firebase.google.com/docs/reference/ios/firebaseanalytics/api/reference/Classes/FIRAnalytics#+logeventwithname:parameters:
    // https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics#public-void-logevent-string-name,-bundle-params
    await widget.analytics.logEvent(
      name: 'test_event',
      parameters: <String, dynamic>{
        'string': 'string',
        'int': 42,
        'long': 12345678910,
        'double': 42.0,
        // Only strings and numbers (ints & doubles) are supported for GA custom event parameters:
        // https://developers.google.com/analytics/devguides/collection/analyticsjs/custom-dims-mets#overview
        'bool': true.toString(),
      },
    );

    setMessage('logEvent succeeded');
  }

  Future<void> _testSetCurrentScreen() async {
    await widget.analytics.setCurrentScreen(
      screenName: 'Analytics Demo',
      screenClassOverride: 'AnalyticsDemo',
    );
    setMessage('setCurrentScreen succeeded');
  }

  Future<void> _testSetAnalyticsCollectionEnabled() async {
    await widget.analytics.setAnalyticsCollectionEnabled(false);
    await widget.analytics.setAnalyticsCollectionEnabled(true);
    setMessage('setAnalyticsCollectionEnabled succeeded');
  }

  Future<void> _testSetSessionTimeoutDuration() async {
    await widget.analytics
        .setSessionTimeoutDuration(const Duration(milliseconds: 20000));
    setMessage('setSessionTimeoutDuration succeeded');
  }

  Future<void> _testSetUserProperty() async {
    await widget.analytics.setUserProperty(name: 'regular', value: 'indeed');
    setMessage('setUserProperty succeeded');
  }

  Future<void> _testAppInstanceId() async {
    String? id = await widget.analytics.appInstanceId;
    if (id != null) {
      setMessage('appInstanceId succeeded: $id');
    } else {
      setMessage('appInstanceId failed, consent declined');
    }
  }

  Future<void> _testResetAnalyticsData() async {
    await widget.analytics.resetAnalyticsData();
    setMessage('resetAnalyticsData succeeded');
  }

  AnalyticsEventItem itemCreator() {
    return AnalyticsEventItem(
      affiliation: 'affil',
      coupon: 'coup',
      creativeName: 'creativeName',
      creativeSlot: 'creativeSlot',
      discount: 2.22,
      index: 3,
      itemBrand: 'itemBrand',
      itemCategory: 'itemCategory',
      itemCategory2: 'itemCategory2',
      itemCategory3: 'itemCategory3',
      itemCategory4: 'itemCategory4',
      itemCategory5: 'itemCategory5',
      itemId: 'itemId',
      itemListId: 'itemListId',
      itemListName: 'itemListName',
      itemName: 'itemName',
      itemVariant: 'itemVariant',
      locationId: 'locationId',
      price: 9.99,
      currency: 'USD',
      promotionId: 'promotionId',
      promotionName: 'promotionName',
      quantity: 1,
    );
  }

  Future<void> _testAllEventTypes() async {
    await widget.analytics.logAddPaymentInfo();
    await widget.analytics.logAddToCart(
      currency: 'USD',
      value: 123,
      items: [itemCreator(), itemCreator()],
    );
    await widget.analytics.logAddToWishlist();
    await widget.analytics.logAppOpen();
    await widget.analytics.logBeginCheckout(
      value: 123,
      currency: 'USD',
      items: [itemCreator(), itemCreator()],
    );
    await widget.analytics.logCampaignDetails(
      source: 'source',
      medium: 'medium',
      campaign: 'campaign',
      term: 'term',
      content: 'content',
      aclid: 'aclid',
      cp1: 'cp1',
    );
    await widget.analytics.logEarnVirtualCurrency(
      virtualCurrencyName: 'bitcoin',
      value: 345.66,
    );

    await widget.analytics.logGenerateLead(
      currency: 'USD',
      value: 123.45,
    );
    await widget.analytics.logJoinGroup(
      groupId: 'test group id',
    );
    await widget.analytics.logLevelUp(
      level: 5,
      character: 'witch doctor',
    );
    await widget.analytics.logLogin(loginMethod: 'login');
    await widget.analytics.logPostScore(
      score: 1000000,
      level: 70,
      character: 'tiefling cleric',
    );
    await widget.analytics
        .logPurchase(currency: 'USD', transactionId: 'transaction-id');
    await widget.analytics.logSearch(
      searchTerm: 'hotel',
      numberOfNights: 2,
      numberOfRooms: 1,
      numberOfPassengers: 3,
      origin: 'test origin',
      destination: 'test destination',
      startDate: '2015-09-14',
      endDate: '2015-09-16',
      travelClass: 'test travel class',
    );
    await widget.analytics.logSelectContent(
      contentType: 'test content type',
      itemId: 'test item id',
    );
    await widget.analytics.logSelectPromotion(
      creativeName: 'promotion name',
      creativeSlot: 'promotion slot',
      items: [itemCreator()],
      locationId: 'United States',
    );
    await widget.analytics.logSelectItem(
      items: [itemCreator(), itemCreator()],
      itemListName: 't-shirt',
      itemListId: '1234',
    );
    await widget.analytics.logScreenView(
      screenName: 'tabs-page',
    );
    await widget.analytics.logViewCart(
      currency: 'USD',
      value: 123,
      items: [itemCreator(), itemCreator()],
    );
    await widget.analytics.logShare(
      contentType: 'test content type',
      itemId: 'test item id',
      method: 'facebook',
    );
    await widget.analytics.logSignUp(
      signUpMethod: 'test sign up method',
    );
    await widget.analytics.logSpendVirtualCurrency(
      itemName: 'test item name',
      virtualCurrencyName: 'bitcoin',
      value: 34,
    );
    await widget.analytics.logViewPromotion(
      creativeName: 'promotion name',
      creativeSlot: 'promotion slot',
      items: [itemCreator()],
      locationId: 'United States',
      promotionId: '1234',
      promotionName: 'big sale',
    );
    await widget.analytics.logRefund(
      currency: 'USD',
      value: 123,
      items: [itemCreator(), itemCreator()],
    );
    await widget.analytics.logTutorialBegin();
    await widget.analytics.logTutorialComplete();
    await widget.analytics.logUnlockAchievement(id: 'all Firebase API covered');
    await widget.analytics.logViewItem(
      currency: 'usd',
      value: 1000,
      items: [itemCreator()],
    );
    await widget.analytics.logViewItemList(
      itemListId: 't-shirt-4321',
      itemListName: 'green t-shirt',
      items: [itemCreator()],
    );
    await widget.analytics.logViewSearchResults(
      searchTerm: 'test search term',
    );
    setMessage('All standard events logged successfully');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state.notifications.isNotEmpty) {
          final receivedNotification = state.notifications.first;
          showDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: receivedNotification.title != null
                  ? Text(receivedNotification.title!)
                  : null,
              content: receivedNotification.body != null
                  ? Text(receivedNotification.body!)
                  : null,
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    // await Navigator.of(context).push(
                    //   MaterialPageRoute<void>(
                    //     builder: (BuildContext context) =>
                    //         SecondPage(receivedNotification.payload),
                    //   ),
                    // );
                  },
                  child: const Text('Ok'),
                )
              ],
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            MaterialButton(
              onPressed: _sendAnalyticsEvent,
              child: const Text('Test logEvent'),
            ),
            MaterialButton(
              onPressed: _testAllEventTypes,
              child: const Text('Test standard event types'),
            ),
            MaterialButton(
              onPressed: _testSetCurrentScreen,
              child: const Text('Test setCurrentScreen'),
            ),
            MaterialButton(
              onPressed: _testSetAnalyticsCollectionEnabled,
              child: const Text('Test setAnalyticsCollectionEnabled'),
            ),
            MaterialButton(
              onPressed: _testSetSessionTimeoutDuration,
              child: const Text('Test setSessionTimeoutDuration'),
            ),
            MaterialButton(
              onPressed: _testSetUserProperty,
              child: const Text('Test setUserProperty'),
            ),
            MaterialButton(
              onPressed: _testAppInstanceId,
              child: const Text('Test appInstanceId'),
            ),
            MaterialButton(
              onPressed: _testResetAnalyticsData,
              child: const Text('Test resetAnalyticsData'),
            ),
            MaterialButton(
              onPressed: _setDefaultEventParameters,
              child: const Text('Test setDefaultEventParameters'),
            ),
            Text(
              _message,
              style: const TextStyle(color: Color.fromARGB(255, 0, 155, 0)),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 155, 0),
                ),
                child: Text(
                  'Firebase Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Todos'),
                onTap: () {
                  Navigator.of(context).pushNamed('/todos');
                },
              ),
              ListTile(
                title: const Text('Show Notification'),
                onTap: () async {
                  await _showNotification();
                },
              ),
              ListTile(
                title: const Text('Cloud Messaging'),
                onTap: () {
                  Navigator.of(context).pushNamed('/messaging');
                },
              ),
              ListTile(
                title: const Text('Authentication'),
                onTap: () {
                  Navigator.of(context).pushNamed('/authentication');
                },
              ),
              ListTile(
                title: const Text('Dynamic Links'),
                onTap: () {
                  Navigator.of(context).pushNamed('/dynamic_links');
                },
              ),
              ListTile(
                title: const Text('Remote Config'),
                onTap: () {
                  Navigator.of(context).pushNamed('/remote_config');
                },
              ),
              ListTile(
                title: const Text('In-App Messaging'),
                onTap: () {
                  Navigator.of(context).pushNamed('/in_app_messaging');
                },
              ),
              ListTile(
                title: const Text('AdMob'),
                onTap: () {
                  Navigator.of(context).pushNamed('/admob');
                },
              ),
              ListTile(
                title: const Text('ML Kit'),
                onTap: () {
                  Navigator.of(context).pushNamed('/mlkit');
                },
              ),
              ListTile(
                title: const Text('Log Out'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  await FirebaseAuth.instance.signOut();
                  navigator.pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<TabsPage>(
                settings: const RouteSettings(name: TabsPage.routeName),
                builder: (BuildContext context) {
                  return TabsPage(widget.observer);
                },
              ),
            );
          },
          child: const Icon(Icons.tab),
        ),
      ),
    );
  }
}
