import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meet_up/modules/login/login_screen.dart';
import 'package:meet_up/modules/splash/splashScreen.dart';
import 'package:meet_up/resources/auth_methods.dart';
import 'package:meet_up/screens/home_screen.dart';
import 'package:meet_up/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:meet_up/providers/theme_provider.dart';
import 'package:flutter/services.dart';
import 'package:meet_up/utils/themes.dart';
import 'package:meet_up/motel_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(_setAllProviders()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meet Up',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
      home: StreamBuilder(
        stream: AuthMethods().authChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => ThemeProvider(
                    state: AppTheme.getThemeData,
                  ),
                ),
              ],
              // child: MotelApp(),
              builder: (context, child) {
                return const MotelApp();
              },
            );
          }
        },
      ),
    );
  }
}

Widget _setAllProviders() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(
          state: AppTheme.getThemeData,
        ),
      ),
    ],
    builder: (context, child) {
      return const MotelApp();
    },
  );
}
