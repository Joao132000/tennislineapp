import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../handlers/notification.dart';
import '../models/post.dart';
import '../models/team.dart';

class Posts extends StatefulWidget {
  const Posts({Key? key, required this.teamId, required this.userName})
      : super(key: key);
  final String? teamId;
  final String? userName;

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final descriptionController = TextEditingController();
  String messageForNotification = '';
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Posts'), actions: [
        SizedBox(
          width: 10,
        )
      ]),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .where('teamId', isEqualTo: widget.teamId)
            .orderBy(
              "timeStamp",
              descending: false,
            )
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError ||
              snapshot.connectionState == ConnectionState.none ||
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 1),
                curve: Curves.easeInOut);
          });
          return Scrollbar(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final QueryDocumentSnapshot doc =
                            snapshot.data!.docs[index];

                        final Post post = Post.fromSnapshot(doc);
                        final String formattedDate =
                            DateFormat('M/dd/yyyy - kk:mm')
                                .format(post.timeStamp.toDate());

                        return Padding(
                          padding: EdgeInsets.only(
                              right: 18.0, left: 18, top: 15, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(height: 30),
                              Flexible(
                                  child: Row(
                                mainAxisAlignment:
                                    post.userName == widget.userName
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.cyan[900],
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(18),
                                          topLeft: Radius.circular(18),
                                          bottomLeft:
                                              post.userName == widget.userName
                                                  ? Radius.circular(18)
                                                  : Radius.circular(0),
                                          bottomRight:
                                              post.userName == widget.userName
                                                  ? Radius.circular(0)
                                                  : Radius.circular(18),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            post.userName == widget.userName
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  post.userName,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  formattedDate,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            post.description,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: Colors.white30)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: descriptionController,
                            maxLines: null,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                                hintText: 'Type your message here...'),
                          ),
                        ),
                        IconButton(
                            onPressed: () async {
                              messageForNotification =
                                  descriptionController.text;
                              if (descriptionController.text != "") {
                                final docPost = FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc();
                                final post = Post(
                                  id: docPost.id,
                                  teamId: widget.teamId!,
                                  userName: widget.userName!,
                                  timeStamp: Timestamp.now(),
                                  description: descriptionController.text,
                                );
                                final json = post.toJson();
                                await docPost.set(json);
                                FirebaseFirestore.instance
                                    .collection('player')
                                    .where('teamId', isEqualTo: widget.teamId!)
                                    .get()
                                    .then((QuerySnapshot snapshot) {
                                  snapshot.docs.forEach((element) {
                                    if (FirebaseAuth
                                            .instance.currentUser!.uid !=
                                        element['id']) {
                                      NotificationPush.sendPushMessage(
                                          element['token'],
                                          widget.userName,
                                          messageForNotification);
                                    }
                                  });
                                });
                                final docTeam = FirebaseFirestore.instance
                                    .collection("team")
                                    .doc(widget.teamId!);
                                final snapshotTeam = await docTeam.get();
                                final t = Team.fromJson(snapshotTeam.data()!);
                                FirebaseFirestore.instance
                                    .collection('coach')
                                    .where('id', isEqualTo: t.coachId)
                                    .get()
                                    .then((QuerySnapshot snapshot) {
                                  snapshot.docs.forEach((element) {
                                    if (FirebaseAuth
                                            .instance.currentUser!.uid !=
                                        element['id']) {
                                      NotificationPush.sendPushMessage(
                                          element['token'],
                                          widget.userName,
                                          messageForNotification);
                                    }
                                  });
                                });
                              }
                              descriptionController.clear();
                            },
                            icon: Icon(Icons.send))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
