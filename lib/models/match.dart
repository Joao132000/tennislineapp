class Match {
  String id;
  final String? player1id;
  final String player2id;
  final String date;
  final String result;
  final String? teamId;
  final String? player1name;
  final String player2name;
  final double? player1position;
  final int player2position;
  final int timeStamp;
  final String? winner;

  Match(
      {this.id = '',
      required this.player1id,
      required this.player2id,
      required this.date,
      required this.result,
      required this.teamId,
      required this.player1name,
      required this.player2name,
      required this.player1position,
      required this.player2position,
      required this.timeStamp,
      required this.winner});
  Map<String, dynamic> toJson() => {
        'id': id,
        'player1id': player1id,
        'player2id': player2id,
        'date': date,
        'result': result,
        'teamId': teamId,
        'player1name': player1name,
        'player2name': player2name,
        'player1position': player1position,
        'player2position': player2position,
        'timeStamp': timeStamp,
        'winner': winner
      };
  static Match fromJson(Map<String, dynamic> json) => Match(
        id: (json['id'] ?? '').toString(),
        player1id: (json['player1id'] ?? '').toString(),
        player2id: (json['player2id'] ?? '').toString(),
        date: (json['date'] ?? '').toString(),
        result: (json['result'] ?? '').toString(),
        teamId: (json['teamId'] ?? '').toString(),
        player2name: (json['player2name'] ?? '').toString(),
        player1name: (json['player1name'] ?? '').toString(),
        player2position: int.parse(json['player2position'].toString()),
        player1position: double.parse(json['player1position'].toString()),
        timeStamp: (json['timeStamp']),
        winner: (json['winner'] ?? '').toString(),
      );
}
