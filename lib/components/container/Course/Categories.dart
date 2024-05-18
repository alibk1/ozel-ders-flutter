import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Categories extends StatelessWidget {
  final IconData icon;
  final String category;

  Categories({required this.icon, required this.category});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [FadeEffect()],
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48.0, color: Colors.teal),
              SizedBox(height: 16.0),
              Text(category),
              Text(
                'Kategoriye git',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
