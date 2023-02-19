import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tennislineapp/handlers/utils.dart';
import 'package:tennislineapp/models/coach.dart';
import 'package:tennislineapp/screens/intro_coach.dart';
import 'package:tennislineapp/screens/intro_player.dart';

import '../models/player.dart';

class SignUp extends StatefulWidget {
  final VoidCallback onClickedSignIn;

  const SignUp({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final emailController = TextEditingController();
  final passwordController1 = TextEditingController();
  final passwordController2 = TextEditingController();
  final nameController = TextEditingController();
  final teamIdController = TextEditingController();
  final List<bool> coachOrPlayerList = <bool>[true, false];
  bool isCoach = false;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController1.dispose();
    passwordController2.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: emailController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: passwordController1,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 5),
            TextField(
              controller: passwordController2,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 15),
            const Text(
              'Would you like to register as a player or coach?',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ToggleButtons(
                children: const <Widget>[
                  Text(
                    'Player',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Coach',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                constraints: const BoxConstraints(
                  minHeight: 55.0,
                  minWidth: 160.0,
                ),
                onPressed: (int index) => toggleButton(index),
                isSelected: coachOrPlayerList),
            const SizedBox(height: 5),
            Visibility(
              visible: !isCoach,
              child: TextField(
                controller: teamIdController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                    labelText: 'Team code provided by coach'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                signUpButton();
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Sign Up', style: TextStyle(fontSize: 24)),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(
              height: 30,
            ),
            RichText(
                text: TextSpan(
                    text: 'Already have an account? ',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignIn,
                      text: 'Sign In',
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue))
                ])),
            SizedBox(
              height: 30,
            )
          ],
        ),
      );

  Future signInButton() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController1.text.trim());
    if (FirebaseAuth.instance.currentUser!.displayName == '2') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IntroPlayer(),
        ),
      );
    } else if (FirebaseAuth.instance.currentUser!.displayName == '1') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IntroCoach(),
        ),
      );
    }
  }

  void wait() {
    Timer(const Duration(seconds: 5), () {
      FirebaseAuth.instance.signOut();
      signInButton();
    });
    Utils.showSnackBar('Wait a moment please...');
  }

  Future signUpButton() async {
    try {
      if (nameController.text != "") {
        if (isCoach) {
          if (passwordController1.text == passwordController2.text) {
            final user =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController1.text.trim(),
            );
            saveCoach();
            user.user?.updateDisplayName('1');
            wait();
            requestPermission();
          } else {
            Utils.showSnackBar('Please check your password or team code');
          }
        } else {
          await checkTeamFunc();
          if ((passwordController1.text == passwordController2.text) &&
              (checkTeam == true)) {
            final user =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController1.text.trim(),
            );
            savePlayer();
            user.user?.updateDisplayName('2');
            wait();
            requestPermission();
          } else {
            Utils.showSnackBar('Please check your password or team code');
          }
        }
      } else {
        Utils.showSnackBar('Please enter a name!');
      }
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    }
  }

  bool checkTeam = false;
  Future checkTeamFunc() async {
    if (teamIdController.text != "") {
      final docTeam = FirebaseFirestore.instance
          .collection("team")
          .doc(teamIdController.text);
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

  String myToken = '';
  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        myToken = token!;
        print('My token $myToken');
      });
    });
  }

  Future saveCoach() async {
    final docCoach = FirebaseFirestore.instance
        .collection('coach')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final coach = Coach(
      id: FirebaseAuth.instance.currentUser!.uid,
      name: nameController.text,
      email: emailController.text,
      token: myToken,
    );
    final json = coach.toJson();
    await docCoach.set(json);
  }

  Future savePlayer() async {
    final docPlayer = FirebaseFirestore.instance
        .collection('player')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final player = Player(
      id: FirebaseAuth.instance.currentUser!.uid,
      name: nameController.text,
      email: emailController.text,
      teamId: teamIdController.text,
      position: 00,
      challenge: false,
      token: myToken,
    );
    final json = player.toJson();
    await docPlayer.set(json);
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('ok');
    } else {
      print('Ops');
    }
  }

  void toggleButton(int index) {
    setState(() {
      for (int i = 0; i < coachOrPlayerList.length; i++) {
        coachOrPlayerList[i] = i == index;
        isCoach = i == index;
      }
    });
  }
}
