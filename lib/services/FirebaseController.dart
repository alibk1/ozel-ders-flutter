import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static Map<String, dynamic> userDetails = {};
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
    return _auth.currentUser!.uid ?? "";
  }

  // Kullanıcının görüntüleme adını alma
  String userDisplayName() {
    return _auth.currentUser?.displayName ?? 'Kullanıcı';
  }

  // Kullanıcının e-posta adresini alma
  String userEmail() {
    return _auth.currentUser?.email ?? '';
  }

  // Şifre Sıfırlama E-postası Gönderme
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Şifre sıfırlama e-postası gönderildi.');
      return true;
    } catch (e) {
      print('Şifre Sıfırlama Hatası: ${e.toString()}');
      return false;
    }
  }
}


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Öğrenci dökümanı oluşturma
  Future<void> createStudentDocument(String uid, String email, String name, int age, String city, String profilePictureUrl, String reference) async {
    await _db.collection('students').doc(uid).set({
      'email': email,
      'name': name,
      'age': age,
      'city': city,
      'profilePictureUrl': profilePictureUrl,
      'desc': '',
      'reference': reference,
      'courses': []
    });
  }

  // Öğretmen dökümanı oluşturma
  Future<void> createTeacherDocument(String uid, String email, String name, int age, String fieldOfStudy, double diplomaGrade, String profilePictureUrl, String reference) async {
    await _db.collection('teachers').doc(uid).set({
      'email': email,
      'name': name,
      'age': age,
      'fieldOfStudy': fieldOfStudy,
      'diplomaGrade': diplomaGrade,
      'profilePictureUrl': profilePictureUrl,
      'desc': '',
      "reference": reference,
      'courses': []
    });
  }

  Future<void> createTeamDocument(String uid, String email, String name, String address, String profilePictureUrl, double discountPercent) async {
    await _db.collection('teams').doc(uid).set({
      'email': email,
      'name': name,
      'fieldOfStudy': address,
      'profilePictureUrl': profilePictureUrl,
      'desc': '',
      'discountPercent': discountPercent,
      'teachers': []
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
  Future<String> createAppointment(String author, String student, String courseId, String meetingURL, List<DateTime> selectedDates) async {
    DocumentReference doc1 = await _db.collection('appointments').add({
      'author': author,
      'student': student,
      'courseID': courseId,
      'date': DateTime.now().add(Duration(days: -1)),
      'meetingURL': meetingURL,
      'selectedDates': selectedDates,
      'isAccepted' : false,
      'homework' : '',
      'note' : '',
      'homeworkFiles': []
    });

    await _db.collection('students').doc(student).collection("appointments").doc(doc1.id).set({
      'author': author,
      'student': student,
      'courseID': courseId,
      'date': DateTime.now().add(Duration(days: -1)),
      'meetingURL': meetingURL,
      'selectedDates': selectedDates,
      'isAccepted' : false,
      'note' : '',
      'homework' : '',
      'homeworkFiles': []
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
      'date': DateTime.now().add(Duration(days: -1)),
      'meetingURL': meetingURL,
      'selectedDates': selectedDates,
      'isAccepted' : false,
      'note' : '',
      'homework' : '',
      'homeworkFiles': []
    });
    return doc1.id;
  }


  // Randevu oluşturma
  Future<String> createSelfAppointment(String author, DateTime date) async {
    DocumentReference doc1 = await _db.collection('appointments').add({
      'author': author,
      'student': author,
      'date': date,
      'isAccepted' : true,
    });

    await _db.collection('teachers').doc(author).collection("appointments").doc(doc1.id).set({
      'author': author,
      'student': author,
      'date': date,
      'isAccepted' : true,
    });
    return doc1.id;
  }

  Future<void> deleteSelfAppointment(String author, String uid) async {
    await _db.collection('appointments').doc(uid).delete();
    await _db.collection('teachers').doc(author).collection("appointments").doc(uid).delete();
  }

  // Randevu düzenleme
  Future<void> updateAppointment(String appointmentId, String meetingURL, DateTime date) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'meetingURL': meetingURL,
      'date': date,
    });
  }

  // Randevu düzenleme
  Future<void> acceptAppointment(String appointmentId, String teacherId, String studentId, DateTime selectedDate) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'isAccepted' : true,
      'date' : selectedDate
    });

    await _db.collection('teachers').doc(teacherId).collection("appointments").doc(appointmentId).update({
      'isAccepted' : true,
      'date' : selectedDate
    });

    await _db.collection('students').doc(studentId).collection("appointments").doc(appointmentId).update({
      'isAccepted' : true,
      'date' : selectedDate
    });
  }

  Future<void> addHomeworkToAppointment(String appointmentId, String teacherId, String studentId, String homework, List<String> homeworkFiles) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'homework' : homework,
      'homeworkFiles' : homeworkFiles
    });

    await _db.collection('teachers').doc(teacherId).collection("appointments").doc(appointmentId).update({
      'homework' : homework,
      'homeworkFiles' : homeworkFiles
    });

    await _db.collection('students').doc(studentId).collection("appointments").doc(appointmentId).update({
      'homework' : homework,
      'homeworkFiles' : homeworkFiles
    });
  }


  Future<void> addNoteToAppointment(String appointmentId, String teacherId, String studentId, String note) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'note' : note,
    });

    await _db.collection('teachers').doc(teacherId).collection("appointments").doc(appointmentId).update({
      'note' : note,
    });

    await _db.collection('students').doc(studentId).collection("appointments").doc(appointmentId).update({
      'note' : note,
    });
  }

  Future<String> createAppointmentSurvey(String appointmentUID, String author, String student, List<String> questions, String surveyName) async {
    DocumentReference doc1 = await _db.collection('appointments').doc(appointmentUID).collection("surveys").add({
      'surveyName' : surveyName,
      'author': author,
      'student': student,
      "questions" : questions,
      'answers' : []
    });

    await _db.collection('teachers').doc(author).collection("appointments").doc(appointmentUID).collection("surveys").doc(doc1.id).set({
      'surveyName' : surveyName,
      'author': author,
      'student': student,
      "questions" : questions,
      'answers' : []
    });

    await _db.collection('students').doc(student).collection("appointments").doc(appointmentUID).collection("surveys").doc(doc1.id).set({
      'surveyName' : surveyName,
      'author': author,
      'student': student,
      "questions" : questions,
      'answers' : []
    });
    return doc1.id;
  }

  Future<String> createAppointmentSurveyTemplate(String author, List<String> questions, String surveyName) async {
    DocumentReference doc1 = await _db.collection('teachers').doc(author).collection("surveyTemplates").add({
      'surveyName' : surveyName,
      "questions" : questions,
    });
    return doc1.id;
  }

  Future<void> updateAppointmentSurveyQuestions(String appointmentUID, String surveyUID, String author, String student, List<String> questions) async {
    await _db.collection('appointments').doc(appointmentUID).collection("surveys").doc(surveyUID).update({
      "questions" : questions,
    });

    await _db.collection('teachers').doc(author).collection("appointments").doc(appointmentUID).collection("surveys").doc(surveyUID).update({
      "questions" : questions,
    });

    await _db.collection('students').doc(student).collection("appointments").doc(appointmentUID).collection("surveys").doc(surveyUID).update({
      "questions" : questions,
    });
  }

  Future<void> updateAppointmentSurveyAnswers(String appointmentUID, String surveyUID,String author, String student, List<String> answers) async {
    await _db.collection('appointments').doc(appointmentUID).collection("surveys").doc(surveyUID).update({
      "answers" : answers,
    });

    await _db.collection('teachers').doc(author).collection("appointments").doc(appointmentUID).collection("surveys").doc(surveyUID).update({
      "answers" : answers,
    });

    await _db.collection('students').doc(student).collection("appointments").doc(appointmentUID).collection("surveys").doc(surveyUID).update({
      "answers" : answers,
    });
  }

  Future<List<Map<String, dynamic>>> getAppointmentSurveys(String appointmentUID) async {
    QuerySnapshot snapshot = await _db.collection('appointments').doc(appointmentUID).collection("surveys").get();
    if(snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {...data, 'UID': doc.id};
      }).toList();
    }
    else{
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getASurveyTemplates(String author) async {
    QuerySnapshot snapshot = await _db.collection('teachers').doc(author).collection("surveyTemplates").get();
    if(snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {...data, 'UID': doc.id};
      }).toList();
    }
    else{
      return [];
    }
  }


  // Randevu düzenleme
  Future<void> updateAppointmentUrl(String appointmentId, String meetingURL) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'meetingURL': meetingURL,
    });
  }

//--------------------------------------------------------------------------------------------------
  Future<void> createCategory(String name, List<String> subCategories, String imageUrl) async {
    DocumentReference categoryRef = await _db.collection('categories1')
        .add({'name': name, 'imageUrl' : imageUrl});
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
      subCategoryIds.add(docRef.id);
    }

    return subCategoryIds;
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

  Future<List<Map<String, dynamic>>> getAllTeams() async {
    QuerySnapshot snapshot = await _db.collection('teams').get();
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

  // Get specific document by UID from courses collection
  Future<Map<String, dynamic>> getTeamByUID(String uid) async {
    DocumentSnapshot doc = await _db.collection('teams').doc(uid).get();
    if(doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return data;
    }
    else return Map<String, dynamic>.fromIterable(Iterable.empty());

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

  Future<void> changeTeamPhoto(String uid, String photoUrl) async {
    String collection = "teams";
    await _db.collection(collection).doc(uid).update({'profilePictureUrl': photoUrl});
  }

  // Change team description
  Future<void> changeTeamDesc(String uid, String desc) async {
    String collection = "teams";
    await _db.collection(collection).doc(uid).update({'desc': desc});
  }

  // Change team name
  Future<void> changeTeamName(String uid, String name) async {
    String collection = "teams";
    await _db.collection(collection).doc(uid).update({'name': name});
  }

  Future<void> sendRFromTeamToTeacher(String teacherUID, String teamUID, String teamName) async {
    String collection = "teachers";
    String collection2 = "notifications";
    await _db.collection(collection).doc(teacherUID).collection(collection2).doc("Request" + teamUID).set({
      "teamUID" : teamUID,
      "notType" : "Invite",
      "message" : "$teamName onların eğitmeni olman için sana bir istek gönderdi. Kabul edebilir veya yoksayabilirsin. Bu bildirim daha sonra kabul edebilmen için saklanacak.",
      "isAccepted" : false,
      "hasRead" : false,
    });
  }

  Future<void> sendRFromTeamToStudent(String studentUID, String teamUID, String teamName) async {
    String collection = "students";
    String collection2 = "notifications";
    await _db.collection(collection).doc(studentUID).collection(collection2).doc("Request" + teamUID).set({
      "teamUID" : teamUID,
      "notType" : "Invite",
      "message" : "$teamName onların öğrencisi olman için sana bir istek gönderdi. Kabul edebilir veya yoksayabilirsin. Bu bildirim daha sonra kabul edebilmen için saklanacak.",
      "isAccepted" : false,
      "hasRead" : false,
    });
  }

  Future<void> acceptRequestForTeacher(String teacherUID, String teamUID) async {
    String collection = "teachers";
    String notificationsCollection = "notifications";
    try {
      await _db
          .collection(collection)
          .doc(teacherUID)
          .collection(notificationsCollection)
          .doc("Request" + teamUID)
          .update({
        "isAccepted": true,
      });
      print("Teacher request accepted successfully.");
    } catch (e) {
      print("Error accepting teacher request: $e");
    }
  }

  Future<void> acceptRequestForStudent(String studentUID, String teamUID) async {
    String collection = "students";
    String notificationsCollection = "notifications";
    try {
      await _db
          .collection(collection)
          .doc(studentUID)
          .collection(notificationsCollection)
          .doc("Request" + teamUID)
          .update({
        "isAccepted": true,
      });
      print("Student request accepted successfully.");
    } catch (e) {
      print("Error accepting student request: $e");
    }
  }

  Future<void> markRequestAsReadForTeacher(String teacherUID, String teamUID) async {
    String collection = "teachers";
    String notificationsCollection = "notifications";
    try {
      await _db
          .collection(collection)
          .doc(teacherUID)
          .collection(notificationsCollection)
          .doc("Request" + teamUID)
          .update({
        "hasRead": true,
      });
      print("Teacher request marked as read successfully.");
    } catch (e) {
      print("Error marking teacher request as read: $e");
    }
  }

  Future<void> markRequestAsReadForStudent(String studentUID, String teamUID) async {
    String collection = "students";
    String notificationsCollection = "notifications";
    try {
      await _db
          .collection(collection)
          .doc(studentUID)
          .collection(notificationsCollection)
          .doc("Request" + teamUID)
          .update({
        "hasRead": true,
      });
      print("Student request marked as read successfully.");
    } catch (e) {
      print("Error marking student request as read: $e");
    }
  }

  /// Belirtilen öğretmenin bildirimlerini alır.
  Future<List<Map<String, dynamic>>> getNotificationsForTeacher(String teacherUID) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('teachers')
          .doc(teacherUID)
          .collection('notifications')
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching notifications for teacher: $e');
      return [];
    }
  }

  /// Belirtilen öğrencinin bildirimlerini alır.
  Future<List<Map<String, dynamic>>> getNotificationsForStudent(String studentUID) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('students')
          .doc(studentUID)
          .collection('notifications')
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching notifications for student: $e');
      return [];
    }
  }

  /// Belirtilen takımın bildirimlerini alır.
  Future<List<Map<String, dynamic>>> getNotificationsForTeam(String teamUID) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('teams')
          .doc(teamUID)
          .collection('notifications')
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching notifications for team: $e');
      return [];
    }
  }

  Future<bool> updateReference(String uid, String newReference) async {
    try {
      // Öncelikle 'teachers' koleksiyonunda UID'yi kontrol et
      DocumentReference teacherRef = _db.collection('teachers').doc(uid);
      DocumentSnapshot teacherSnap = await teacherRef.get();

      if (teacherSnap.exists) {
        await teacherRef.update({'reference': newReference});
        print('Reference updated for teacher with UID: $uid');
        return true;
      }

      // Eğer 'teachers' koleksiyonunda bulunamazsa, 'students' koleksiyonunda kontrol et
      DocumentReference studentRef = _db.collection('students').doc(uid);
      DocumentSnapshot studentSnap = await studentRef.get();

      if (studentSnap.exists) {
        await studentRef.update({'reference': newReference});
        print('Reference updated for student with UID: $uid');
        return true;
      }

      // UID ne 'teachers' ne de 'students' koleksiyonunda bulunamazsa
      print('UID not found in both teachers and students collections: $uid');
      return false;
    } catch (e) {
      print('Error updating reference for UID $uid: $e');
      return false;
    }
  }


  Future<void> sendAppointmentToTeacher(String appointmentUID, String teacherUID, String studentUID,String studentName) async {
    String collection = "teachers";
    String collection2 = "notifications";
    await _db.collection(collection).doc(teacherUID).collection(collection2).doc(appointmentUID).set({
      "appointmentUID" : appointmentUID,
      "notType" : "Meeting",
      "teacherUID": teacherUID,
      "studentUID": studentUID,
      "message" : "$studentName sizden yeni bir randevu talep ediyor.",
      "isAccepted" : false,
      "hasRead" : false,
    });
  }

  Future<void> markAppointmentAsReadForTeacher(String teacherUID, String appointmentUID) async {
    String collection = "teachers";
    String notificationsCollection = "notifications";
    try {
      await _db
          .collection(collection)
          .doc(teacherUID)
          .collection(notificationsCollection)
          .doc(appointmentUID)
          .update({
        "hasRead": true,
      });
      print("Teacher request marked as read successfully.");
    } catch (e) {
      print("Error marking teacher request as read: $e");
    }
  }

  Future<void> sendAppointmentAcceptedToStudent(String appointmentUID, String teacherUID, String studentUID, String teacherName, String formattedDate) async {
    String collection = "students";
    String collection2 = "notifications";
    await _db.collection(collection).doc(studentUID).collection(collection2).doc(appointmentUID + "Acccept").set({
      "appointmentUID" : appointmentUID,
      "notType" : "MeetingAccept",
      "teacherUID": teacherUID,
      "studentUID": studentUID,
      "message" : "$teacherName ile olan randevu talebiniz yanıtlandı. $formattedDate tarihinde randevunuz oluşturuldu. Görüşmek üzere...",
      "hasRead" : false,
    });
  }

  Future<void> markAppointmentAcceptedAsReadForStudent(String studentUID, String appointmentUID) async {
    String collection = "students";
    String notificationsCollection = "notifications";
    try {
      await _db
          .collection(collection)
          .doc(studentUID)
          .collection(notificationsCollection)
          .doc(appointmentUID)
          .update({
        "hasRead": true,
      });
      print("Teacher request marked as read successfully.");
    } catch (e) {
      print("Error marking teacher request as read: $e");
    }
  }

  Future<bool> acceptAppointmentRequest(String teacherUID, String studentUID, String appointmentUID, DateTime selectedDate) async {
    String collection1 = "teachers";
    String collection2 = "students";
    String notificationsCollection = "notifications";
    String appointmentsCollection = "appointments";
    try {
      await _db
          .collection(collection1)
          .doc(teacherUID)
          .collection(notificationsCollection)
          .doc(appointmentUID)
          .update({
        "isAccepted": true,
      });
      await _db
          .collection(collection1)
          .doc(teacherUID)
          .collection(appointmentsCollection)
          .doc(appointmentUID)
          .update({
        "isAccepted": true,
        "date" : selectedDate
      });
      await _db
          .collection(collection2)
          .doc(studentUID)
          .collection(appointmentsCollection)
          .doc(appointmentUID)
          .update({
        "isAccepted": true,
        "date" : selectedDate
      });
      await _db
          .collection(appointmentsCollection)
          .doc(appointmentUID)
          .update({
        "isAccepted": true,
        "date" : selectedDate
      });
      print("Teacher request marked as read successfully.");
      return true;
    } catch (e) {
      print("Error marking teacher request as read: $e");
      return false;
    }
  }

  // Blog oluşturma
  Future<void> createBlog(String creatorUID, String title, String content) async {
    // Öncelikle, creatorUID'nin bir öğretmene ait olup olmadığını kontrol edin
    DocumentSnapshot teacherDoc = await _db.collection('teachers').doc(creatorUID).get();
    if (!teacherDoc.exists) {
      throw Exception('Sadece öğretmenler blog yazısı oluşturabilir.');
    }

    await _db.collection('blogs').add({
      'creatorUID': creatorUID,
      'title': title,
      'content': content,
      'createdAt': DateTime.now(),
    });
  }

  // Tüm blogları getirme
  Future<List<Map<String, dynamic>>> getAllBlogs() async {
    QuerySnapshot snapshot = await _db.collection('blogs').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {...data, 'uid': doc.id};
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getAllBlogs20Times({int limit = 20, DocumentSnapshot? startAfter}) async {
    Query query = _db.collection('blogs').orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    QuerySnapshot snapshot = await query.get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {...data, 'uid': doc.id};
    }).toList();
  }

  // Belirli bir öğretmenin bloglarını getirme
  Future<List<Map<String, dynamic>>> getTeacherBlogs(String teacherUID) async {
    QuerySnapshot snapshot = await _db.collection('blogs')
        .where('creatorUID', isEqualTo: teacherUID)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {...data, 'uid': doc.id};
    }).toList();
  }

  // Belirli bir blogu getirme
  Future<Map<String, dynamic>> getBlog(String blogUID) async {
    DocumentSnapshot doc = await _db.collection('blogs').doc(blogUID).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      return {...data, 'uid': doc.id};
    } else {
      throw Exception('Blog bulunamadı.');
    }
  }

  // Blog güncelleme
  Future<void> updateBlogDetails(String blogUID, String? title, String? content) async {
    Map<String, dynamic> updateData = {};
    if (title != null) updateData['title'] = title;
    if (content != null) updateData['content'] = content;

    if (updateData.isNotEmpty) {
      await _db.collection('blogs').doc(blogUID).update(updateData);
    }
  }

  // Bloga yorum ekleme
  Future<void> commentToBlog(String blogUID, String commenterUID, String comment) async {
    await _db.collection('blogs').doc(blogUID).collection('comments').add({
      'commenterUID': commenterUID,
      'comment': comment,
      'commentedAt': DateTime.now(),
    });
  }

  // Blogun yorumlarını getirme
  Future<List<Map<String, dynamic>>> getBlogComments(String blogUID) async {
    QuerySnapshot snapshot = await _db.collection('blogs').doc(blogUID).collection('comments')
        .orderBy('commentedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {...data, 'uid': doc.id};
    }).toList();
  }

}
