import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'E-posta: info@example.com',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Tüm Hakları Saklıdır © 2024',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}