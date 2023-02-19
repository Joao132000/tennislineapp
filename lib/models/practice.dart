import 'package:cloud_firestore/cloud_firestore.dart';

class Practice {
  String id;
  final String result;
  final String? teamId;
  final String? player1name;
  final String player2name;
  final Timestamp timeStamp;
  final String? winner;
  final String? checkSinglesDoubles;
  final String date;

  Practice({
    this.id = '',
    required this.result,
    required this.teamId,
    required this.player1name,
    required this.player2name,
    required this.timeStamp,
    required this.winner,
    required this.date,
    required this.checkSinglesDoubles,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'result': result,
        'teamId': teamId,
        'player1name': player1name,
        'player2name': player2name,
        'timeStamp': timeStamp,
        'winner': winner,
        'checkSinglesDoubles': checkSinglesDoubles,
        'date': date,
      };
  static Practice fromJson(Map<String, dynamic> json) => Practice(
        id: (json['id'] ?? '').toString(),
        result: (json['result'] ?? '').toString(),
        teamId: (json['teamId'] ?? '').toString(),
        player2name: (json['player2name'] ?? '').toString(),
        player1name: (json['player1name'] ?? '').toString(),
        timeStamp: (json['timeStamp']),
        checkSinglesDoubles: json['checkSinglesDoubles'],
        winner: (json['winner'] ?? '').toString(),
        date: (json['date'] ?? '').toString(),
      );
}
