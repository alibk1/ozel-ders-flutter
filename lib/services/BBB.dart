import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:html' as html;

import 'package:url_launcher/url_launcher.dart';

class BBBService {
  final String bbbUrl = 'https://test.bigbluebutton.org/bigbluebutton/api/';
  final String secret = '8cd8ef52e8e101574e400365b55e11a6';
  final String proxyUrl = 'http://localhost:3000/proxy?url=';

  String generateChecksum(String query) {
    var bytes = utf8.encode(query + secret);
    return sha1.convert(bytes).toString();
  }

  Future<void> createMeeting(String meetingID, String meetingName) async {
    String query = 'create?meetingID=$meetingID&name=$meetingName';
    String checksum = generateChecksum(query);
    String url = '$bbbUrl/$query&checksum=$checksum';

    var response = await http.get(Uri.parse(proxyUrl + Uri.encodeComponent(url)));
    if (response.statusCode == 200) {
      print('Meeting created successfully');
    } else {
      print('Failed to create meeting');
    }
  }

  String generateJoinUrl(String meetingID, String userName, String userID, bool isModerator) {
    String role = isModerator ? 'moderator' : 'attendee';
    String query = 'join?meetingID=$meetingID&fullName=$userName&userID=$userID&password=$role';
    String checksum = generateChecksum(query);
    return '$bbbUrl/$query&checksum=$checksum';
  }

  String meetingID = '1234';
  String meetingName = 'Test_Meeting';
  String userName = 'John Doe';
  String userID = 'user123';
  bool isModerator = true;

  void joinMeeting() async {
    await createMeeting(meetingID, meetingName);
    print("meetijg created");
    String joinUrl = generateJoinUrl(meetingID, userName, userID, isModerator);
    print(joinUrl);

    // JavaScript kullanarak yeni bir tarayıcı penceresi açma
    html.window.open(joinUrl, 'hey');
  }
  Future<void> makeRequest() async {
    String url = 'https://www.google.com';
    html.window.open(url, 'hey');
  }


}
