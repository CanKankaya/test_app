import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class OtherUserFollowersScreen extends StatelessWidget {
  const OtherUserFollowersScreen({Key? key, required this.thisUser}) : super(key: key);
  final DocumentSnapshot<Object?>? thisUser;

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
        final usersData = usersSnapshot.data?.docs;
        final List<dynamic> followersList = thisUser?['followers'];

        return Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Followers',
                  style: TextStyle(fontSize: 20),
                ),
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
                        itemCount: followersList.length,
                        itemBuilder: (context, index) {
                          final user = usersData?.firstWhere(
                            (element) {
                              return element.id == followersList[index];
                            },
                          );
                          return FollowerUserItem(user: user);
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

class FollowerUserItem extends StatelessWidget {
  const FollowerUserItem({Key? key, this.user}) : super(key: key);

  final QueryDocumentSnapshot<Object?>? user;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashColor: Colors.amber,
        onTap: () {},
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
        ),
      ),
    );
  }
}
