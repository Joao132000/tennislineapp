import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../models/practice.dart';

class PracticeMatchCoach extends StatefulWidget {
  const PracticeMatchCoach({Key? key, required this.teamId}) : super(key: key);
  final String teamId;

  @override
  State<PracticeMatchCoach> createState() => _PracticeMatchCoachState();
}

class _PracticeMatchCoachState extends State<PracticeMatchCoach> {
  String check = '';
  String dropDownType = "Singles";
  final resultController = TextEditingController();
  var selectedPlayer1;
  var selectedPlayer2;
  var selectedPlayer3;
  var selectedPlayer4;
  String formattedDate = '';
  String? winner;
  String? radioButton;
  var playerNameFilter = 'All';
  var itemsType = [
    "Singles",
    "Doubles",
  ];

  @override
  void dispose() {
    resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Team Matches'),
        ),
        body: GestureDetector(
          onPanUpdate: (details) async {
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
                    List dataList =
                        snapshot.data!.docs.map((e) => e.data()).toList();
                    List dataListPlayer = dataList
                        .where((element) =>
                            element['player1name'].contains(playerNameFilter))
                        .toList();
                    List dataListPlayerMerge = dataList
                        .where((element) =>
                            element['player2name'].contains(playerNameFilter))
                        .toList();
                    dataListPlayer.addAll(dataListPlayerMerge);
                    dataListPlayer.sort(
                        (a, b) => b['timeStamp'].compareTo(a['timeStamp']));

                    return Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Practice Matches',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton(
                                alignment: AlignmentDirectional.bottomStart,
                                value: dropDownType,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: itemsType.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropDownType = newValue!;
                                  });
                                },
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('player')
                                    .where('teamId', isEqualTo: widget.teamId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    List<DropdownMenuItem> items = [];
                                    items.add(
                                      DropdownMenuItem(
                                        child: Text(
                                          'All',
                                        ),
                                        value: 'All',
                                      ),
                                    );
                                    for (int i = 0;
                                        i < snapshot.data!.docs.length;
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
                                              MainAxisAlignment.start,
                                          children: [
                                            DropdownButton(
                                              menuMaxHeight: 200,
                                              items: items,
                                              onChanged: (dynamic value) {
                                                setState(() {
                                                  playerNameFilter = value;
                                                });
                                              },
                                              value: playerNameFilter,
                                              isExpanded: false,
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: (playerNameFilter == "All")
                                ? dataList.length
                                : dataListPlayer.length,
                            itemBuilder: (BuildContext context, int index) {
                              final doc;
                              if (playerNameFilter == "All") {
                                doc = dataList[index];
                              } else {
                                doc = dataListPlayer[index];
                              }
                              return buildCard(context, doc);
                            },
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  '<-- Swipe to see challenge matches',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              verticalDirection: VerticalDirection.up,
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
                                    showDialog(
                                      context: context,
                                      builder: (context) => StatefulBuilder(
                                        builder: (context, setState) =>
                                            AlertDialog(
                                          title:
                                              const Text('New Practice Match:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 25,
                                                  )),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                StreamBuilder<QuerySnapshot>(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('player')
                                                      .where('teamId',
                                                          isEqualTo:
                                                              widget.teamId)
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    } else {
                                                      List<DropdownMenuItem>
                                                          items = [];
                                                      for (int i = 0;
                                                          i <
                                                              snapshot.data!
                                                                  .docs.length;
                                                          i++) {
                                                        DocumentSnapshot snap =
                                                            snapshot
                                                                .data!.docs[i];
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
                                                                menuMaxHeight:
                                                                    200,
                                                                items: items,
                                                                onChanged:
                                                                    (dynamic
                                                                        value) {
                                                                  setState(() {
                                                                    selectedPlayer1 =
                                                                        value;
                                                                  });
                                                                },
                                                                value:
                                                                    selectedPlayer1,
                                                                isExpanded:
                                                                    false,
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
                                                                menuMaxHeight:
                                                                    200,
                                                                items: items,
                                                                onChanged:
                                                                    (dynamic
                                                                        value) {
                                                                  setState(() {
                                                                    selectedPlayer2 =
                                                                        value;
                                                                  });
                                                                },
                                                                value:
                                                                    selectedPlayer2,
                                                                isExpanded:
                                                                    false,
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
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: ((selectedPlayer1 !=
                                                              selectedPlayer2) &&
                                                          (selectedPlayer2 !=
                                                              null) &&
                                                          (selectedPlayer1 !=
                                                              null))
                                                      ? () {
                                                          check = 'Singles';
                                                          formattedDate = DateFormat(
                                                                  'M/dd/yyyy - kk:mm')
                                                              .format(Timestamp
                                                                      .now()
                                                                  .toDate());
                                                          saveMatchSingles();
                                                          Navigator.pop(
                                                              context);
                                                          selectedPlayer1 =
                                                              null;
                                                          selectedPlayer2 =
                                                              null;
                                                        }
                                                      : null,
                                                  child: const Text(
                                                    'Confirm',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 25,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    selectedPlayer1 = null;
                                                    selectedPlayer2 = null;
                                                  },
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                    'Add Singles',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                const SizedBox(
                                  height: 50,
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
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => StatefulBuilder(
                                        builder: (context, setState) =>
                                            AlertDialog(
                                          title:
                                              const Text('New Practice Match:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 25,
                                                  )),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                StreamBuilder<QuerySnapshot>(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('player')
                                                      .where('teamId',
                                                          isEqualTo:
                                                              widget.teamId)
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    } else {
                                                      List<DropdownMenuItem>
                                                          items = [];
                                                      for (int i = 0;
                                                          i <
                                                              snapshot.data!
                                                                  .docs.length;
                                                          i++) {
                                                        DocumentSnapshot snap =
                                                            snapshot
                                                                .data!.docs[i];
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
                                                              Text(
                                                                  "Doubles 1: "),
                                                              DropdownButton(
                                                                menuMaxHeight:
                                                                    200,
                                                                items: items,
                                                                onChanged:
                                                                    (dynamic
                                                                        value) {
                                                                  setState(() {
                                                                    selectedPlayer1 =
                                                                        value;
                                                                  });
                                                                },
                                                                value:
                                                                    selectedPlayer1,
                                                                isExpanded:
                                                                    false,
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
                                                              Text(
                                                                  "Doubles 1: "),
                                                              DropdownButton(
                                                                menuMaxHeight:
                                                                    200,
                                                                items: items,
                                                                onChanged:
                                                                    (dynamic
                                                                        value) {
                                                                  setState(() {
                                                                    selectedPlayer2 =
                                                                        value;
                                                                  });
                                                                },
                                                                value:
                                                                    selectedPlayer2,
                                                                isExpanded:
                                                                    false,
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
                                                              Text(
                                                                  "Doubles 2: "),
                                                              DropdownButton(
                                                                menuMaxHeight:
                                                                    200,
                                                                items: items,
                                                                onChanged:
                                                                    (dynamic
                                                                        value) {
                                                                  setState(() {
                                                                    selectedPlayer3 =
                                                                        value;
                                                                  });
                                                                },
                                                                value:
                                                                    selectedPlayer3,
                                                                isExpanded:
                                                                    false,
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
                                                              Text(
                                                                  "Doubles 2: "),
                                                              DropdownButton(
                                                                menuMaxHeight:
                                                                    200,
                                                                items: items,
                                                                onChanged:
                                                                    (dynamic
                                                                        value) {
                                                                  setState(() {
                                                                    selectedPlayer4 =
                                                                        value;
                                                                  });
                                                                },
                                                                value:
                                                                    selectedPlayer4,
                                                                isExpanded:
                                                                    false,
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
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: ((selectedPlayer1 !=
                                                              selectedPlayer2) &&
                                                          (selectedPlayer1 !=
                                                              selectedPlayer3) &&
                                                          (selectedPlayer1 !=
                                                              selectedPlayer4) &&
                                                          (selectedPlayer2 !=
                                                              selectedPlayer3) &&
                                                          (selectedPlayer3 !=
                                                              selectedPlayer4) &&
                                                          (selectedPlayer2 !=
                                                              selectedPlayer4) &&
                                                          (selectedPlayer2 !=
                                                              null) &&
                                                          (selectedPlayer1 !=
                                                              null) &&
                                                          (selectedPlayer3 !=
                                                              null) &&
                                                          (selectedPlayer4 !=
                                                              null))
                                                      ? () {
                                                          check = 'Doubles';
                                                          formattedDate = DateFormat(
                                                                  'M/dd/yyyy - kk:mm')
                                                              .format(Timestamp
                                                                      .now()
                                                                  .toDate());
                                                          saveMatchDoubles();
                                                          Navigator.pop(
                                                              context);
                                                          selectedPlayer1 =
                                                              null;
                                                          selectedPlayer2 =
                                                              null;
                                                          selectedPlayer3 =
                                                              null;
                                                          selectedPlayer4 =
                                                              null;
                                                        }
                                                      : null,
                                                  child: const Text(
                                                    'Confirm',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 25,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    selectedPlayer1 = null;
                                                    selectedPlayer3 = null;
                                                    selectedPlayer4 = null;
                                                    selectedPlayer2 = null;
                                                  },
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                    'Add Doubles',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            )
                          ],
                        )
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return const Text('Something went wrong!');
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
        ),
      );

  Slidable buildCard(BuildContext context, Map<String, dynamic> doc) {
    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'Are you sure you want to delete this practice match?',
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
                            final deleteDoc = FirebaseFirestore.instance
                                .collection('practice')
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
        color: ((doc['winner']) != "") ? Colors.green : null,
        child: ListTile(
          title: (doc['checkSinglesDoubles'] == 'Singles')
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['date'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.white60),
                    ),
                    Text(
                      '${doc['player1name'].toString()} x ${doc['player2name'].toString()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['date'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.white60),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${doc['player1name'].toString()} x',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '${doc['player2name'].toString()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          subtitle: Text(
            '${doc['winner']} ${doc['result']}',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 35,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  doc['player1name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                                leading: Radio(
                                  value: 'player1',
                                  groupValue: radioButton,
                                  onChanged: (value) {
                                    setState(() {
                                      radioButton = value.toString();
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  doc['player2name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                                leading: Radio(
                                  value: 'player2',
                                  groupValue: radioButton,
                                  onChanged: (value) {
                                    setState(() {
                                      radioButton = value.toString();
                                    });
                                  },
                                ),
                              ),
                              TextField(
                                controller: resultController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                    labelText: 'Match Result'),
                              ),
                            ],
                          ),
                        );
                      }),
                      title: const Text('Match Result:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 25,
                          )),
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
                                  if (resultController.text != "") {
                                    final updateDoc = FirebaseFirestore.instance
                                        .collection('practice')
                                        .doc(doc['id']);
                                    setState(() {
                                      updateDoc.update({
                                        'result': resultController.text,
                                      });
                                    });
                                    if (radioButton == 'player1') {
                                      setState(() {
                                        updateDoc.update({
                                          'winner': doc['player1name'],
                                        });
                                      });
                                    } else if (radioButton == 'player2') {
                                      setState(() {
                                        updateDoc.update({
                                          'winner': doc['player2name'],
                                        });
                                      });
                                    }
                                    Navigator.pop(context);
                                  } else {
                                    showDialog(
                                      context: (context),
                                      builder: (context) => AlertDialog(
                                        title:
                                            Text('Please enter match result'),
                                        titlePadding: EdgeInsets.all(10),
                                      ),
                                    );
                                  }
                                  radioButton = null;
                                  winner = '';
                                  resultController.text = '';
                                }),
                            TextButton(
                                onPressed: () {
                                  winner = '';
                                  resultController.text = '';
                                  radioButton = null;
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ))),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.scoreboard_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future saveMatchSingles() async {
    final docSinglesMatch =
        FirebaseFirestore.instance.collection('practice').doc();
    final practice = Practice(
      id: docSinglesMatch.id,
      teamId: widget.teamId,
      player1name: selectedPlayer1,
      player2name: selectedPlayer2,
      result: '',
      timeStamp: Timestamp.now(),
      winner: '',
      checkSinglesDoubles: check,
      date: formattedDate,
    );
    final json = practice.toJson();
    await docSinglesMatch.set(json);
  }

  Future saveMatchDoubles() async {
    final docDoublesMatch =
        FirebaseFirestore.instance.collection('practice').doc();
    final practice = Practice(
      id: docDoublesMatch.id,
      teamId: widget.teamId,
      player1name: "${selectedPlayer1}/${selectedPlayer2}",
      player2name: "${selectedPlayer3}/${selectedPlayer4}",
      result: '',
      timeStamp: Timestamp.now(),
      winner: '',
      checkSinglesDoubles: check,
      date: formattedDate,
    );
    final json = practice.toJson();
    await docDoublesMatch.set(json);
  }

  Future<QuerySnapshot<Object?>>? read() async {
    return await FirebaseFirestore.instance
        .collection('practice')
        .orderBy('timeStamp', descending: true)
        .where('teamId', isEqualTo: widget.teamId)
        .where('checkSinglesDoubles', isEqualTo: dropDownType)
        .get();
  }
}
