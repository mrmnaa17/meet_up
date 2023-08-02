import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meet_up/modules/splash/introductionScreen.dart';
import 'package:meet_up/screens/home_screen.dart';
import 'package:meet_up/utils/localfiles.dart';
import 'package:meet_up/utils/text_styles.dart';
import 'package:meet_up/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../resources/auth_methods.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoadText = false;
  @override
  void initState() {
    super.initState();
    void timer() {
      Timer(const Duration(milliseconds: 2500), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => IntroductionScreen(),
            ),
            (route) => false);
      });
    }

    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        SharedPreferences sp = await SharedPreferences.getInstance();

        bool? first = sp.getBool('first');

        if (first == false || AuthMethods().currentUser != null) {
          sp.setBool('first', true);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false);
        } else  {
          sp.setBool('first', true);
          timer();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            foregroundDecoration: !appTheme.isLightMode
                ? BoxDecoration(
                    color: Theme.of(context).backgroundColor.withOpacity(0.4))
                : null,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Column(
            children: <Widget>[
              const Expanded(
                flex: 5,
                child: SizedBox(),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Image.asset(
                        Localfiles.appIcon,
                      ),
                    ),
                  ],
                ),
              ),
              const CircularProgressIndicator(
                color: Color(0xFFEB7660),
              ),
              AnimatedOpacity(
                opacity: isLoadText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 420),
                child: Text(
                  '',
                  textAlign: TextAlign.left,
                  style: TextStyles(context).getRegularStyle().copyWith(),
                ),
              ),
              const Expanded(
                flex: 3,
                child: SizedBox(),
              ),
              AnimatedOpacity(
                opacity: isLoadText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 680),
              ),
              AnimatedOpacity(
                opacity: isLoadText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1200),
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: 24.0 + MediaQuery.of(context).padding.bottom,
                      top: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
