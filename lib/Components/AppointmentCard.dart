import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/FirebaseController.dart';
import 'dart:html' as html;

import 'package:ozel_ders/services/BBB.dart';

class AppointmentCard extends StatefulWidget {
  final String appointmentUID;

  AppointmentCard({
    required this.appointmentUID,
  });

  @override
  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool isLoading = true;
  Map<String, dynamic> appData = {};
  Map<String, dynamic> courseData = {};
  Map<String, dynamic> authorData = {};
  Map<String, dynamic> studentData = {};
  DateFormat dateFormatter = DateFormat("dd/MM/yyyy - hh:mm");
  String dateStr = "";

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  Future<void> getData() async {
    appData = await FirestoreService().getAppointmentByUID(widget.appointmentUID);
    courseData = await FirestoreService().getCourseByUID(appData["courseID"]);
    authorData = await FirestoreService().getTeacherByUID(appData["author"]);
    studentData = await FirestoreService().getStudentByUID(appData["student"]);
    isLoading = false;
    Timestamp tmstmp = appData["date"] as Timestamp;
    DateTime date = tmstmp.toDate();
    dateStr = dateFormatter.format(date);
    setState(() {});
  }

  void _showAppointmentDetails(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color(0xFF183A37),
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Randevu Bilgileri',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Kurs: ${courseData['name']}',
                        style: TextStyle(fontSize: 16, color: Color(0xFFEFD6AC)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Eğitmen: ${authorData['name']}',
                        style: TextStyle(fontSize: 16, color: Color(0xFFEFD6AC)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Öğrenci: ${studentData['name']}',
                        style: TextStyle(fontSize: 16, color: Color(0xFFEFD6AC)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Tarih: $dateStr',
                        style: TextStyle(fontSize: 16, color: Color(0xFFEFD6AC)),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  BBBService().createAndJoinMeeting("AAAAAAA", "meeting");
                  //html.window.open(appData["meetingURL"], "Redirecting...");
                },
                child: Text('Randevuya Git', style: TextStyle(fontSize: 16, color: Color(0xFF000000)
                )
                )
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAppointmentDetails(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), // Yuvarlak köşe
            topRight: Radius.circular(25), // Yuvarlak köşe
            bottomLeft: Radius.circular(25), // Sivri köşe
            bottomRight: Radius.circular(25),
          ),
          side: BorderSide(
            width: 2,
            color: Color(int.parse("#04151F".substring(1, 7), radix: 16) + 0xFF000000),
          ),
        ),
        color: Color(int.parse("#183A37".substring(1, 7), radix: 16) + 0xFF000000),
        child: isLoading ? Center(child: LoadingAnimationWidget.inkDrop(color: Colors.white, size: 50),): Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                child: PageView(
                  children: courseData['photos'].map<Widget>((photoUrl) {
                    return Image.network(photoUrl, fit: BoxFit.cover);
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 4),
            TextButton(
              child: Text(
                courseData['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(int.parse("#EFD6AC".substring(1, 7), radix: 16) + 0xFF000000),
                ),
              ),
              onPressed: () {
                context.go('/courses/' + courseData["UID"]); // CategoriesPage'e yönlendirme
              },
            ),
            Text(
              authorData["name"],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(int.parse("#EFD6AC".substring(1, 7), radix: 16) + 0xFF000000),
              ),
            ),
            SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.calendar_month, color: Color(0xFFEFD6AC),),
                SizedBox(width: 10,),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(int.parse("#EFD6AC".substring(1, 7), radix: 16) + 0xFF000000),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}
