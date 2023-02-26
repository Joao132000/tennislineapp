import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NotificationPush {
  static void sendPushMessage(String token, String? title, String body) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAVCxeRzE:APA91bFxdrbqpLSAl-_iKGjL9sQkeTCmcZPTIS5_cYS6n95SY-dPeB7S7fPIwu43H-aFu1HxoP__BGtya4toyHqLZpPCvoLSjt7RVwCp0W3uQdvvOXXT14nxakxYojU9tdePPaFm_6j7',
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
            },
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'android_channel_id': 'channelID'
            },
            'to': token,
          }));
    } catch (e) {
      if (kDebugMode) {
        print('error');
      }
    }
  }
}
