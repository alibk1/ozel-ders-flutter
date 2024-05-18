import 'package:flutter/material.dart';

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Bize Ulaşın',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            'OrtakOzelDers, her zaman sizden haber almak ister! İsteklerinizi, görüşlerinizi ve önerilerinizi paylaşarak platformumuzu geliştirmemize yardımcı olursunuz.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
          SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              hintText: 'Mesajınızı gönderin',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () {},
            child: Text('Gönder'),
          ),
        ],
      ),
    );
  }
}
