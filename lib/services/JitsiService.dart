import 'dart:convert';
import 'package:http/http.dart' as http;

class JitsiService {
  Future<String?> createMeeting() async {
    final url = Uri.parse('https://api.vitament.net/create-meeting');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({"user_name": "user"}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      return data['admin_link'];
    } else {
      print("Error: ${response.statusCode}");
      return null;
    }
  }

}
