import 'package:flutter/material.dart';
import 'package:flutter_chat_app/util/firebase_helper.dart';
import 'package:flutter_chat_app/widgets/message_bubble.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseHelper().firestoreGetChat(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('no message found'),
          );
        }

        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('something went wrong...'),
          );
        }

        final loadedMessages = chatSnapshot.data!.docs;

        return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final messages = loadedMessages[index].data();
              final nextMessages = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;
              final currentMessageUserId =
                  messages[FirebaseHelper().firestoreuserIdKey];
              final nextMessageUserId = nextMessages != null
                  ? nextMessages[FirebaseHelper().firestoreuserIdKey]
                  : null;
              final nextUserIdIsSame =
                  nextMessageUserId == currentMessageUserId;

              if (nextUserIdIsSame) {
                return MessageBubble.next(
                  message: messages[FirebaseHelper().firestoreTextKey],
                  isMe: FirebaseHelper().getUser()!.uid == currentMessageUserId,
                );
              } else {
                return MessageBubble.first(
                    userImage: messages[FirebaseHelper().firestoreuserImageKey],
                    username: messages[FirebaseHelper().firestoreUsernameKey],
                    message: messages[FirebaseHelper().firestoreTextKey],
                    isMe: FirebaseHelper().getUser()!.uid ==
                        currentMessageUserId);
              }
            });
      },
    );
  }
}
