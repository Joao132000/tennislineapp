import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tennislineapp/handlers/MenuItem.dart';
import 'package:tennislineapp/handlers/utils.dart';
import 'package:tennislineapp/screens/doubles_player_view.dart';
import 'package:tennislineapp/screens/intro_player.dart';
import 'package:tennislineapp/screens/posts.dart';

import '../handlers/admob_service.dart';
import '../handlers/notification.dart';
import '../handlers/signin_signout.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../models/team.dart';
import 'matches.dart';

class MainPlayer extends StatefulWidget {
  @override
  State<MainPlayer> createState() => _MainPlayerState();
}

class _MainPlayerState extends State<MainPlayer> {
  String? type;
  String? university;
  String? league;
  int challengePosition = 2;
  Player? p;
  final newTeamCodeController = TextEditingController();
  bool checkTeam = false;
  Random random = new Random();
  final id = FirebaseAuth.instance.currentUser!;

  Future checkTeamFunc() async {
    if (newTeamCodeController.text != "") {
      final docTeam = FirebaseFirestore.instance
          .collection("team")
          .doc(newTeamCodeController.text);
      final snapshot = await docTeam.get();
      if (snapshot.exists) {
        checkTeam = true;
      } else {
        checkTeam = false;
      }
    } else {
      checkTeam = false;
    }
  }

  @override
  void initState() {
    createInterstitialAd();
    super.initState();
  }

  InterstitialAd? interstitialAd;
  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdMobService.interstitialAdUnit!,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => interstitialAd = ad,
          onAdFailedToLoad: (LoadAdError error) => interstitialAd = null,
        ));
  }

  void showInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        createInterstitialAd();
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        createInterstitialAd();
      });
      interstitialAd!.show();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(
          'Singles Lineup',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<Item>(
            icon: Icon(Icons.menu),
            onSelected: (value) async {
              if (value == Item.item1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IntroPlayer(),
                  ),
                );
              } else if (value == Item.item2) {
                await getPlayer();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Paste code below to move to a new team:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    content: TextField(
                      controller: newTeamCodeController,
                      textInputAction: TextInputAction.done,
                      decoration:
                          const InputDecoration(labelText: 'New Team Code'),
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
                            onPressed: () async {
                              await checkTeamFunc();
                              if (checkTeam) {
                                final updateDoc = FirebaseFirestore.instance
                                    .collection('player')
                                    .doc(p?.id);
                                setState(() {
                                  updateDoc.update({
                                    'teamId': newTeamCodeController.text,
                                    'position': 0,
                                    'challenge': false,
                                  });
                                });
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInSignOut(),
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: (context),
                                  builder: (context) => AlertDialog(
                                    title: Text('Please enter a valid code'),
                                    titlePadding: EdgeInsets.all(10),
                                  ),
                                );
                              }
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
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Would like to remove your account permanently?\nIt is not possible to undo this action.',
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
                              final deleteDoc = FirebaseFirestore.instance
                                  .collection('player')
                                  .doc(id.uid);
                              setState(() {
                                deleteDoc.delete();
                              });
                              id.delete();
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
              } else if (value == Item.item4) {
                FirebaseAuth.instance.signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Tutorial'),
                value: Item.item1,
              ),
              PopupMenuItem(
                child: Text('New Team'),
                value: Item.item2,
              ),
              PopupMenuItem(
                child: Text('Delete Account'),
                value: Item.item3,
              ),
              PopupMenuItem(
                child: Text('Log out'),
                value: Item.item4,
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) async {
          if (details.delta.dx < 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoublesPlayerView(
                  teamId: p!.teamId,
                  teamSchool: university!,
                  teamType: type!,
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
                      const SizedBox(
                        height: 20,
                      ),
                      Text(university!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 25,
                          )),
                      Text('Singles ${type!}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: ListView(
                          children: documents
                              .map(
                                (doc) => Card(
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
                                    trailing: IconButton(
                                      disabledColor: doc['challenge']
                                          ? Colors.red
                                          : Colors.green,
                                      color: doc['challenge']
                                          ? Colors.red
                                          : Colors.green,
                                      iconSize: 40,
                                      onPressed: ((((doc['challenge'] ==
                                                          false) &&
                                                      ((doc['id']) !=
                                                          (FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid))) &&
                                                  (doc['position'] != 0)) &&
                                              (p?.challenge == false))
                                          ? () {
                                              final challengePositionCheck =
                                                  p!.position - doc['position'];
                                              if ((challengePositionCheck <=
                                                      challengePosition) &&
                                                  (challengePositionCheck >
                                                      0)) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: Text(
                                                      'Are you sure you want to challenge ${doc['name']}?',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              final String
                                                                  pushTitle =
                                                                  "New Challenge!!!";
                                                              final String
                                                                  pushBody =
                                                                  '${p?.name} is challenging you!';
                                                              Navigator.pop(
                                                                  context);
                                                              final playerChallenged =
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'player')
                                                                      .doc(doc[
                                                                          'id']);
                                                              final playerChallenging = FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'player')
                                                                  .doc(FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid);
                                                              setState(() {
                                                                playerChallenging
                                                                    .update({
                                                                  'challenge':
                                                                      true,
                                                                });
                                                                playerChallenged
                                                                    .update({
                                                                  'challenge':
                                                                      true,
                                                                });
                                                              });
                                                              saveMatch(
                                                                  doc['id'],
                                                                  doc['name'],
                                                                  doc['position']);
                                                              NotificationPush
                                                                  .sendPushMessage(
                                                                      doc['token'],
                                                                      pushTitle,
                                                                      pushBody);
                                                            },
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                Utils.showSnackBar(
                                                    'You can only challenge players ${challengePosition} position(s) above you');
                                              }
                                            }
                                          : null,
                                      icon: const Icon(
                                          Icons.sports_tennis_outlined),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Swipe to see doubles lineup -->',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(
                                width: 20,
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
                                  final int randomNumberAd = random.nextInt(3);
                                  if (randomNumberAd == 0) {
                                    showInterstitialAd();
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Matches()),
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
                                width: 10,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blueAccent.shade200,
                                  minimumSize: const Size(150, 40),
                                  // foreground
                                ),
                                onPressed: () async {
                                  final int randomNumberAd = random.nextInt(3);
                                  if (randomNumberAd == 0) {
                                    showInterstitialAd();
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Posts(
                                        teamId: p?.teamId,
                                        userName: p?.name,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Team Posts',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
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
                  return Center(
                    child: const Text(
                      'Something went wrong or you do not belong to any team at the moment!',
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ));

  Future<Player> getPlayer() async {
    final docPlayer = FirebaseFirestore.instance
        .collection("player")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final snapshot = await docPlayer.get();
    return Player.fromJson(snapshot.data()!);
  }

  Future<QuerySnapshot<Object?>>? read() async {
    p = await getPlayer();
    final docTeam =
        FirebaseFirestore.instance.collection("team").doc(p?.teamId);
    final snapshotTeam = await docTeam.get();
    final t = Team.fromJson(snapshotTeam.data()!);
    league = t.league;
    type = t.type;
    university = t.school;
    challengePosition = t.challengePositions;
    return await FirebaseFirestore.instance
        .collection('player')
        .orderBy('position')
        .where('teamId', isEqualTo: p?.teamId)
        .get();
  }

  Future saveMatch(
      String player2id, String player2name, int player2position) async {
    final docMatch = FirebaseFirestore.instance.collection('match').doc();
    final match = Match(
      player1id: p?.id,
      player2id: player2id,
      date: '',
      result: '',
      teamId: p?.teamId,
      player1name: p?.name,
      player2name: player2name,
      id: docMatch.id,
      player1position: p?.position,
      player2position: player2position,
      timeStamp: DateTime.now().microsecondsSinceEpoch,
      winner: '',
    );
    final json = match.toJson();
    await docMatch.set(json);
  }
}
