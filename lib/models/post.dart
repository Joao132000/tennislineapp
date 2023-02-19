import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  final String userName;
  final String teamId;
  final Timestamp timeStamp;
  final String description;

  Post({
    this.id = '',
    required this.userName,
    required this.timeStamp,
    required this.teamId,
    required this.description,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'teamId': teamId,
        'timeStamp': timeStamp,
        'description': description,
      };

  Post.fromSnapshot(QueryDocumentSnapshot doc)
      : timeStamp = doc["timeStamp"] as Timestamp,
        description = doc["description"] as String,
        userName = doc["userName"] as String,
        teamId = doc["teamId"] as String,
        id = doc["id"] as String;
}
