import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:test_app/services/map_service.dart';

import 'package:test_app/providers/add_participant_provider.dart';
import 'package:test_app/providers/reply_provider.dart';
import 'package:test_app/providers/theme_provider.dart';

import 'package:test_app/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => ReplyProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AddListProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => MapService(),
        ),
      ],
      child: Consumer<ThemeModel>(
        builder: (context, themeNotifier, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: themeNotifier.isDark ? ThemeData.dark() : ThemeData.light(),
            home: AuthScreen(),
            navigatorObservers: [routeObserver],
            //TODO: add a proper home screen, navigate user from there
          );
        },
      ),
    );
  }
}
