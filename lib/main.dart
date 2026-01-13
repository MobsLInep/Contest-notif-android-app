import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './providers/contest_provider.dart';
import './providers/theme_provider.dart';
import './providers/user_provider.dart';
import './screens/contest_details_screen.dart';
import './screens/contests_screen.dart';
import './screens/not_found_screen.dart';
import './screens/settings_screen.dart';
import './screens/tabs_screen.dart';
import 'services/notification_service.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Set the background messaging handler early on
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  await NotificationService().initialize();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
        ChangeNotifierProvider(create: (ctx) => UserProvider(prefs)),
        ChangeNotifierProxyProvider<UserProvider, ContestProvider>(
          create: (ctx) => ContestProvider(),
          update: (ctx, userProvider, previousContestProvider) {
            return previousContestProvider ?? ContestProvider();
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Contest App',
            themeMode: themeProvider.themeMode,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            home: const TabsScreen(),
            routes: {
              ContestDetailsScreen.routeName: (ctx) => const ContestDetailsScreen(),
              '/contests': (ctx) => const ContestsScreen(),
              '/settings': (ctx) => const SettingsScreen(),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(builder: (ctx) => const NotFoundScreen());
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}