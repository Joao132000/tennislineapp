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
  var playerNameFilter = 'All';
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
                        const Text('Challenge Matches',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 30,
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
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
                        const SizedBox(
                          height: 10,
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

  Card buildCard(BuildContext context, Map<String, dynamic> doc) {
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
