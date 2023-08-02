import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:meet_up/resources/auth_methods.dart';
import 'package:meet_up/resources/jitsi_meet_methods.dart';
import 'package:meet_up/utils/themes.dart';
import 'package:meet_up/widgets/meeting_option.dart';
import 'package:meet_up/widgets/common_button.dart';
import '../language/appLocalizations.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final AuthMethods _authMethods = AuthMethods();
  late TextEditingController meetingIdController;
  late TextEditingController nameController;
  final JitsiMeetMethods _jitsiMeetMethods = JitsiMeetMethods();
  bool isAudioMuted = true;
  bool isVideoMuted = true;
  String ? _errorName;

  @override
  void initState() {
    meetingIdController = TextEditingController();
    nameController = TextEditingController(
      text: _authMethods.user.displayName,
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    meetingIdController.dispose();
    nameController.dispose();
    JitsiMeet.removeAllListeners();
  }

  _joinMeeting() {
    if(_allValidation()){
    _jitsiMeetMethods.createMeeting(
      roomName: meetingIdController.text,
      isAudioMuted: isAudioMuted,
      isVideoMuted: isVideoMuted,
      username: nameController.text,
    );}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const AppBarTheme().backgroundColor,
        title: Text(AppLocalizations(context).of("join_a_meeting")),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: TextField(
              controller: meetingIdController,
              maxLines: 1,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                errorText: _errorName,
                fillColor: AppTheme.scaffoldBackgroundColor,
                filled: true,
                border: InputBorder.none,
                hintText: 'Room ID',
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 0),

              ),
            ),
          ),
          SizedBox(
            height: 60,
            child: TextField(
              controller: nameController,
              maxLines: 1,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                fillColor: AppTheme.scaffoldBackgroundColor,
                filled: true,
                border: InputBorder.none,
                hintText: 'Name',
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onHover: (value) {
              Text('$value +wait');
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CommonButton(
                buttonText: AppLocalizations(context).of("join"),
                onTap: _joinMeeting,
              ),
            ),
          ),
          const SizedBox(height: 20),
          MeetingOption(
            text: (AppLocalizations(context).of("mute_audio")),
            isMute: isAudioMuted,
            onChange: onAudioMuted,
          ),
          MeetingOption(
            text: (AppLocalizations(context).of("turn_off_camera")),
            isMute: isVideoMuted,
            onChange: onVideoMuted,
          ),
        ],
      ),
    );
  }

  onAudioMuted(bool val) {
    setState(() {
      isAudioMuted = val;
    });
  }

  onVideoMuted(bool val) {
    setState(() {
      isVideoMuted = val;
    });
  }
  bool _allValidation() {
    bool isValid = true;
    if (meetingIdController.text.trim().isEmpty) {
      _errorName = AppLocalizations(context).of('room_cannot_empty');
      isValid = false;
    } else {
      _errorName = '';
    }

    setState(() {});
    return isValid;
  }
}

