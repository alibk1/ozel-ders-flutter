import 'dart:convert';
import 'package:http/http.dart' as http;

class JitsiService {
  Future<String?> createMeeting() async {
    final url = Uri.parse('https://api.vitament.net/create-meeting');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data['meeting_link']);
      return data['meeting_link'];
    } else {
      return null;
    }
  }
}
