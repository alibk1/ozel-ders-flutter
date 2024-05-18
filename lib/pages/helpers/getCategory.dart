import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getCategoryCourses(String categoryName) async {
  List<Map<String, dynamic>> courses = [];
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('instructors')
      .where('category', isEqualTo: categoryName)
      .get();

  snapshot.docs.forEach((doc) {
    courses.add(doc.data() as Map<String, dynamic>);
  });

  print(courses); // courses dizisini konsola yazdırıyoruz

  return courses;
}
