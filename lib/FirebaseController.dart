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

  Future<bool> isUserSignedIn() async {
    try {
      final User? user = _auth.currentUser;
      return user != null;
    } catch (e) {
      print('Hata: $e');
      return false;
    }
  }

  Future<bool> signOut() async
  {
    try {
      await _auth.signOut();
      return true;
    }
    catch(e)
    {
      print(e);
      return false;
    }
  }

  String userUID()
  {
    return _auth.currentUser!.uid;
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
      'desc': '',
      'courses': []
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
      'desc': '',
      'courses': []
    });
  }

  Future<void> createMessage(String email, String name, String message) async {
    await _db.collection('messages').add({
      'email': email,
      'name': name,
      'message': message
    });
  }

  // Kurs oluşturma
  Future<void> createCourse(String name, String desc, String author, String category, String subCategory, double hourlyPrice, List<String> photos) async {
    try {
      DocumentReference courseRef = await _db.collection('courses').add({
        'name': name,
        'desc': desc,
        'author': author,
        'category': category,
        'subCategory': subCategory,
        'hourlyPrice': hourlyPrice,
        'photos': photos,
      });

      String courseId = courseRef.id;

      DocumentReference teacherRef = _db.collection('teachers').doc(author);

      await _db.runTransaction((transaction) async {
        DocumentSnapshot teacherSnapshot = await transaction.get(teacherRef);
        if (teacherSnapshot.exists) {
          print(teacherSnapshot.id);
          List<dynamic> courses = teacherSnapshot['courses'] ?? [];

          if (!courses.contains(courseId)) {
            courses.add(courseId);
            transaction.update(teacherRef, {'courses': courses});
          }
        }
      });
    }
    catch(e)
    {
      print(e);
    }
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
    DocumentReference doc1 = await _db.collection('appointments').add({
      'author': author,
      'student': student,
      'courseID': courseId,
      'meetingURL': meetingURL,
      'date': date,
    });

    await _db.collection('students').doc(student).collection("appointments").doc(doc1.id).set({
      'author': author,
      'student': student,
      'courseID': courseId,
      'meetingURL': meetingURL,
      'date': date,
    });


    DocumentReference studentRef = _db.collection('students').doc(student);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot teacherSnapshot = await transaction.get(studentRef);

      if (teacherSnapshot.exists) {
        List<dynamic> courses = teacherSnapshot['courses'] ?? [];

        if (!courses.contains(courseId)) {
          courses.add(courseId);
          transaction.update(studentRef, {'courses': courses});
        }
      }
    });

    await _db.collection('teachers').doc(author).collection("appointments").doc(doc1.id).set({
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
    try {
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
    catch(e)
    {
      print(e);
      return[];
    }
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

  // Get specific document by UID from courses collection
  Future<Map<String, dynamic>> getCourseByUID(String uid) async {
    DocumentSnapshot doc = await _db.collection('courses').doc(uid).get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['uid'] = doc.id;
    return data;
  }

  // Get specific document by UID from categories collection
  Future<Map<String, dynamic>> getCategoryByUID(String uid) async {
    DocumentSnapshot doc = await _db.collection('categories').doc(uid).get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['uid'] = doc.id;
    return data;
  }


  // Get specific document by UID from teachers collection
  Future<Map<String, dynamic>> getTeacherByUID(String uid) async {
    DocumentSnapshot doc = await _db.collection('teachers').doc(uid).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return data;
    } else {
      return {};
    }
  }

  // Get specific document by UID from students collection
  Future<Map<String, dynamic>> getStudentByUID(String uid) async {
    DocumentSnapshot doc = await _db.collection('students').doc(uid).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return data;
    } else {
      return {};
    }
  }

  // Get specific document by UID from students collection
  Future<Map<String, dynamic>> getAppointmentByUID(String uid) async {
    DocumentSnapshot doc = await _db.collection('appointments').doc(uid).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return data;
    } else {
      return {};
    }
  }

  // Get specific document by UID from students collection
  Future<List<Map<String, dynamic>>> getUserAppointments(String uid, bool isTeacher) async {
    String collection = isTeacher ? "teachers" : "students";
    QuerySnapshot query = await _db.collection(collection).doc(uid).collection("appointments").get();
    return query.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {...data, 'UID': doc.id};
    }).toList();
  }

  // Change user profile photo URL
  Future<void> changeUserPhoto(String uid, String photoUrl, bool isTeacher) async {
    String collection = isTeacher ? 'teachers' : 'students';
    await _db.collection(collection).doc(uid).update({'profilePictureUrl': photoUrl});
  }

  // Change user description
  Future<void> changeUserDesc(String uid, String desc, bool isTeacher) async {
    String collection = isTeacher ? 'teachers' : 'students';
    await _db.collection(collection).doc(uid).update({'desc': desc});
  }

  // Change user name
  Future<void> changeUserName(String uid, String name, bool isTeacher) async {
    String collection = isTeacher ? 'teachers' : 'students';
    await _db.collection(collection).doc(uid).update({'name': name});
  }
}
