import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meet_up/widgets/common_button.dart';

import '../../utils/localfiles.dart';

class FacebookTwitterButtonView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _fTButtonUI();
  }

  Widget _fTButtonUI() {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 24,
          ),
          // Expanded(
          //   child: CommonButton(
          //     padding: EdgeInsets.zero,
          //     backgroundColor: Color(0x0FF3C5799),
          //     buttonTextWidget: _buttonTextUI(),
          //   ),
          // ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            child: CommonButton(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              buttonTextWidget: _buttonTextUI(),
            ),
          ),
          SizedBox(
            width: 24,
          )
        ],
      ),
    );
  }

  Widget _buttonTextUI() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(Localfiles.google ,height: 50,width: 50,),
        SizedBox(
          width: 4,
        ),
        Text(
           "Sign In With Google",
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }
}
