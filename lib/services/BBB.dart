import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:html' as html;

import 'package:url_launcher/url_launcher.dart';

class BBBService {
  final String bbbUrl = 'https://test-install.blindsidenetworks.com/bigbluebutton/api/';
  final String secret = '8cd8ef52e8e101574e400365b55e11a6';
  final String proxyUrl = 'http://localhost:3000/proxy?url=';

  String generateChecksum(String query) {
    var bytes = utf8.encode(query + secret);
    return sha1.convert(bytes).toString();

  }

  Future<void> createMeeting(String meetingID, String meetingName) async {
    print("GİRDİM BABBA");
    String query = 'create?meetingID=$meetingID&name=$meetingName';
    String checksum = generateChecksum(query);
    String url = '$bbbUrl/$query&checksum=$checksum';
    url = "https://test-install.blindsidenetworks.com/bigbluebutton/api/create?allowStartStopRecording=true&attendeePW=ap&autoStartRecording=false&meetingID=random-3587986&moderatorPW=mp&name=random-3587986&record=false&voiceBridge=71493&welcome=%3Cbr%3EWelcome+to+%3Cb%3E%25%25CONFNAME%25%25%3C%2Fb%3E%21&checksum=42941ec4ed0fb44bdc3b6ee80bcbe4059470432e";

    var response = await http.get(Uri.parse(proxyUrl + Uri.encodeComponent(url)));
    print("GİRDİM BABBA 2");

    if (response.statusCode == 200) {
      print('Meeting created successfully');
      print(response.body);
    } else {
      print('Failed to create meeting');
      print(response.body);

    }
  }

  String generateJoinUrl(String meetingID, String userName, String userID, bool isModerator) {
    String role = isModerator ? 'moderator' : 'attendee';
    String query = 'join?meetingID=$meetingID&fullName=$userName&userID=$userID&password=$role';
    String checksum = generateChecksum(query);
    return '$bbbUrl/$query&checksum=$checksum';
  }



  void joinMeeting(String meetingID, String meetingName, String userName, String userID, bool isModerator) async {

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
