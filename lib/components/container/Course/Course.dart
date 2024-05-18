import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Course extends StatelessWidget {
  final String image;
  final String category;
  final String title;
  final int participants;
  final double rating;
  final double price;

  Course({
    required this.image,
    required this.category,
    required this.title,
    required this.participants,
    required this.rating,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 4.0, color: Colors.grey)],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(image),
          SizedBox(height: 8.0),
          Text(category, style: TextStyle(color: Colors.teal)),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(FontAwesomeIcons.user, color: Colors.teal),
                  Text('$participants'),
                ],
              ),
              Row(
                children: [
                  Icon(FontAwesomeIcons.star, color: Colors.yellow),
                  Text('$rating'),
                ],
              ),
              Text('\$$price'),
            ],
          ),
        ],
      ),
    );
  }
}
