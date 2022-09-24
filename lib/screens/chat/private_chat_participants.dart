import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:test_app/widgets/simpler_error_message.dart';

import 'package:test_app/screens/other_user/other_userdata_screen.dart';
import 'package:test_app/screens/chat/private_chats_list_screen.dart';

class PrivateChatParticipantsScreen extends StatelessWidget {
  final String chatId;

  const PrivateChatParticipantsScreen({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('usersData').snapshots(),
      builder: (_, AsyncSnapshot<QuerySnapshot> usersSnapshot) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('privateChats/$chatId/participantsData')
              .snapshots(),
          builder: (_, AsyncSnapshot<QuerySnapshot> participantsSnapshot) {
            if (usersSnapshot.hasData && participantsSnapshot.hasData) {
              final participantsData = participantsSnapshot.data?.docs;
              final usersData = usersSnapshot.data?.docs;

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Scaffold(
                  appBar: AppBar(
                    actions: [
                      IconButton(
                        onPressed: () => _deleteCurrentChat(chatId, context),
                        icon: const Icon(Icons.delete_forever),
                      ),
                    ],
                  ),
                  body: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: participantsData?.length,
                    itemBuilder: (context, index) {
                      final whichUser = usersData?.firstWhere((element) {
                        return element['userId'] == participantsData?[index]['userId'];
                      });
                      final isMe = currentUser?.uid == whichUser?['userId'];

                      return InkWell(
                        onTap: () {
                          if (!isMe) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtherUserDataScreen(
                                  user: whichUser,
                                ),
                              ),
                            );
                          }
                        },
                        splashColor: Colors.amber,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.amber,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: CircleAvatar(
                                  radius: 23,
                                  backgroundImage: NetworkImage(
                                    whichUser?['userImageUrl'] ?? '',
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                whichUser?['username'] ?? '',
                              ),
                              if (whichUser?['userId'] == currentUser?.uid)
                                const Text(
                                  '(You)',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
  }

  _deleteCurrentChat(String chatId, BuildContext context) async {
    final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Chat'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const [
                Text('Are you sure you want to delete this chat?'),
              ],
            ),
          ),
          actions: [
            ValueListenableBuilder(
              valueListenable: isLoading,
              builder: (context, bool value, __) {
                return TextButton(
                  onPressed: () async {
                    if (chatId == '') {
                      Navigator.of(context).pop();
                      SchedulerBinding.instance.addPostFrameCallback(
                        (_) {
                          simplerErrorMessage(
                            context,
                            'Couldnt find the chat',
                            '',
                            null,
                            false,
                          );
                        },
                      );
                      return;
                    } else {
                      isLoading.value = true;
                      await FirebaseFirestore.instance
                          .collection('privateChats')
                          .doc(chatId)
                          .delete();

                      SchedulerBinding.instance.addPostFrameCallback(
                        (_) {
                          isLoading.value = false;
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => const PrivateChatsListScreen(),
                              ),
                              (route) => false);
                          simplerErrorMessage(
                            context,
                            'Chat Deleted',
                            '',
                            null,
                            false,
                          );
                        },
                      );
                    }
                  },
                  child: value
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Yes',
                          style: TextStyle(fontSize: 20),
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
