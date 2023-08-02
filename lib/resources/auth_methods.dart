import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meet_up/utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../language/appLocalizations.dart';
import '../modules/splash/introductionScreen.dart';
import 'package:meet_up/resources/user_model.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel userModel = UserModel();
  String? errorMessage;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User get user => _auth.currentUser!;

  Future<bool> signInWithGoogle(BuildContext context) async {
    bool res = false;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName,
            'Email': user.email,
            'imageUrl': user.photoURL,
          });
        }
        res = true;
        Fluttertoast.showToast(msg: AppLocalizations(context).of('success_login'));
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
      res = false;
    }
    return res;
  }

  String newPassword = "";

  //changing password
  final currentUser = FirebaseAuth.instance.currentUser;

  BuildContext? context;

  // SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

// DELETE ACCOUNT
  Future<void> deleteAccount() async {
    await user.delete();
  }

// Alert Dialog Delete Account
  Future<void> showMyDialogDelete({required BuildContext context}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations(context).of("delete_account")),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(AppLocalizations(context).of("confirm_delete")),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations(context).of("confirm")),
              onPressed: () {
                AuthMethods().deleteAccount();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const IntroductionScreen(),
                    ),
                    (route) => false);
                Fluttertoast.showToast(
                    msg: AppLocalizations(context).of("success_deleted"));
              },
            ),
            TextButton(
              child: Text(AppLocalizations(context).of("cancel")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Alert Dialog Delete Account
  Future<void> showMyDialogRestart({required BuildContext context}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations(context).of("restart_app")),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(AppLocalizations(context).of("confirm_restart")),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations(context).of("confirm")),
              onPressed: () {
                Restart.restartApp();
              },
            ),
            TextButton(
              child: Text(AppLocalizations(context).of("cancel")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Alert Dialog Log out
  Future<void> showMyDialogLogOut({required BuildContext context}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations(context).of("log_out")),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(AppLocalizations(context).of("confirm_logout")),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations(context).of("confirm")),
              onPressed: () {
                AuthMethods().signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const IntroductionScreen(),
                    ),
                    (route) => false);
                Fluttertoast.showToast(
                    msg: AppLocalizations(context).of("success_logout"));
              },
            ),
            TextButton(
              child: Text(AppLocalizations(context).of("cancel")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
