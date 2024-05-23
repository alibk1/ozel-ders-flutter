import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF04151F),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'E-posta: info@welldo.com',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'WellDo Education Services',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Tüm Hakları Saklıdır © 2024',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}