import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meet_up/language/appLocalizations.dart';
import 'package:meet_up/screens/history_meeting_screen.dart';
import 'package:meet_up/screens/meeting_screen.dart';
import 'package:meet_up/profile/components/body.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String profilePicLink = "";

  void pickUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 90,
    );

    Reference ref = FirebaseStorage.instance.ref().child("usersImages");

    await ref.putFile(File(image!.path));

    ref.getDownloadURL().then((value) async {
      setState(() {
        profilePicLink = value;
      });
    });
  }

  int _page = 0;
  onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  List<Widget> pages = [
    MeetingScreen(),
    const HistoryMeetingScreen(),
    const Body(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const AppBarTheme().backgroundColor,
        elevation: 0,
        title: Text(AppLocalizations(context).of("meet_and_chat")),
        centerTitle: true,
      ),
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const AppBarTheme().backgroundColor,
        selectedItemColor: const Color(0xFF4FBE9F),
        unselectedItemColor: Colors.grey,
        onTap: onPageChanged,
        currentIndex: _page,
        type: BottomNavigationBarType.fixed,
        unselectedFontSize: 14,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.comment_bank,
            ),
            label: AppLocalizations(context).of("meet_and_chat"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.lock_clock,
            ),
            label: AppLocalizations(context).of("meetings"),
          ),
          BottomNavigationBarItem(
              icon: const Icon(
                Icons.settings_outlined,
              ),
              label: AppLocalizations(context).of("settings")),
        ],
      ),
    );
  }
}
