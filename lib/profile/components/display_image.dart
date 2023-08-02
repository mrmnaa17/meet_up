import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meet_up/language/appLocalizations.dart';
import 'package:meet_up/widgets/remove_focuse.dart';

import '../../resources/user_model.dart';

class DisplayImage extends StatefulWidget {
  const DisplayImage({Key? key}) : super(key: key);

  @override
  State<DisplayImage> createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage> {
  String? _uid;
  String? _userImageUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const AppBarTheme().backgroundColor,
      ),
      body: RemoveFocuse(
          onClick: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: wait()),
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
    });
  }

  void getData() async {
    User? user = _auth.currentUser;
    _uid = user!.uid;

    final DocumentSnapshot<Map<String, dynamic>>? userDoc = user.isAnonymous
        ? null
        : await FirebaseFirestore.instance.collection('users').doc(_uid).get();

    if (userDoc == null) {
      return;
    } else {
      setState(() {
        _userImageUrl = userDoc.get('imageUrl');
      });
    }
  }

  Widget wait() {
    if (_userImageUrl == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4FBE9F),
            ),
          ),
          const SizedBox(
            width: 24,
          ),
          Text(AppLocalizations(context).of("wait"),
              style: const TextStyle(
                  color: Color(0xFF4FBE9F),
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      );
    } else {
      return Image.network(_userImageUrl!);
    }
  }
}
