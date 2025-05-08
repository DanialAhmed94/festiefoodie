import 'package:festiefoodie/providers/eventProvider.dart';
import 'package:festiefoodie/providers/festivalProvider.dart';
import 'package:festiefoodie/providers/menuProvider.dart';
import 'package:festiefoodie/providers/ratingsProvider.dart';
import 'package:festiefoodie/providers/stallProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'splashView.dart';

void main() async{

  //firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp((MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => FestivalProvider()),
      ChangeNotifierProvider(create: (_) => RatingsProvider()),
      ChangeNotifierProvider(create: (_) => EventProvider()),
      ChangeNotifierProvider(create: (_) => StallProvider()),
      ChangeNotifierProvider(create: (_) => MenuProvider()),

  ],
     child: const MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
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


