import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meet_up/language/appLocalizations.dart';
import 'package:meet_up/modules/login/forgot_password.dart';
import 'package:meet_up/modules/login/sign_up_Screen.dart';
import 'package:meet_up/screens/home_screen.dart';
import 'package:meet_up/utils/localfiles.dart';
import 'package:meet_up/utils/themes.dart';
import 'package:meet_up/utils/validator.dart';
import 'package:meet_up/widgets/common_appbar_view.dart';
import 'package:meet_up/widgets/common_button.dart';
import 'package:meet_up/widgets/common_text_field_view.dart';
import 'package:meet_up/widgets/remove_focuse.dart';
import 'package:meet_up/resources/auth_methods.dart';
import '../../utils/text_styles.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? errorMessage;
  String _animationType = 'idle';
  final FocusNode passwordNode = FocusNode();
  final FocusNode emailNode = FocusNode();
  SharedPreferences? loginData;
  bool? newUser;
  void checkIfLogin() async {
    loginData = await SharedPreferences.getInstance();
    newUser = (loginData?.getBool('login') ?? true);
  }

  @override
  void initState() {
    passwordNode.addListener(() {
      if (passwordNode.hasFocus) {
        setState(() {
          _animationType = 'hands_up';
        });
      } else {
        setState(() {
          _animationType = 'hands_down';
        });
      }
    });

    emailNode.addListener(() {
      if (emailNode.hasFocus) {
        setState(() {
          _animationType = 'test';
        });
      } else {
        setState(() {
          _animationType = 'idle';
        });
      }
    });

    super.initState();
    checkIfLogin();
  }

  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;

  final String _correctPassword = 'admin';

  String _errorEmail = '';
  String _errorPassword = '';

  // login function
  Future<void> signIn(String email, String password) async {
    if (_allValidation()) {
      setState(() {
        _isLoading = true;
      });
    }

    {
      try {
        if (!_allValidation()) {
          setState(() {
            _isLoading = false;
            Fluttertoast.showToast(msg: AppLocalizations(context).of("fields"));
          });
        } else {
          await _auth
              .signInWithEmailAndPassword(email: email, password: password)
              .then((uid) => {
                    Fluttertoast.showToast(
                        msg: AppLocalizations(context).of('success_login')),
                    Navigator.pushAndRemoveUntil(
                        (context),
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                        (route) => false),
                  });
        }
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email is invalid.";
            _isLoading = false;
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            _isLoading = false;
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            _isLoading = false;
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            _isLoading = false;
            break;
          case "too-many-requests":
            errorMessage =
                "Too many requests.. please try again after a few minutes";
            _isLoading = false;
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            _isLoading = false;
            break;
          case "unknown":
            errorMessage = "An undefined Error happened.";
            _isLoading = false;
            break;
          default:
            errorMessage = "An undefined Error happened.";
            _isLoading = false;
        }
        Fluttertoast.showToast(msg: errorMessage!);
        _isLoading = false;
      }
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
              titleText: AppLocalizations(context).of("login"),
              onBackClick: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(1.0),
                    ),
                    CommonTextFieldView(
                      // titleText: AppLocalizations(context).of("your_mail"),
                      controller: _emailController,
                      focusNode: emailNode,
                      errorText: _errorEmail,
                      img: SizedBox(
                        height: 180,
                        child: FlareActor(
                          'assets/Teddy.flr',
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                          animation: _animationType,
                          callback: (currentAnimation) {
                            setState(() {
                              _animationType = 'idle';
                            });
                          },
                        ),
                      ),
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, bottom: 16, top: 10),
                      hintText:
                          AppLocalizations(context).of("enter_your_email"),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    CommonTextFieldView(
                      titleText: AppLocalizations(context).of("password"),
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      hintText: AppLocalizations(context).of("enter_password"),
                      isObscureText: true,
                      onChanged: (value) {
                        password = value;
                      },
                      errorText: _errorPassword,
                      controller: _passwordController,
                      focusNode: passwordNode,
                    ),
                    _forgotYourPasswordUI(),
                    CommonButton(
                      buttonTextWidget: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 24,
                                ),
                                Text('Please Wait...',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )
                          : Text(
                              AppLocalizations(context).of("login"),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                      onTap: () async {
                        loginData?.setBool('login', true);
                        if (_isLoading) return;
                        setState(() {
                          _isLoading = true;
                        });
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (_passwordController.text
                                .compareTo(_correctPassword) ==
                            0) {
                          setState(() {
                            _animationType = 'success';
                          });
                        } else {
                          setState(() {
                            _animationType = 'success';
                          });
                        }
                        setState(() {
                          _isLoading = false;

                          signIn(
                              _emailController.text, _passwordController.text);
                        });
                      },
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, bottom: 16),
                      buttonText: AppLocalizations(context).of("login"),
                      isClickable: !_isLoading,
                    ),
                    CommonButton(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 35),
                      textColor: Colors.red,
                      backgroundColor: Colors.white,
                      buttonTextWidget: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(Localfiles.google,
                                height: 35, width: 35),
                          ),
                          const Text(
                            'Login with Google',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontFamily: 'arial',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        {
                          bool res =
                              await AuthMethods().signInWithGoogle(context);
                          if (res) {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                                (route) => false);
                          }
                        }
                      },
                    ),
                    Text(
                      AppLocalizations(context).of("new_account"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          AppLocalizations(context).of("register_now"),
                          style: TextStyles(context).getRegularStyle().copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _forgotYourPasswordUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations(context).of("forgot_your_Password"),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _allValidation() {
    bool isValid = true;
    if (_emailController.text.trim().isEmpty) {
      _errorEmail = AppLocalizations(context).of('email_cannot_empty');
      isValid = false;
    } else if (!Validator.validateEmail(_emailController.text.trim())) {
      _errorEmail = AppLocalizations(context).of('enter_valid_email');
      isValid = false;
    } else {
      _errorEmail = '';
    }

    if (_passwordController.text.trim().isEmpty) {
      _errorPassword = AppLocalizations(context).of('password_cannot_empty');
      isValid = false;
    } else if (_passwordController.text.trim().length < 6) {
      _errorPassword = AppLocalizations(context).of('valid_password');
      isValid = false;
    } else {
      _errorPassword = '';
    }
    setState(() {});
    return isValid;
  }
}
