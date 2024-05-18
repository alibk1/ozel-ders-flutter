import 'package:flutter/material.dart';

class Teacher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alanında Uzman Eğitmenlerden Ders Al',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Eğitimleri Keşfet'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Image.asset('assets/teacher1.png'),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bilgi Birikiminizi Öğrencilerle Paylaşın',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Eğitmen Ol'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Image.asset('assets/teacher2.png'),
          SizedBox(height: 16.0),
          Text(
            'Sıkça Sorulan Sorular',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          // Add Accordion widgets here
        ],
      ),
    );
  }
}
