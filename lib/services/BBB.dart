/*import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:html' as html;


class BBBService {
  final String bbbUrl = 'http://104.248.163.172/bigbluebutton/api';
  final String secret = 'x46fdZ0qsusL1oxsFo12n71SMkvyWjC0ZyEOBC3u3rA';

  String generateChecksum(String apiCall, Map<String, String> params, String secret) {
    var paramsString = Uri(queryParameters: params).query;
    var stringToHash = apiCall + paramsString + secret;
    var bytes = utf8.encode(stringToHash);
    var digest = sha1.convert(bytes);
    return digest.toString();
  }


  Future<void> createAndJoinMeeting(String meetingID, String meetingName) async {
    const apiCall = 'create';
    const apiCall1 = 'join';
    final params = {
      'name': meetingName,
      'meetingID': meetingID,
      'attendeePW': 'ap',
      'moderatorPW': 'mp',
      'welcome': 'Welcome to the meeting!',
      'dialNumber': '',
      'webVoice': '',
      'record': 'true',
      'duration': '60',
      'meta_course': 'Math 101',
    };

    var checksum = generateChecksum(apiCall, params, secret);
    var checksum1 = generateChecksum(apiCall, params, secret);
    var url = Uri.parse('$bbbUrl/$apiCall?${Uri(queryParameters: params).query}&checksum=$checksum');
    var url1 = Uri.parse('$bbbUrl/$apiCall1?${Uri(queryParameters: params).query}&checksum=$checksum1');
    print(url);
    print(url1);
    html.window.open(url.toString(), 'hey');

  }
}

 */