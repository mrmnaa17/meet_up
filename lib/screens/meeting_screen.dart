import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meet_up/resources/jitsi_meet_methods.dart';
import 'package:meet_up/screens/video_call_screen.dart';
import 'package:meet_up/widgets/common_appbar_view.dart';
import 'package:meet_up/widgets/home_meeting_button.dart';

import '../language/appLocalizations.dart';

class MeetingScreen extends StatelessWidget {
  MeetingScreen({Key? key}) : super(key: key);

  final JitsiMeetMethods _jitsiMeetMethods = JitsiMeetMethods();

  createNewMeeting() async {
    var random = Random();
    String roomName = (random.nextInt(10000000) + 10000000).toString();
    _jitsiMeetMethods.createMeeting(
        roomName: roomName, isAudioMuted: true, isVideoMuted: true);
  }

  joinMeeting(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (BuildContext context) => const VideoCallScreen()),
    );  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              HomeMeetingButton(
                onPressed: createNewMeeting,
                text: AppLocalizations(context).of('new_meeting'),
                icon: Icons.videocam,
              ),
              HomeMeetingButton(
                onPressed: () => joinMeeting(context),
                text: AppLocalizations(context).of('join_meeting'),
                icon: Icons.add_box_rounded,
              ),
              // HomeMeetingButton(
              //   onPressed: () {},
              //   text: 'Schedule',
              //   icon: Icons.calendar_today,
              // ),
              // HomeMeetingButton(
              //   onPressed: () {},
              //   text: 'Share Screen',
              //   icon: Icons.arrow_upward_rounded,
              // ),
            ],
          ),
        ),
         Expanded(
          child: Center(
            child:CommonAppbarView(titleText: AppLocalizations(context).of("create_join_meeting"),)
          ),
        ),
      ],
    );
  }
}
