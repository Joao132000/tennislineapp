import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tennislineapp/models/doubles.dart';

class TeamDoubles extends StatefulWidget {
  final String teamId;
  final String teamSchool;
  final String teamType;

  const TeamDoubles({
    Key? key,
    required this.teamId,
    required this.teamSchool,
    required this.teamType,
  }) : super(key: key);

  @override
  State<TeamDoubles> createState() => _TeamDoublesState();
}

class _TeamDoublesState extends State<TeamDoubles> {
  final positionController = TextEditingController();
  var selectedPlayer1;
  var selectedPlayer2;
  @override
  void dispose() {
    positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'Team Lineup',
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 0) {
            Navigator.pop(context);
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.arrow_back,
                            size: 15,
                            color: Colors.grey,
                          ),
                          Text(
                            'Singles lineup',
                            style: TextStyle(color: Colors.grey),
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
                      Text('Doubles ${widget.teamType}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        child: buildListView(documents, context),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(
                            height: 70,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent.shade200,
                              minimumSize: const Size(150, 40),
                              // foreground
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => StatefulBuilder(
                                  builder: (context, setState) => AlertDialog(
                                    title: const Text('New doubles team:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 25,
                                        )),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('player')
                                                .where('teamId',
                                                    isEqualTo: widget.teamId)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              } else {
                                                List<DropdownMenuItem> items =
                                                    [];
                                                for (int i = 0;
                                                    i <
                                                        snapshot
                                                            .data!.docs.length;
                                                    i++) {
                                                  DocumentSnapshot snap =
                                                      snapshot.data!.docs[i];
                                                  items.add(
                                                    DropdownMenuItem(
                                                      child: Text(
                                                        snap['name'],
                                                      ),
                                                      value: snap['name'],
                                                    ),
                                                  );
                                                }
                                                return Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        DropdownButton(
                                                          menuMaxHeight: 200,
                                                          items: items,
                                                          onChanged:
                                                              (dynamic value) {
                                                            setState(() {
                                                              selectedPlayer1 =
                                                                  value;
                                                            });
                                                          },
                                                          value:
                                                              selectedPlayer1,
                                                          isExpanded: false,
                                                          hint: Text(
                                                              'Choose a player'),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        DropdownButton(
                                                          menuMaxHeight: 200,
                                                          items: items,
                                                          onChanged:
                                                              (dynamic value) {
                                                            setState(() {
                                                              selectedPlayer2 =
                                                                  value;
                                                            });
                                                          },
                                                          value:
                                                              selectedPlayer2,
                                                          isExpanded: false,
                                                          hint: Text(
                                                              'Choose a player'),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              }
                                            },
                                          ),
                                          TextField(
                                            controller: positionController,
                                            decoration: const InputDecoration(
                                                labelText: "Position:"),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: ((selectedPlayer1 !=
                                                        selectedPlayer2) &&
                                                    (selectedPlayer2 != null) &&
                                                    (selectedPlayer1 != null))
                                                ? () {
                                                    if (positionController
                                                            .text !=
                                                        '') {
                                                      saveDouble();
                                                      Navigator.pop(context);
                                                      selectedPlayer2 = null;
                                                      selectedPlayer1 = null;
                                                      positionController.text =
                                                          '';
                                                    } else {
                                                      showDialog(
                                                        context: (context),
                                                        builder: (context) =>
                                                            AlertDialog(
                                                          title: Text(
                                                              'Please enter position'),
                                                          titlePadding:
                                                              EdgeInsets.all(
                                                                  10),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                : null,
                                            child: const Text(
                                              'Confirm',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              selectedPlayer2 = null;
                                              selectedPlayer1 = null;
                                              positionController.text = '';
                                            },
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Add Doubles Team',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
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

  ListView buildListView(
      List<DocumentSnapshot<Object?>> documents, BuildContext context) {
    return ListView(
        children: documents
            .map(
              (doc) => Slidable(
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'Are you sure you want to delete this double?',
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
                                          .collection('doubles')
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
                      child: Text(
                        doc['position'].toString(),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    title: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(doc['players'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                          )),
                    ),
                    trailing: buildRowIcons(context, doc),
                  ),
                ),
              ),
            )
            .toList());
  }

  Row buildRowIcons(BuildContext context, DocumentSnapshot<Object?> doc) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildIconButtonUpdate(context, doc),
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
                  title: const Text('Update doubles position in the lineup:',
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
                              int p = int.parse(positionController.text);
                              final updateDoc = FirebaseFirestore.instance
                                  .collection('doubles')
                                  .doc(doc['id']);
                              setState(() {
                                updateDoc.update({
                                  'position': p,
                                });
                              });
                              Navigator.pop(context);
                              positionController.clear();
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

  Future saveDouble() async {
    final docDoubles = FirebaseFirestore.instance.collection('doubles').doc();
    final doubles = Doubles(
      id: docDoubles.id,
      teamId: widget.teamId,
      players: '${selectedPlayer1}/${selectedPlayer2}',
      position: int.parse(positionController.text),
    );
    final json = doubles.toJson();
    await docDoubles.set(json);
  }

  Future<QuerySnapshot<Object?>>? read() async {
    return await FirebaseFirestore.instance
        .collection('doubles')
        .orderBy('position')
        .where('teamId', isEqualTo: widget.teamId)
        .get();
  }
}
