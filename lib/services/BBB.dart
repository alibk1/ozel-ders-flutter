import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:html' as html;

import 'package:url_launcher/url_launcher.dart';

class BBBService {
  final String bbbUrl = 'http://165.232.45.70/bigbluebutton/api';
  final String secret = 'iKqpjGWkYzXx0K14th3PRwEndrJADZHiCQHtu6vY';
  final String proxyUrl = 'http://localhost:3000/proxy?url=';

  /*String generateChecksum(String query) {
    var bytes = utf8.encode(query + secret);
    return sha1.convert(bytes).toString();

  }*/
  String generateChecksum(String apiCall, Map<String, String> params, String secret) {
    var paramsString = Uri(queryParameters: params).query;
    var stringToHash = apiCall + paramsString + secret;
    var bytes = utf8.encode(stringToHash);
    var digest = sha1.convert(bytes);
    return digest.toString();
  }


  Future<void> createMeeting(String meetingID, String meetingName) async {
    const apiCall = 'create';
    final params = {
      'name': meetingName,
      'meetingID': meetingID,
      'attendeePW': 'ap',
      'moderatorPW': 'mp',
      'welcome': 'Welcome to the meeting!',
      'dialNumber': '',
      'voiceBridge': '71234',
      'webVoice': '',
      'logoutURL': 'https://your-logout-url.com',
      'record': 'true',
      'duration': '60',
      'meta_course': 'Math 101',
    };
    print("GİRDİM BABBA");
    String query = 'create?meetingID=$meetingID&name=$meetingName';
    //String checksum = generateChecksum(query);
    //String url = '$bbbUrl/$query&checksum=$checksum';

    var checksum = generateChecksum(apiCall, params, secret);
    var url = Uri.parse('$bbbUrl/$apiCall?${Uri(queryParameters: params).query}&checksum=$checksum');
    //url = "https://test-install.blindsidenetworks.com/bigbluebutton/api/create?allowStartStopRecording=true&attendeePW=ap&autoStartRecording=false&meetingID=random-3587986&moderatorPW=mp&name=random-3587986&record=false&voiceBridge=71493&welcome=%3Cbr%3EWelcome+to+%3Cb%3E%25%25CONFNAME%25%25%3C%2Fb%3E%21&checksum=42941ec4ed0fb44bdc3b6ee80bcbe4059470432e";
    print(url.toString());


    var response = await http.get(url);
    //String a = _getJoinLink(meetingID,"b","",meetingName);
    print("-----------");
   // print(a);


    //var response = await http.get(Uri.parse(proxyUrl + Uri.encodeComponent(url)));
    //var response = await http.get(url);
    //html.window.open(url.toString(), 'hey');


    print("GİRDİM BABBA 2");


  }
  String _getJoinLink(String meetingID, String fullName, String password, String meetingName) {
    const apiCall = 'join';
    final params = {
      'name': meetingName,
      'meetingID': meetingID,
      'fullName': fullName,
      'attendeePW': 'ap',
      'moderatorPW': 'mp',
      'welcome': 'Welcome to the meeting!',
      'dialNumber': '',
      'webVoice': '',
      'record': 'true',
      'duration': '60',
      'meta_course': 'Math 101',
    };
    String joinQuery = 'join?meetingID=$meetingID';
    String checksum = generateChecksum(joinQuery, params, apiCall);
    return '$bbbUrl/$joinQuery&checksum=$checksum';
  }

  String generateJoinUrl(String meetingID, String userName, String userID, bool isModerator) {
    const apiCall = 'join';
    final params = {
      'meetingID': '1234',
      'fullName': 'John Doe',
      'password': 'mp',  // Kullanıcı parolası, moderatör veya katılımcı
      'redirect': 'true',
    };
    var checksum = generateChecksum(apiCall, params, secret);
    var url = Uri.parse('$bbbUrl/$apiCall?${Uri(queryParameters: params).query}&checksum=$checksum');

    String role = isModerator ? 'moderator' : 'attendee';
    String query = 'join?meetingID=$meetingID&fullName=$userName&userID=$userID&password=$role';
    //&&//String checksum = generateChecksum(query);
    //return '$bbbUrl/$query&checksum=$checksum';
    return url.toString();
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
