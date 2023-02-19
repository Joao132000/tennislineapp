import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoublesPlayerView extends StatefulWidget {
  final String teamId;
  final String teamSchool;
  final String teamType;
  final String teamLeague;

  const DoublesPlayerView(
      {Key? key,
      required this.teamId,
      required this.teamSchool,
      required this.teamType,
      required this.teamLeague})
      : super(key: key);

  @override
  State<DoublesPlayerView> createState() => _DoublesPlayerViewState();
}

class _DoublesPlayerViewState extends State<DoublesPlayerView> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Doubles Lineup'),
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
                  if (snapshot.data!.size == 0) {
                    return AlertDialog(
                      content: Text('No doubles for this team yet!'),
                      actions: [
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back))
                      ],
                    );
                  }
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return Column(
                    children: [
                      const SizedBox(
                        height: 20,
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
                      Text(widget.teamLeague,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: buildListView(documents, context),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '<-- Swipe to see singles lineup',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
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
            .map((doc) => Card(
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
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(doc['players'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 30,
                        )),
                  ),
                )))
            .toList());
  }

  Future<QuerySnapshot<Object?>>? read() async {
    return await FirebaseFirestore.instance
        .collection('doubles')
        .orderBy('position')
        .where('teamId', isEqualTo: widget.teamId)
        .get();
  }
}
