import 'package:flutter/material.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:test_app/widgets/app_drawer.dart';
import 'package:test_app/widgets/exit_popup.dart';

import 'package:test_app/screens/profile/followers_screen.dart';
import 'package:test_app/screens/profile/following_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final currentUser = FirebaseAuth.instance.currentUser;

  final ValueNotifier<bool> _isUpdatable = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<XFile?> _pickedImage = ValueNotifier<XFile?>(null);

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _userDetailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('usersData').doc(currentUser?.uid).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting ||
            userSnapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(),
            drawer: const AppDrawer(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final DocumentSnapshot<Object?>? userData = userSnapshot.data;
        _usernameController.text = userData?['username'] ?? '';
        _emailController.text = currentUser?.email ?? '';
        _userDetailController.text = userData?['userDetail'] ?? '';

        return WillPopScope(
          onWillPop: () => showExitPopup(context),
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.amber,
              ),
              child: Scaffold(
                appBar: AppBar(),
                drawer: const AppDrawer(),
                body: Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            ValueListenableBuilder(
                              valueListenable: _pickedImage,
                              builder: (_, XFile? value, __) {
                                return Row(
                                  children: [
                                    Stack(
                                      children: [
                                        value == null
                                            ? CircleAvatar(
                                                radius: 60,
                                                backgroundImage:
                                                    NetworkImage(currentUser?.photoURL ?? ''),
                                              )
                                            : CircleAvatar(
                                                radius: 60,
                                                backgroundImage: FileImage(File(value.path)),
                                              ),
                                        Positioned(
                                          top: 75,
                                          left: 75,
                                          child: IconButton(
                                            iconSize: 40,
                                            onPressed: _selectImage,
                                            icon: const Icon(
                                              Icons.camera,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Column(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const FollowingScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            '${(userData?['followingCount'] ?? 0).toString()}\nFollowing',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FollowersScreen(thisUser: userData),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            '${(userData?['followerCount'] ?? 0).toString()}\nFollowers',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    key: const ValueKey('username'),
                                    autocorrect: false,
                                    textCapitalization: TextCapitalization.none,
                                    controller: _usernameController,
                                    maxLength: 30,
                                    decoration: const InputDecoration(labelText: 'Username'),
                                    onSaved: (newValue) {
                                      _usernameController.text = newValue ?? '';
                                    },
                                    onChanged: (_) {
                                      _isUpdatable.value = true;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Username cant be empty';
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                  TextFormField(
                                    key: const ValueKey('userDetail'),
                                    autocorrect: true,
                                    textCapitalization: TextCapitalization.sentences,
                                    controller: _userDetailController,
                                    maxLength: 200,
                                    decoration: const InputDecoration(labelText: 'User Detail'),
                                    maxLines: 10,
                                    minLines: 1,
                                    onSaved: (newValue) {
                                      _userDetailController.text = newValue ?? '';
                                    },
                                    onChanged: (_) {
                                      _isUpdatable.value = true;
                                    },
                                    validator: (value) {
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    key: const ValueKey('email'),
                                    style: const TextStyle(color: Colors.grey),
                                    enabled: false,
                                    autocorrect: false,
                                    textCapitalization: TextCapitalization.none,
                                    keyboardType: TextInputType.emailAddress,
                                    controller: _emailController,
                                    // maxLength: 50,
                                    onSaved: (newValue) {
                                      _emailController.text = newValue ?? '';
                                    },
                                    decoration: const InputDecoration(labelText: 'Email'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ValueListenableBuilder(
                          valueListenable: _isLoading,
                          builder: (_, bool loadingValue, __) {
                            return ValueListenableBuilder(
                              valueListenable: _isUpdatable,
                              builder: (_, bool updateValue, __) {
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                  ),
                                  onPressed: updateValue
                                      ? () {
                                          _tryUpdate();
                                          _isUpdatable.value = false;
                                        }
                                      : null,
                                  child: loadingValue
                                      ? const CircularProgressIndicator()
                                      : Text(
                                          'Update',
                                          style: TextStyle(
                                            color: updateValue ? Colors.black : Colors.grey,
                                          ),
                                        ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future _selectImage() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (image != null) {
      _pickedImage.value = image;

      _isUpdatable.value = true;
    }
  }

  Future _tryUpdate() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      if (_pickedImage.value != null) {
        _isLoading.value = true;

        final ref =
            FirebaseStorage.instance.ref().child('user_image').child('${currentUser!.uid}.jpg');
        await ref.delete();
        await ref.putFile(File(_pickedImage.value!.path));
        final url = await ref.getDownloadURL();
        await currentUser?.updatePhotoURL(url);

        await currentUser?.updateDisplayName(_usernameController.text);

        await FirebaseFirestore.instance.collection('usersData').doc(currentUser?.uid).update({
          'username': _usernameController.text,
          'userImageUrl': url,
          'userDetail': _userDetailController.text,
        }).then((_) {
          _isLoading.value = false;
        });
      } else {
        _isLoading.value = true;

        await currentUser?.updateDisplayName(_usernameController.text);

        await FirebaseFirestore.instance.collection('usersData').doc(currentUser?.uid).update({
          'username': _usernameController.text,
          'userDetail': _userDetailController.text,
        }).then((value) {
          _isLoading.value = false;
        });
      }
    }
  }
}
