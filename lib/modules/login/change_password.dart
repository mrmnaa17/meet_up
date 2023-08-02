import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_up/language/appLocalizations.dart';
import 'package:meet_up/resources/auth_methods.dart';
import 'package:meet_up/widgets/common_appbar_view.dart';
import 'package:meet_up/widgets/common_button.dart';
import 'package:meet_up/widgets/common_text_field_view.dart';
import 'package:meet_up/widgets/remove_focuse.dart';

class ChangepasswordScreen extends StatefulWidget {
  @override
  _ChangepasswordScreenState createState() => _ChangepasswordScreenState();
}

class _ChangepasswordScreenState extends State<ChangepasswordScreen> {
  String _errorNewPassword = '';
  String _errorConfirmPassword = '';
  TextEditingController _newController = TextEditingController();
  TextEditingController _confirmController = TextEditingController();
  String? errorMessage;

  final currentUser = FirebaseAuth.instance.currentUser;

  String newPassword = "";
  String confirmPassword = '';
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _newController.dispose();
    _confirmController.dispose();
  }

  Future<String?> changePassword() async {
    if (_allValidation()) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      if (newPassword == confirmPassword) {
        await currentUser!.updatePassword(newPassword);

        Fluttertoast.showToast(
            msg: AppLocalizations(context).of('password_changed'));
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Your email address appears to be malformed.";

          break;
        case "wrong-password":
          errorMessage = "Your password is wrong.";
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          break;
        case "too-many-requests":
          errorMessage = "Too many requests";
          break;
        case "operation-not-allowed":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
      Fluttertoast.showToast(msg: errorMessage!);
      print(error.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RemoveFocuse(
        onClick: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CommonAppbarView(
              iconData: Icons.arrow_back,
              titleText: AppLocalizations(context).of("change_password"),
              onBackClick: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, bottom: 16.0, left: 24, right: 24),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              AppLocalizations(context)
                                  .of("enter_your_new_password"),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CommonTextFieldView(
                      controller: _newController,
                      titleText: AppLocalizations(context).of("new_password"),
                      padding: EdgeInsets.only(left: 24, right: 24, bottom: 16),
                      hintText:
                          AppLocalizations(context).of('enter_new_password'),
                      keyboardType: TextInputType.visiblePassword,
                      isObscureText: true,
                      onChanged: (value) {
                        newPassword = value;
                      },
                      errorText: _errorNewPassword,
                    ),
                    CommonTextFieldView(
                      controller: _confirmController,
                      titleText:
                          AppLocalizations(context).of("confirm_password"),
                      padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
                      hintText: AppLocalizations(context)
                          .of("enter_confirm_password"),
                      keyboardType: TextInputType.visiblePassword,
                      isObscureText: true,
                      onChanged: (value) {
                        confirmPassword = value;
                      },
                      errorText: _errorConfirmPassword,
                    ),
                    CommonButton(
                      padding: EdgeInsets.only(left: 24, right: 24, bottom: 16),
                      buttonText: AppLocalizations(context).of("Apply_text"),
                      isClickable: !_isLoading,
                      // isClickable: !_isLoading,
                      onTap: () {
                        // CircularProgressIndicator(
                        //   color: Colors.white,
                        // );
                        // SizedBox(
                        // width: 24,
                        // );
                        // Text('Please Wait...',
                        // style: TextStyle(
                        // color: Colors.white,
                        // fontSize: 22,
                        // fontWeight: FontWeight.bold));
                        changePassword();
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool _allValidation() {
    bool isValid = true;
    if (_newController.text.trim().isEmpty) {
      _errorNewPassword = AppLocalizations(context).of('password_cannot_empty');
      isValid = false;
    } else if (_newController.text.trim().length < 6) {
      _errorNewPassword = AppLocalizations(context).of('valid_new_password');
      isValid = false;
    } else {
      _errorNewPassword = '';
    }
    if (_confirmController.text.trim().isEmpty) {
      _errorConfirmPassword =
          AppLocalizations(context).of('password_cannot_empty');
      isValid = false;
    } else if (_newController.text.trim() != _confirmController.text.trim()) {
      _errorConfirmPassword =
          AppLocalizations(context).of('password_not_match');
      isValid = false;
    } else {
      _errorConfirmPassword = '';
    }
    setState(() {});
    return isValid;
  }
}
