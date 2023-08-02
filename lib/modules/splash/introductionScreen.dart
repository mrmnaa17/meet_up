import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meet_up/modules/login/login_screen.dart';
import 'package:meet_up/modules/login/sign_up_Screen.dart';
import 'package:meet_up/utils/localfiles.dart';
import 'package:meet_up/utils/themes.dart';
import 'package:meet_up/language/appLocalizations.dart';
import 'package:meet_up/modules/splash/components/page_pop_view.dart';
import 'package:meet_up/widgets/common_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  var pageController = PageController(initialPage: 0);
  List<PageViewData> pageViewModelData = [];

  late Timer sliderTimer;
  var currentShowIndex = 0;

  @override
  void initState() {
    pageViewModelData.add(PageViewData(
      titleText: 'remotly',
      subText: 'seeing_and_hearing',
      assetsImage: Localfiles.introduction1,
    ));

    pageViewModelData.add(PageViewData(
      titleText: 'high_definition',
      subText: 'makes_your_work',
      assetsImage: Localfiles.introduction2,
    ));

    pageViewModelData.add(PageViewData(
      titleText: 'meeting_online',
      subText: 'setting_up',
      assetsImage: Localfiles.introduction3,
    ));

    sliderTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (currentShowIndex == 0) {
        pageController.animateTo(MediaQuery.of(context).size.width,
            duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
      } else if (currentShowIndex == 1) {
        pageController.animateTo(MediaQuery.of(context).size.width * 2,
            duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
      } else if (currentShowIndex == 2) {
        pageController.animateTo(0,
            duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
      }
    });
    print('intro');
    //FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  void dispose() {
    sliderTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context2) {
    return Scaffold(
      //key: navigatorKey,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context2).padding.top,
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              pageSnapping: true,
              onPageChanged: (index) {
                currentShowIndex = index;
              },
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                PagePopup(imageData: pageViewModelData[0]),
                PagePopup(imageData: pageViewModelData[1]),
                PagePopup(imageData: pageViewModelData[2]),
              ],
            ),
          ),
          SmoothPageIndicator(
            controller: pageController, // PageController
            count: 3,
            effect: WormEffect(
                activeDotColor: Theme.of(context2).primaryColor,
                dotColor: Theme.of(context2).dividerColor,
                dotHeight: 10.0,
                dotWidth: 10.0,
                spacing: 5.0), // your preferred effect
            onDotClicked: (index) {},
          ),
          CommonButton(
            padding:
                const EdgeInsets.only(left: 48, right: 48, bottom: 8, top: 32),
            buttonText: AppLocalizations(context2).of("login"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ));
            },
          ),
          CommonButton(
            padding:
                const EdgeInsets.only(left: 48, right: 48, bottom: 32, top: 8),
            buttonText: AppLocalizations(context2).of("create_account"),
            backgroundColor: AppTheme.backgroundColor,
            textColor: AppTheme.primaryTextColor,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpScreen(),
                  ));
            },
          ),
          SizedBox(
            height: MediaQuery.of(context2).padding.bottom,
          )
        ],
      ),
    );
  }
}
