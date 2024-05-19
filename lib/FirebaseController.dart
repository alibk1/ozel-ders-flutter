import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Eposta ile kayıt oluşturma
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Eposta ile giriş
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Google ile giriş
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Öğrenci dökümanı oluşturma
  Future<void> createStudentDocument(String uid, String email, String name, int age, String city, String profilePictureUrl) async {
    await _db.collection('students').doc(uid).set({
      'email': email,
      'name': name,
      'age': age,
      'city': city,
      'profilePictureUrl': profilePictureUrl,
    });
  }

  // Öğretmen dökümanı oluşturma
  Future<void> createTeacherDocument(String uid, String email, String name, int age, String fieldOfStudy, double diplomaGrade, String profilePictureUrl) async {
    await _db.collection('teachers').doc(uid).set({
      'email': email,
      'name': name,
      'age': age,
      'fieldOfStudy': fieldOfStudy,
      'diplomaGrade': diplomaGrade,
      'profilePictureUrl': profilePictureUrl,
    });
  }

  // Kurs oluşturma
  Future<void> createCourse(String name, String desc, String author, String category, String subCategory, double hourlyPrice, List<String> photos) async {
    await _db.collection('courses').add({
      'name': name,
      'desc': desc,
      'author': author,
      'category': category,
      'subCategory': subCategory,
      'hourlyPrice': hourlyPrice,
      'photos': photos,
    });
  }

  // Kurs düzenleme
  Future<void> updateCourse(String courseId, String category, String subCategory, double hourlyPrice) async {
    await _db.collection('courses').doc(courseId).update({
      'category': category,
      'subCategory': subCategory,
      'hourlyPrice': hourlyPrice,
    });
  }

  // Randevu oluşturma
  Future<void> createAppointment(String author, String student, String courseId, String meetingURL, DateTime date) async {
    await _db.collection('appointments').add({
      'author': author,
      'student': student,
      'courseID': courseId,
      'meetingURL': meetingURL,
      'date': date,
    });
  }

  // Randevu düzenleme
  Future<void> updateAppointment(String appointmentId, String meetingURL, DateTime date) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'meetingURL': meetingURL,
      'date': date,
    });
  }


  Future<void> createCategory(String name, List<String> subCategories) async {
    DocumentReference categoryRef = await _db.collection('categories1')
        .add({'name': name});
    for (String subCategoryName in subCategories) {
      await categoryRef.collection('subCategories').add(
          {'name': subCategoryName, });
    }
  }

  Future<void> editCategory(String uid, String name) async {
    await _db.collection('categories1').doc(uid).update({'name': name});
  }

  Future<void> editSubCategory(String catUID, String subCatUID,
      String name) async {
    await _db.collection('categories1').doc(catUID).collection(
        'subCategories').doc(subCatUID).update({'name': name});
  }

  Future<List<String>> addSubCategories(String uid, List<String> newSubCategories) async {
    DocumentReference categoryRef = _db.collection('categories1').doc(uid);
    List<String> subCategoryIds = [];

    for (String subCategoryName in newSubCategories) {
      DocumentReference docRef = await categoryRef.collection('subCategories').add({'name': subCategoryName});
      subCategoryIds.add(docRef.id); // Eklenen dökümanın ID'sini listeye ekle
    }

    return subCategoryIds; // Eklenen tüm alt kategorilerin ID'lerini içeren listeyi döndür
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    QuerySnapshot categoriesSnapshot = await _db.collection('categories1')
        .get();
    List<Map<String, dynamic>> categories = [];
    for (var doc in categoriesSnapshot.docs) {
      DocumentSnapshot categoryDoc = doc;
      List<Map<String, dynamic>> subCategories = [];
      QuerySnapshot subCategoriesSnapshot = await categoryDoc.reference
          .collection('subCategories').get();
      subCategories = subCategoriesSnapshot.docs.map((subDoc) =>
      {
        'uid': subDoc.id,
        ...subDoc.data() as Map<String, dynamic>
      }).toList();
      categories.add({
        'uid': doc.id,
        ...doc.data() as Map<String, dynamic>,
        'subCategories': subCategories,
      });
    }
    return categories;
  }

  // Tüm öğrencileri alma
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    QuerySnapshot snapshot = await _db.collection('students').get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {...data, 'UID': doc.id};
    }).toList();
  }

  // Tüm öğretmenleri alma
  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    QuerySnapshot snapshot = await _db.collection('teachers').get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {...data, 'UID': doc.id};
    }).toList();
  }

  // Tüm kursları alma
  Future<List<Map<String, dynamic>>> getAllCourses() async {
    QuerySnapshot snapshot = await _db.collection('courses').get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {...data, 'UID': doc.id};
    }).toList();
  }

  // Tüm randevuları alma
  Future<List<Map<String, dynamic>>> getAllAppointments() async {
    QuerySnapshot snapshot = await _db.collection('appointments').get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {...data, 'UID': doc.id};
    }).toList();
  }
}
