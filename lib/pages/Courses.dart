import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Courses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('instructors').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var courseData = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  title: Text(courseData['title']),
                  subtitle: Text(courseData['description']),
                  leading: Image.network(courseData['image']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
