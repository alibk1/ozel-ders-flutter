import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Image.asset('assets/About.jpg'),
          SizedBox(height: 16.0),
          Text(
            'Canlı ve yüz yüze eğitimlerin ortak noktası',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'OrtakOzelDers, eğitimde sınırları ortadan kaldırarak her öğrenciye en iyi eğitim imkanını sunmayı ilke edinmiştir. Bu amaçla, canlı online derslerin esnekliğini ve yüz yüze eğitimlerin etkileşimini bir araya getiren yenilikçi bir platform sunuyoruz.',
            style: TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
