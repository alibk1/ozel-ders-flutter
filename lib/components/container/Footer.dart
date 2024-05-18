import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.teal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get Started',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            'Lorem ipsum, dolor sit amet consectetur adipisicing elit. Nemo neque saepe cumque. Veritatis sunt commodi',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16.0),
          Text(
            'Services',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(onPressed: () {}, child: Text('Web Design')),
              TextButton(onPressed: () {}, child: Text('Web Development')),
              TextButton(onPressed: () {}, child: Text('Science')),
              TextButton(onPressed: () {}, child: Text('Digital Marketing')),
            ],
          ),
          SizedBox(height: 16.0),
          Text(
            'Company',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(onPressed: () {}, child: Text('Privacy Policy')),
              TextButton(onPressed: () {}, child: Text('Sitemap')),
              TextButton(onPressed: () {}, child: Text('Careers')),
              TextButton(onPressed: () {}, child: Text('Terms & Conditions')),
            ],
          ),
          SizedBox(height: 16.0),
          Text(
            'Bizi takip edin',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            'ortakozelders@gmail.com',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            '+90-555-555-5555',
            style: TextStyle(color: Colors.white),
          ),
          Row(
            children: [
              IconButton(
                icon: FaIcon(FontAwesomeIcons.facebook),
                color: Colors.white,
                onPressed: () {},
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.instagram),
                color: Colors.white,
                onPressed: () {},
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.twitter),
                color: Colors.white,
                onPressed: () {},
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.pinterest),
                color: Colors.white,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
