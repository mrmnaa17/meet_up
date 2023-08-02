import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meet_up/modules/login/login_screen.dart';
import 'package:meet_up/screens/home_screen.dart';
import 'package:meet_up/utils/text_styles.dart';
import 'package:meet_up/utils/themes.dart';
import 'package:meet_up/language/appLocalizations.dart';
import 'package:meet_up/utils/validator.dart';
import 'package:meet_up/widgets/common_appbar_view.dart';
import 'package:meet_up/widgets/common_button.dart';
import 'package:meet_up/widgets/common_text_field_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meet_up/resources/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _errorEmail = '';
  final TextEditingController _emailController = TextEditingController();
  String _errorPassword = '';
  final TextEditingController _passwordController = TextEditingController();
  String _errorFName = '';
  final TextEditingController _fnameController = TextEditingController();
  String _errorLName = '';
  final TextEditingController _lnameController = TextEditingController();

  bool _isLoading = false;
  String? errorMessage;

  File? _pickedImage;
  String? url;
  String imageUrl = "";

  // Signing Up User

  void signUp(String email, String password) async {
    if (_allValidation()) {
      setState(() {
        _isLoading = true;
      });
    }
    {
      try {
        if (_pickedImage == null) {
          Fluttertoast.showToast(msg: AppLocalizations(context).of("pick"));
          _isLoading = false;
        } else if (!_allValidation()) {
          setState(() {
            _isLoading = false;
            Fluttertoast.showToast(msg: AppLocalizations(context).of("fields"));
          });
        } else {
          final ref = FirebaseStorage.instance
              .ref()
              .child('usersImages')
              .child(fName + '.jpg');
          await ref.putFile(_pickedImage!);
          url = await ref.getDownloadURL();
          await _auth
              .createUserWithEmailAndPassword(
                  email: _emailController.text,
                  password: _passwordController.text)
              .then((value) => postDetailsToFirestore());
        }
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
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
            errorMessage = "Too many requests";
            _isLoading = false;
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            _isLoading = false;
            break;
          case "email-already-in-use":
            errorMessage = "Email is already in use.";
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

  postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sedning these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    // writing all the values
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.firstName = _fnameController.text;
    userModel.lastName = _lnameController.text;
    userModel.imageUrl = url;
    user.updateDisplayName(_fnameController.text + " " + _lnameController.text);

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());

    Fluttertoast.showToast(
        msg: AppLocalizations(context).of("success_created"));

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false);
  }

  void _pickImageCamera() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 10);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _pickImageGallery() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _remove() {
    setState(() {
      _pickedImage = null;
    });
    Navigator.pop(context);
  }

  final _auth = FirebaseAuth.instance;

  late String fName;
  late String lName;
  late String email;
  late String password;
  late String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _appBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 30, horizontal: 30),
                          child: CircleAvatar(
                            radius: 71,
                            backgroundColor: const Color(0xFF4FBE9F),
                            child: CircleAvatar(
                              radius: 65,
                              backgroundColor: const Color(0xFF4FBE9F),
                              backgroundImage: _pickedImage == null
                                  ? null
                                  : FileImage(_pickedImage!),
                            ),
                          ),
                        ),
                        Positioned(
                            top: 120,
                            left: 110,
                            child: RawMaterialButton(
                              elevation: 10,
                              fillColor: const Color(0xFF4FBE9F),
                              child: const Icon(Icons.add_a_photo),
                              padding: const EdgeInsets.all(15.0),
                              shape: const CircleBorder(),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Choose option',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF4FBE9F)),
                                        ),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: [
                                              InkWell(
                                                onTap: _pickImageCamera,
                                                splashColor:
                                                    const Color(0xFF4FBE9F),
                                                child: Row(
                                                  children: const [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Icon(
                                                        FontAwesomeIcons.camera,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Camera',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color(
                                                              0xFF4FBE9F)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              InkWell(
                                                onTap: _pickImageGallery,
                                                splashColor: Colors.grey,
                                                child: Row(
                                                  children: const [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Icon(
                                                        FontAwesomeIcons.image,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Gallery',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color(
                                                              0xFF4FBE9F)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              InkWell(
                                                onTap: _remove,
                                                splashColor: Colors.grey,
                                                child: Row(
                                                  children: const [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Icon(
                                                        Icons.remove_circle,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Remove',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.red),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                            ))
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                    ),
                    CommonTextFieldView(
                      controller: _fnameController,
                      errorText: _errorFName,
                      padding: const EdgeInsets.only(
                          bottom: 16, left: 24, right: 24),
                      titleText: AppLocalizations(context).of("first_name"),
                      hintText:
                          AppLocalizations(context).of("enter_first_name"),
                      keyboardType: TextInputType.name,
                      onChanged: (value) {
                        fName = value;
                      },
                    ),
                    CommonTextFieldView(
                      controller: _lnameController,
                      errorText: _errorLName,
                      padding: const EdgeInsets.only(
                          bottom: 16, left: 24, right: 24),
                      titleText: AppLocalizations(context).of("last_name"),
                      hintText: AppLocalizations(context).of("enter_last_name"),
                      keyboardType: TextInputType.name,
                      onChanged: (value) {
                        lName = value;
                      },
                    ),
                    CommonTextFieldView(
                      controller: _emailController,
                      errorText: _errorEmail,
                      titleText: AppLocalizations(context).of("your_mail"),
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, bottom: 16),
                      hintText:
                          AppLocalizations(context).of("enter_your_email"),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    CommonTextFieldView(
                      titleText: AppLocalizations(context).of("password"),
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, bottom: 24),
                      hintText: AppLocalizations(context).of('enter_password'),
                      isObscureText: true,
                      onChanged: (value) {
                        password = value;
                      },
                      errorText: _errorPassword,
                      controller: _passwordController,
                    ),
                    CommonButton(
                      buttonTextWidget: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:  [
                                const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                const SizedBox(
                                  width: 24,
                                ),
                                Text(AppLocalizations(context).of("wait"),
                                    style:  const TextStyle(
                                        color: Color(0xFF4FBE9F),
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )
                          : Text(AppLocalizations(context).of("sign_up"),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                      onTap: () async {
                        if (_isLoading) return;
                        setState(() {
                          _isLoading = true;
                        });
                        await Future.delayed(const Duration(milliseconds: 500));
                        setState(() {
                          _isLoading = false;
                          signUp(
                              _emailController.text, _passwordController.text);
                        });
                      },
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, bottom: 16),
                      buttonText: AppLocalizations(context).of("sign_up"),
                      isClickable: !_isLoading,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        AppLocalizations(context).of("terms_agreed"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          AppLocalizations(context).of("already_have_account"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                        InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              AppLocalizations(context).of("login"),
                              style: TextStyles(context)
                                  .getRegularStyle()
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 24,
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

  Widget _appBar() {
    return CommonAppbarView(
      iconData: Icons.arrow_back,
      titleText: AppLocalizations(context).of("sign_up"),
      onBackClick: () {
        Navigator.pop(context);
      },
    );
  }

  bool _allValidation() {
    bool isValid = true;

    if (_fnameController.text.trim().isEmpty) {
      _errorFName = AppLocalizations(context).of('first_name_cannot_empty');
      isValid = false;
    } else {
      _errorFName = '';
    }

    if (_lnameController.text.trim().isEmpty) {
      _errorLName = AppLocalizations(context).of('last_name_cannot_empty');
      isValid = false;
    } else {
      _errorLName = '';
    }

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
