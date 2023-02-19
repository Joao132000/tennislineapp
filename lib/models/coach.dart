class Coach {
  String id;
  final String name;
  final String email;
  final String token;

  Coach({
    this.id = '',
    required this.name,
    required this.email,
    required this.token,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'token': token,
      };
  static Coach fromJson(Map<String, dynamic> json) => Coach(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        token: (json['token'] ?? '').toString(),
      );
}
