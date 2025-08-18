import 'dart:io';

import 'package:festiefoodie/providers/eventProvider.dart';
import 'package:festiefoodie/providers/festivalProvider.dart';
import 'package:festiefoodie/providers/menuProvider.dart';
import 'package:festiefoodie/providers/ratingsProvider.dart';
import 'package:festiefoodie/providers/stallProvider.dart';
import 'package:festiefoodie/utilities/sharedPrefs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'splashView.dart';
import 'views/foodieStall/foofieStallHome.dart';
import 'views/foodieStall/authViews/loginView.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling background message: ${message.messageId}');
  if (message.notification != null) {
    _showNotification(
      message.notification?.title ?? '',
      message.notification?.body ?? '',
    );
  }
}

Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'festiefoodie_high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'Used for important FestieFoodie notifications',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
  );

  const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: iOSDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    platformDetails,
  );
}

Future<void> _navigateToAppropriateScreen() async {
  bool isLoggedIn = (await getIsLogedIn()) ?? false;

  if (isLoggedIn) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => FoodieStallHome()),
      (_) => false,
    );
  } else {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginView()),
      (_) => false,
    );
  }
}

Future<String?> getCurrentUserId() async {
  final userId = await getUserId();
  return userId?.toString(); // returns null if no one is logged in
}



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Must be before runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initializeLocalNotifications();

  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // iOS permission
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // Android 13+ auto-init
  if (Platform.isAndroid) {
    await messaging.setAutoInitEnabled(true);
  }

  // Retrieve and save token
  String? token = await messaging.getToken();
  print('FCM Token: $token');




  // Set the preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,   // Portrait mode (upright)
    DeviceOrientation.portraitDown, // Portrait mode (upside-down)
  ]);

  // Set up system UI overlay styles
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp((MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => FestivalProvider()),
      ChangeNotifierProvider(create: (_) => RatingsProvider()),
      ChangeNotifierProvider(create: (_) => EventProvider()),
      ChangeNotifierProvider(create: (_) => StallProvider()),
      ChangeNotifierProvider(create: (_) => MenuProvider()),
  ],
     child: const MyApp())));
}

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initIOS = DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: initAndroid,
    iOS: initIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      print("Notification tapped: ${response.payload}");
      await _navigateToAppropriateScreen();
    },
  );

  // Create notification channel for Android 8.0+
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'festiefoodie_high_importance_channel', // Channel ID
    'High Importance Notifications', // Channel name
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    setupFCM();
  }

  Future<void> setupFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.messageId}');
      if (message.notification != null) {
        _showNotification(
          message.notification!.title ?? '',
          message.notification!.body ?? '',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened app: ${message.messageId}');
      _handleNotificationClick(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('App opened from terminated with message: ${message.messageId}');
        _handleNotificationClick(message);
      }
    });
  }

  Future<void> _handleNotificationClick(RemoteMessage message) async {
    await _navigateToAppropriateScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'FestieFoodie',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Splashview(),
    );
  }
}


