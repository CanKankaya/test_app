import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:test_app/services/following_service.dart';

import 'package:test_app/screens/other_user/other_userdata_screen.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('usersData').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> usersSnapshot) {
        if (usersSnapshot.connectionState == ConnectionState.waiting ||
            usersSnapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final currentUser = FirebaseAuth.instance.currentUser;
        final usersData = usersSnapshot.data?.docs;
        final currentUserData = usersData?.firstWhere((element) => element.id == currentUser?.uid);
        final List<dynamic> followingList = currentUserData?['following'];
        List<QueryDocumentSnapshot<Object?>>? notFoundUsersData = [];

        //** */
        if (usersData != null) {
          for (var user in usersData) {
            final foundUser = followingList.firstWhereOrNull(
              (element) => element == user['userId'],
            );
            if (foundUser == null && user['userId'] != currentUser?.uid) {
              notFoundUsersData.add(user);
            }
          }
        }
        //

        return Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              const Text(
                'Following',
                style: TextStyle(fontSize: 20),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Material(
                      color: Colors.black,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: followingList.length,
                        itemBuilder: (context, index) {
                          final user = usersData?.firstWhere(
                            (element) {
                              return element.id == followingList[index];
                            },
                          );
                          return FollowingUserItem(user: user);
                        },
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.amber,
                          thickness: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 20,
              ),
              const Text(
                'Users',
                style: TextStyle(fontSize: 20),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Material(
                      color: Colors.black,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: notFoundUsersData.length,
                        itemBuilder: (context, index) {
                          return OtherUserItem(user: notFoundUsersData[index]);
                        },
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.amber,
                          thickness: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FollowingUserItem extends StatelessWidget {
  const FollowingUserItem({Key? key, this.user}) : super(key: key);

  final QueryDocumentSnapshot<Object?>? user;
  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

    return Theme(
      data: ThemeData.dark(),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashColor: Colors.amber,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtherUserDataScreen(
              user: user,
            ),
          ),
        ),
        child: ListTile(
          leading: Container(
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
                user?['userImageUrl'] ?? '',
              ),
            ),
          ),
          title: Text(user?['username'] ?? ''),
          subtitle: Text(
            user?['userDetail'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
          trailing: ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (_, bool value, __) {
              return IconButton(
                icon: value ? const CircularProgressIndicator() : const Icon(Icons.remove),
                onPressed: !value
                    ? () {
                        isLoading.value = true;
                        followService
                            .unfollow(user?['userId'])
                            .then((_) => isLoading.value = false);
                      }
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}

class OtherUserItem extends StatelessWidget {
  const OtherUserItem({Key? key, this.user}) : super(key: key);

  final QueryDocumentSnapshot<Object?>? user;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

    return Theme(
      data: ThemeData.dark(),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashColor: Colors.amber,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtherUserDataScreen(
              user: user,
            ),
          ),
        ),
        child: ListTile(
          leading: Container(
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
                user?['userImageUrl'] ?? '',
              ),
            ),
          ),
          title: Text(user?['username'] ?? ''),
          subtitle: Text(
            user?['userDetail'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
          trailing: ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (_, bool value, __) {
              return IconButton(
                icon: value ? const CircularProgressIndicator() : const Icon(Icons.add),
                onPressed: !value
                    ? () {
                        isLoading.value = true;
                        followService.follow(user?['userId']).then((_) => isLoading.value = false);
                      }
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}
