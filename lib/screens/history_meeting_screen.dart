import 'package:flutter/material.dart';
import 'package:meet_up/resources/firestore_methods.dart';
import 'package:intl/intl.dart';
import '../language/appLocalizations.dart';

class HistoryMeetingScreen extends StatelessWidget {
  const HistoryMeetingScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirestoreMethods().meetingsHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: (snapshot.data! as dynamic).docs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                AppLocalizations(context).of("room_number") +
                    '  ${(snapshot.data! as dynamic).docs[index]['meetingName']}',
              ),
              subtitle: Text(
                AppLocalizations(context).of("joined_on") +
                    ' : ${DateFormat.yMMMd().format((snapshot.data! as dynamic).docs[index]['createdAt'].toDate())}',
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  FirestoreMethods()
                      .delete((snapshot.data! as dynamic).docs[index].id);
                },
              ),
            );
          },
        );
      },
    );
  }
}
