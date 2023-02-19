class Team {
  String id;
  final String type;
  final String school;
  final String league;
  final String coachId;
  final int challengePositions;

  Team(
      {this.id = '',
      required this.type,
      required this.school,
      required this.league,
      required this.coachId,
      required this.challengePositions});
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'school': school,
        'league': league,
        'coachId': coachId,
        'challengePositions': challengePositions,
      };

  static Team fromJson(Map<String, dynamic> json) => Team(
        id: (json['id'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        school: (json['school'] ?? '').toString(),
        league: (json['league'] ?? '').toString(),
        coachId: (json['coachId'] ?? '').toString(),
        challengePositions: (json['challengePositions']),
      );
}
