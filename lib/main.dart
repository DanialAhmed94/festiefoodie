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

import 'firebase_options.dart';
import 'splashView.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");

  if (message.notification != null) {
    // The system will handle displaying the notification.
    // No need to manually display it.
    print('Message contains a notification payload. System will display it.');
  } else {
    // If it's a data-only message, you can display a notification manually.

  }
}


Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // <- small icon
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'), // Custom large icon
      styleInformation: BigPictureStyleInformation(
        DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),)
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
}
void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await initializeLocalNotifications();

  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permissions for iOS
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Enable auto-initialization on Android
  if (Platform.isAndroid) {
    await messaging.setAutoInitEnabled(true);
  }

  // Retrieve and save the FCM token
  String? token = await messaging.getToken();
  print('FCM Registration Token ***********************: $token');
  await saveTokenToPrefs(token);

  // Set up system UI overlay styles
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
// Set the preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,   // Portrait mode (upright)
    DeviceOrientation.portraitDown, // Portrait mode (upside-down)
  ]);



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
  const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async{
      print("Notification clicked with payload: ${response.payload}");
// Handle navigation when notification is tapped
     // await _navigateToAppropriateScreen();
    },
  );

  // Create notification channel for Android 8.0+
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // Channel ID
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
  // This widget is the root of your application.
  @override
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupFCM();

  }
  Future<void> setupFCM() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.messageId}');
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        _showNotification(
          notification.title ?? 'No Title',
          notification.body ?? 'No Body',
        );
      }
    });

    // Handle notification tap when the app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened app from background or terminated state: ${message.messageId}');
      //_handleNotificationClick(message);
    });

    // Handle app launch from a terminated state with a notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state with notification: ${message.messageId}');
        //_handleNotificationClick(message);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

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


