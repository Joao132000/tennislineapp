import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroPlayer extends StatefulWidget {
  @override
  State<IntroPlayer> createState() => _IntroPlayerState();
}

class _IntroPlayerState extends State<IntroPlayer> {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          titleWidget: Column(
            children: [
              SizedBox(
                height: 45,
              ),
              Text(
                'Welcome to Tennis LineApp!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Image.asset(
                'assets/images/BallAndRacquet.png',
                color: Colors.greenAccent,
                width: 160,
                height: 160,
                alignment: Alignment.centerRight,
              ),
            ],
          ),
          bodyWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Click next or swipe right to navigate through this tutorial. You can also skip '
                'and take a look at it later, just hit the light on the top of your screen.',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Image.asset(
                'assets/images/tutorial_light.png',
                width: 40,
                height: 40,
                alignment: Alignment.center,
              ),
            ],
          ),
        ),
        PageViewModel(
          titleWidget: Column(
            children: [
              SizedBox(
                height: 45,
              ),
              Text(
                'Lineup and Challenge',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
          bodyWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Your starting position will be '0'. "
                "Once your coach assign you a position, you can challenge another player by "
                "tapping the green racquet in front of their name.",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Image.asset(
                'assets/images/challenge.png',
                width: 120,
                height: 120,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "A match will be created and you can see it by clicking the button 'Team Matches'. "
                "You can set a time for the match, remove match, "
                "and add match result. Once completed match can't be edited",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Image.asset(
                'assets/images/match_card.png',
                width: 100,
                height: 100,
                alignment: Alignment.center,
              ),
            ],
          ),
        ),
        PageViewModel(
          titleWidget: Column(
            children: [
              SizedBox(
                height: 45,
              ),
              Text(
                'Doubles and Practice Matches',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
          bodyWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Your coach can add doubles teams, to see them just swipe right. However, challenges "
                "are not allowed for doubles, there are only practice matches for doubles.",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Coach can also add practice matches for singles and doubles. You can see "
                "practice matches for your team by swiping right in the matches screen.",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Image.asset(
                'assets/images/singles_practice.png',
                width: 180,
                height: 180,
                alignment: Alignment.center,
              ),
            ],
          ),
        ),
        PageViewModel(
          titleWidget: Column(
            children: [
              SizedBox(
                height: 45,
              ),
              Text(
                'Posts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
          bodyWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Click the button 'Team Posts' to see what is going on in your team. "
                "Coach and players can use the team chat to communicate.",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Image.asset(
                'assets/images/posts.png',
                width: 400,
                height: 400,
                alignment: Alignment.center,
              ),
            ],
          ),
        ),
        PageViewModel(
          titleWidget: Column(
            children: [
              SizedBox(
                height: 45,
              ),
              Text(
                'You are ready to start using Tennis LineApp!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
          bodyWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 20,
              ),
              Image.asset(
                'assets/images/legends.webp',
                //color: Colors.white,
                width: 200,
                height: 200,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Thank you for going through the instructions! "
                "Remember you can come back here anytime."
                " Have a great experience using Tennis LineApp!!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
      controlsMargin: EdgeInsets.only(bottom: 15),
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Text("Next"),
      done: const Text("Done"),
      onSkip: () => Navigator.pop(context),
      onDone: () {
        Navigator.pop(context);
      },
      baseBtnStyle: TextButton.styleFrom(
        backgroundColor: Colors.black12,
        minimumSize: Size(20, 20),
      ),
      skipStyle: TextButton.styleFrom(
          foregroundColor: Colors.red, textStyle: TextStyle(fontSize: 25)),
      doneStyle: TextButton.styleFrom(
          foregroundColor: Colors.green, textStyle: TextStyle(fontSize: 25)),
      nextStyle: TextButton.styleFrom(
          foregroundColor: Colors.blue, textStyle: TextStyle(fontSize: 25)),
    );
  }
}
