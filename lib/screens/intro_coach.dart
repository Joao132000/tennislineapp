import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroCoach extends StatefulWidget {
  @override
  State<IntroCoach> createState() => _IntroCoachState();
}

class _IntroCoachState extends State<IntroCoach> {
  // 1. Define a `GlobalKey` as part of the parent widget's state

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      dotsFlex: 2,
      // 2. Pass that key to the `IntroductionScreen` `key` param
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
                'Teams and Players',
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
                "Create a new team by clicking the button 'New Team' on the bottom of the main screen. ",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Image.asset(
                'assets/images/team_card.png',
                width: 130,
                height: 130,
                alignment: Alignment.center,
              ),
              Text(
                "After team is created you will be able to see "
                "the new team in the main screen(like the one above). Then, you can copy and send the team code"
                " to your players, so they can enroll in your team.",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/team_code.png',
                width: 170,
                height: 170,
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
                'Lineup: Singles and Doubles',
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
                "Navigate to a team by tapping on the team card on the main screen. New players will have position '0' until you "
                "set a position. The coach can update the lineup anytime. ",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Image.asset(
                'assets/images/lineup_coach.png',
                width: 140,
                height: 140,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "By swiping right "
                "you can manage doubles, to add a new double just hit 'Add Doubles Team' at the bottom "
                "of the screen.",
                style: TextStyle(
                  fontSize: 15,
                ),
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
                'Matches: Challenge and Practice',
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
                "Players can challenge each other, whenever a player challenges another player "
                "a match will be created, and you can see it by clicking at 'Team Matches'",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Image.asset(
                'assets/images/challenge_matches.png',
                width: 140,
                height: 140,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "In addition, the coach can also add practice matches. Navigate to practice matches screen by "
                "swiping right on the challenge matches screen. "
                "Players in that team will be able to see the practice matches, but they can't edit it",
                style: TextStyle(
                  fontSize: 15,
                ),
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
        minimumSize: Size(40, 40),
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
