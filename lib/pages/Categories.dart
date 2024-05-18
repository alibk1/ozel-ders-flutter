import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Categories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var categoryData = snapshot.data!.docs[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/categories/${categoryData['category']}');
                },
                child: Card(
                  child: Column(
                    children: [
                      Image.network(categoryData['image'], fit: BoxFit.cover),
                      Text(categoryData['category']),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
