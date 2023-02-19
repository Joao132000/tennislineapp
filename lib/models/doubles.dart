class Doubles {
  String id;
  final String teamId;
  final String players;
  final int position;

  Doubles({
    this.id = '',
    required this.teamId,
    required this.players,
    required this.position,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'teamId': teamId,
        'players': players,
        'position': position,
      };
  static Doubles fromJson(Map<String, dynamic> json) => Doubles(
        id: (json['id'] ?? '').toString(),
        teamId: (json['teamId'] ?? '').toString(),
        players: (json['players'] ?? '').toString(),
        position: int.parse(json['position'].toString()),
      );
}
