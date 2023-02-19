import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tennislineapp/screens/practice_match_coach.dart';

import '../handlers/admob_service.dart';

class MatchesCoach extends StatefulWidget {
  const MatchesCoach({Key? key, required this.teamId}) : super(key: key);
  final String teamId;

  @override
  State<MatchesCoach> createState() => _MatchesCoachState();
}

class _MatchesCoachState extends State<MatchesCoach> {
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Team Matches'),
        ),
        body: GestureDetector(
          onPanUpdate: (details) async {
            if (details.delta.dx < 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PracticeMatchCoach(
                    teamId: widget.teamId,
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
                    final List<DocumentSnapshot> documents =
                        snapshot.data!.docs;
                    return Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('Challenge Matches',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 30,
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                            child: ListView(
                                children: documents
                                    .map((doc) => buildCard(context, doc))
                                    .toList())),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Swipe to see practice matches -->',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(
                              width: 20,
                              height: 60,
                            ),
                          ],
                        ),
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

  Card buildCard(BuildContext context, DocumentSnapshot<Object?> doc) {
    return Card(
      color: ((doc['result']) != "") ? Colors.green : null,
      child: ListTile(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Column(
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
          ),
        ),
        subtitle: Text(
          '${doc['winner']} ${doc['result']}',
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Future<QuerySnapshot<Object?>>? read() async {
    return await FirebaseFirestore.instance
        .collection('match')
        .orderBy('timeStamp', descending: true)
        .where('teamId', isEqualTo: widget.teamId)
        .get();
  }
}
