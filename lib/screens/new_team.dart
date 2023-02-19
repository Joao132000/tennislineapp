import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tennislineapp/handlers/signin_signout.dart';
import 'package:tennislineapp/handlers/utils.dart';

import '../handlers/admob_service.dart';
import '../models/team.dart';

class NewTeam extends StatefulWidget {
  const NewTeam({Key? key}) : super(key: key);

  @override
  State<NewTeam> createState() => _NewTeamState();
}

class _NewTeamState extends State<NewTeam> {
  final schoolController = TextEditingController();
  final leagueController = TextEditingController();
  String type = "Men's Team";

  @override
  void dispose() {
    schoolController.dispose();
    leagueController.dispose();
    super.dispose();
  }

  String dropDownType = "Men's Team";
  String dropDownPosition = '2';

  var itemsPosition = [
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

  // List of items in our dropdown menu
  var itemsType = [
    "Men's Team",
    "Women's Team",
    "Boy's Team",
    "Girl's Team",
    "Men's Senior",
    "Women's Senior",
    'Overall',
  ];
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
          title: const Text('New Team'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Create a New Team',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: schoolController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'School/Organization Name'),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: leagueController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'League'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Team category:   '),
                  DropdownButton(
                    menuMaxHeight: 200,
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
                        type = newValue;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Positions above allowed to challenge:    '),
                  DropdownButton(
                    menuMaxHeight: 200,
                    alignment: AlignmentDirectional.centerEnd,
                    value: dropDownPosition,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: itemsPosition.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropDownPosition = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  if ((leagueController.text != "") &&
                      (schoolController.text != "") &&
                      (type != "")) {
                    saveTeam();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInSignOut()),
                    );
                  } else {
                    Utils.showSnackBar('Please fill out all fields!');
                  }
                },
                style: ButtonStyle(
                    minimumSize:
                        MaterialStateProperty.all(const Size(200, 50))),
                child: const Text(
                  'Create',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
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

  Future saveTeam() async {
    final docCoach = FirebaseFirestore.instance.collection('team').doc();
    final coach = Team(
      id: docCoach.id,
      type: type,
      school: schoolController.text,
      league: leagueController.text,
      coachId: FirebaseAuth.instance.currentUser!.uid,
      challengePositions: int.parse(dropDownPosition),
    );
    final json = coach.toJson();
    await docCoach.set(json);
  }
}
