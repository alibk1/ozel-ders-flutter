import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'özel derslerin güvenilir adresi',
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            'Kaliteli eğitimlere erişmenin yeni yolu',
            style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            'Lorem, ipsum dolor sit amet consectetur adipisicing elit. Vero officia sit vitae quo, eum similique?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {},
            child: Text('Keşfetmeye Başla'),
          ),
          SizedBox(height: 16.0),
          Image.asset('assets/hero.png'),
          SizedBox(height: 16.0),
          Text(
            'We collaborate with 100+ leading universities and companies',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}
