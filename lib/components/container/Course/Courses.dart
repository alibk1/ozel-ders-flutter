import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ozel_ders/components/container/Course/Categories.dart';
import 'package:ozel_ders/components/container/Course/Course.dart';

class Courses extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    // Dummy categories data
  ];

  final List<Map<String, dynamic>> courses = [
    // Dummy courses data
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'En İyi Konular',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            'Lorem ipsum dolor sit amet consectetur adipisicing elit. Labore tempora illo laborum ex cupiditate tenetur doloribus non velit atque amet repudiandae ipsa modi numquam quas odit optio, totam voluptate sit! Lorem ipsum dolor sit amet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
          SizedBox(height: 16.0),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Categories(
                icon: Icons.category, // replace with actual icon
                category: categories[index]['category'],
              );
            },
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Tüm Dersler'),
          ),
          SizedBox(height: 32.0),
          Text(
            'Mevcut Kurslara Göz At',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: courses.map((course) {
                return Course(
                  image: course['image'],
                  category: course['category'],
                  title: course['title'],
                  participants: course['participants'],
                  rating: course['rating'],
                  price: course['price'],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
