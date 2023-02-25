import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tennislineapp/handlers/admob_service.dart';
import 'package:tennislineapp/handlers/signin_signout.dart';
import 'package:tennislineapp/screens/players_by_team.dart';

import '../handlers/MenuItem.dart';
import '../models/coach.dart';
import 'intro_coach.dart';
import 'new_team.dart';

class MainCoach extends StatefulWidget {
  const MainCoach({Key? key}) : super(key: key);

  @override
  State<MainCoach> createState() => _MainCoachState();
}

class _MainCoachState extends State<MainCoach> {
  Coach? coach;
  BannerAd? banner;
  @override
  void initState() {
    super.initState();
    createBannerAd();
  }

  void createBannerAd() {
    banner = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: AdMobService.bannerAdUnit!,
      listener: AdMobService.bannerListener,
      request: const AdRequest(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hey coach, welcome back!'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<Item>(
            icon: Icon(Icons.menu),
            onSelected: (value) async {
              if (value == Item.item1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IntroCoach(),
                  ),
                );
              } else if (value == Item.item2) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Would like to remove you account permanently?\nIt is not possible to undo this action.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
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
                              FirebaseAuth.instance.currentUser!.delete();
                              final deleteDoc = FirebaseFirestore.instance
                                  .collection('coach')
                                  .doc(FirebaseAuth.instance.currentUser!.uid);
                              setState(() {
                                deleteDoc.delete();
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignInSignOut()),
                              );
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
              } else if (value == Item.item3) {
                FirebaseAuth.instance.signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Tutorial'),
                value: Item.item1,
              ),
              PopupMenuItem(
                child: Text('Delete Account'),
                value: Item.item2,
              ),
              PopupMenuItem(
                child: Text('Log out'),
                value: Item.item3,
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: read(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<DocumentSnapshot> documents = snapshot.data!.docs;
              return Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Teams",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView(
                        children: documents
                            .map((doc) => buildGestureDetector(context, doc))
                            .toList()),
                  ),
                  const NewTeamButton(),
                  const SizedBox(
                    height: 10,
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
      bottomNavigationBar: banner == null
          ? Container()
          : Container(
              margin: EdgeInsets.only(bottom: 2),
              height: 50,
              child: AdWidget(
                ad: banner!,
              ),
            ),
    );
  }

  GestureDetector buildGestureDetector(
      BuildContext context, DocumentSnapshot<Object?> doc) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayersByTeam(
              teamId: doc['id'],
              teamSchool: doc['school'],
              teamType: doc['type'],
              teamLeague: doc['league'],
            ),
          ),
        );
      },
      child: Card(
        child: Slidable(
          endActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        'Are you sure you want to delete this team?',
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
                                    .collection('team')
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
          child: ListTile(
            title: Text(
              doc['school'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 25,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    buildShowDialog(context, doc);
                  },
                  icon: const Icon(Icons.qr_code_2_sharp),
                ),
              ],
            ),
            subtitle: Text('${doc['type']}\n${doc['league']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                )),
          ),
        ),
      ),
    );
  }

  Future<dynamic> buildShowDialog(
      BuildContext context, DocumentSnapshot<Object?> doc) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Team Code:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  )),
              content: Text(doc['id'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        ))),
                TextButton(
                    onPressed: () {
                      final value = ClipboardData(text: doc['id']);
                      Clipboard.setData(value);
                      Navigator.pop(context);
                    },
                    child: const Text('Copy',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        ))),
              ],
            ));
  }

  Future<Coach> getCoach() async {
    final docCoach = FirebaseFirestore.instance
        .collection("coach")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final snapshot = await docCoach.get();
    return Coach.fromJson(snapshot.data()!);
  }

  Future<QuerySnapshot<Object?>>? read() async {
    coach = await getCoach();
    return await FirebaseFirestore.instance
        .collection('team')
        .where('coachId', isEqualTo: coach?.id)
        .get();
  }
}

class NewTeamButton extends StatelessWidget {
  const NewTeamButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 5,
        ),
        const SizedBox(
          width: 190,
        ),
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
              MaterialPageRoute(builder: (context) => const NewTeam()),
            );
          },
          child: const Text(
            'New Team',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ],
    );
  }
}
