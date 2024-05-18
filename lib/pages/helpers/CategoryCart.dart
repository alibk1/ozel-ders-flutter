import 'package:flutter/material.dart';

class ActionAreaCard extends StatelessWidget {
  final Map<String, dynamic> categoryData;

  ActionAreaCard({required this.categoryData});

  @override
  Widget build(BuildContext context) {
    final shortDescription = categoryData['description'].split(' ').sublist(0, 10).join(' ') + '...';

    return Card(
      child: Column(
        children: [
          Image.network(
            categoryData['image'],
            height: 140,
            fit: BoxFit.cover,
          ),
          ListTile(
            title: Text(categoryData['category']),
            subtitle: Text(shortDescription),
          ),
        ],
      ),
    );
  }
}
