import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:tennislineapp/handlers/utils.dart';
import 'package:tennislineapp/screens/doubles_player_view.dart';
import 'package:tennislineapp/screens/intro_player.dart';
import 'package:tennislineapp/screens/posts.dart';

import '../handlers/admob_service.dart';
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
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IntroPlayer(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.lightbulb,
                  size: 30,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await getPlayer();
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text(
                              'Paste code below to move to a new team:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 25,
                              ),
                            ),
                            content: TextField(
                              controller: newTeamCodeController,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                  labelText: 'New Team Code'),
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
                                        final updateDoc = FirebaseFirestore
                                            .instance
                                            .collection('player')
                                            .doc(p?.id);
                                        setState(() {
                                          updateDoc.update({
                                            'teamId':
                                                newTeamCodeController.text,
                                            'position': 0,
                                            'challenge': false,
                                          });
                                        });
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SignInSignOut(),
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                          context: (context),
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                                'Please enter a valid code'),
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
                          ));
                },
                icon: const Icon(Icons.qr_code_2_sharp),
              ),
              IconButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(
                  Icons.logout,
                  size: 30,
                ),
              ),
            ],
          )
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
                  teamLeague: league!,
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
                      Text('${type!}\n${league!}',
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
                                                              sendPushMessage(
                                                                  doc['token']);
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

  void sendPushMessage(String token) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=	AAAAVCxeRzE:APA91bFxdrbqpLSAl-_iKGjL9sQkeTCmcZPTIS5_cYS6n95SY-dPeB7S7fPIwu43H-aFu1HxoP__BGtya4toyHqLZpPCvoLSjt7RVwCp0W3uQdvvOXXT14nxakxYojU9tdePPaFm_6j7',
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': '${p?.name} is challenging you!',
              'title': 'New Challenge!',
            },
            'notification': <String, dynamic>{
              'body': '${p?.name} is challenging you!',
              'title': 'New Challenge!',
              'android_channel_id': 'channelID'
            },
            'to': token,
          }));
    } catch (e) {
      if (kDebugMode) {
        print('error');
      }
    }
  }
}
