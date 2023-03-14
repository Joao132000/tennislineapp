import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tennislineapp/screens/posts.dart';
import 'package:tennislineapp/screens/team_doubles.dart';

import '../models/coach.dart';
import 'matches_coach.dart';

class PlayersByTeam extends StatefulWidget {
  final String teamId;
  final String teamSchool;
  final String teamType;
  final String teamLeague;

  const PlayersByTeam(
      {Key? key,
      required this.teamId,
      required this.teamSchool,
      required this.teamType,
      required this.teamLeague})
      : super(key: key);

  @override
  State<PlayersByTeam> createState() => _PlayersByTeamState();
}

class _PlayersByTeamState extends State<PlayersByTeam> {
  final positionController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void dispose() {
    positionController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Team Lineup'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) async {
          if (details.delta.dx < 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDoubles(
                  teamId: widget.teamId,
                  teamSchool: widget.teamSchool,
                  teamType: widget.teamType,
                ),
              ),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () {
            return Future(() {
              setState(() {});
            });
          },
          child: FutureBuilder<QuerySnapshot>(
              future: read(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Doubles lineup',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 15,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(widget.teamSchool,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 25,
                          )),
                      Text(
                        'Singles ${widget.teamType}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: buildListView(documents, context),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blueAccent.shade200,
                                  minimumSize: const Size(150, 40),
                                  // foreground
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MatchesCoach(
                                            teamId: widget.teamId)),
                                  );
                                },
                                child: const Text(
                                  'Team Matches',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                              const SizedBox(
                                height: 70,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blueAccent.shade200,
                                  minimumSize: const Size(150, 40),
                                  // foreground
                                ),
                                child: const Text(
                                  'Team Posts',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                onPressed: () async {
                                  final c = await getCoach();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Posts(
                                        teamId: widget.teamId,
                                        userName: c.name,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      )
                    ],
                  );
                } else if (snapshot.hasError) {
                  return const Text('Its Error!');
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ));

  Future<Coach> getCoach() async {
    final docCoach = FirebaseFirestore.instance
        .collection("coach")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final snapshot = await docCoach.get();
    return Coach.fromJson(snapshot.data()!);
  }

  ListView buildListView(
      List<DocumentSnapshot<Object?>> documents, BuildContext context) {
    return ListView(
        children: documents
            .map((doc) => Slidable(
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Are you sure you want to delete this player?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 25,
                                ),
                              ),
                              actions: [
                                Row(
                                  children: [
                                    TextButton(
                                      child: const Text(
                                        'Confirm',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        ),
                                      ),
                                      onPressed: () {
                                        final deleteDoc = FirebaseFirestore
                                            .instance
                                            .collection('player')
                                            .doc(doc['id']);
                                        setState(() {
                                          deleteDoc.delete();
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icons.delete,
                        backgroundColor: Colors.red,
                      )
                    ],
                  ),
                  child: Card(
                      child: ListTile(
                    leading: CircleAvatar(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          doc['position'].toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    title: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(doc['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                          )),
                    ),
                    trailing: buildRowIcons(context, doc),
                  )),
                ))
            .toList());
  }

  Row buildRowIcons(BuildContext context, DocumentSnapshot<Object?> doc) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildIconButtonUpdate(context, doc),
        IconButton(
          onPressed: () {
            final Map<String, dynamic> data =
                doc.data() as Map<String, dynamic>;
            if (data.containsKey('notes')) {
              notesController.text = doc['notes'];
            }
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text(
                        '${doc['name']}:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      content: Container(
                        margin: const EdgeInsets.all(5.0),
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: Colors.white30)),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          controller: notesController,
                        ),
                      ),
                      actions: [
                        Row(
                          children: [
                            TextButton(
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              onPressed: () {
                                final updateDoc = FirebaseFirestore.instance
                                    .collection('player')
                                    .doc(doc['id']);
                                setState(() {
                                  updateDoc.set(
                                    {
                                      'notes': notesController.text,
                                    },
                                    SetOptions(merge: true),
                                  );
                                });
                                notesController.text = "";
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                notesController.text = "";
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ));
          },
          icon: const Icon(Icons.note_add_sharp),
        ),
      ],
    );
  }

  IconButton buildIconButtonUpdate(
      BuildContext context, DocumentSnapshot<Object?> doc) {
    return IconButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Update player position in the lineup:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                      )),
                  content: TextField(
                    controller: positionController,
                    decoration:
                        const InputDecoration(labelText: "New Position:"),
                    keyboardType: TextInputType.number,
                  ),
                  actions: [
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              if (positionController.text != '') {
                                int p = int.parse(positionController.text);
                                final updateDoc = FirebaseFirestore.instance
                                    .collection('player')
                                    .doc(doc['id']);
                                setState(() {
                                  updateDoc.update({
                                    'position': p,
                                  });
                                });
                                Navigator.pop(context);
                                positionController.clear();
                              }
                            },
                            child: const Text('Confirm',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 25,
                                ))),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 25,
                                ))),
                      ],
                    ),
                  ],
                ));
      },
      icon: const Icon(Icons.move_up),
    );
  }

  Future<QuerySnapshot<Object?>>? read() async {
    return await FirebaseFirestore.instance
        .collection('player')
        .orderBy('position')
        .where('teamId', isEqualTo: widget.teamId)
        .get();
  }
}
