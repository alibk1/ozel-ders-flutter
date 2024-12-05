import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/LoadingIndicator.dart';
import 'package:ozel_ders/FirebaseController.dart';
import 'dart:html' as html;

import 'package:ozel_ders/services/JitsiService.dart';

class AppointmentCard extends StatefulWidget {
  final String appointmentUID;
  final bool isTeacher;

  AppointmentCard({
    required this.appointmentUID,
    required this.isTeacher,
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
  DateFormat dateFormatter = DateFormat("dd/MM/yyyy - HH:mm");
  String dateStr = "";
  late Timestamp time;
  bool isAccepted = false;
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
    time = appData["date"] as Timestamp;
    isAccepted = appData["isAccepted"];
    DateTime date = time.toDate();
    dateStr = dateFormatter.format(date);
    setState(() {});
  }

  void _showAppointmentDetails(BuildContext context) {
    String buttonText = "";
    DateTime date = time.toDate();
    DateTime maxDate = date.add(Duration(hours: 1));
    DateTime minDate = date.add(Duration(minutes: -10));
    bool canEnter = true;
    bool shouldCreate = false;

    if(isAccepted) {
      if (DateTime.now().isBefore(minDate)) {
        canEnter = false;
        buttonText = "Randevu Saati Henüz Gelmedi";
      } else {
        if (widget.isTeacher) {
          if (DateTime.now().isBefore(maxDate)) {
            if (appData["meetingURL"] != "") {
              buttonText = "Randevuya Katıl";
            } else {
              buttonText = "Randevu Oluştur";
              shouldCreate = true;
            }
          } else {
            canEnter = false;
            buttonText = "Bu Randevuya Artık Girilemez";
          }
        } else {
          if (DateTime.now().isBefore(maxDate)) {
            if (appData["meetingURL"] != "") {
              buttonText = "Randevuya Katıl";
            } else {
              canEnter = false;
              buttonText = "Bu Randevuya Henüz Girilemez";
            }
          } else {
            canEnter = false;
            buttonText = "Bu Randevuya Artık Girilemez";
          }
        }
      }
    }
    else{
      canEnter = false;
      buttonText = "Bu Randevu Henüz Onaylanmadı";
    }


    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF222831),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Randevu Bilgileri',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Divider(color: Colors.white54),
                SizedBox(height: 16),
                // Kurs Bilgileri
                ListTile(
                  leading: Icon(Icons.book, color: Color(0xFF76ABAE)),
                  title: Text(
                    'Kurs',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  subtitle: Text(
                    courseData['name'],
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Color(0xFF76ABAE)),
                  title: Text(
                    'Eğitmen',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  subtitle: Text(
                    authorData['name'],
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onTap: () {
                    context.go('/profile/${authorData["uid"]}');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person_outline, color: Color(0xFF76ABAE)),
                  title: Text(
                    'Öğrenci',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  subtitle: Text(
                    studentData['name'],
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onTap: () {
                    context.go('/profile/${studentData["uid"]}');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today, color: Color(0xFF76ABAE)),
                  title: Text(
                    'Tarih ve Saat',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  subtitle: Text(
                    isAccepted ? dateStr : "Eğitimci Henüz Tarih Seçmedi",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.check_circle, color: Color(0xFF76ABAE)),
                  title: Text(
                    'Onaylanma Durumu',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  subtitle: Text(
                    isAccepted ? "Onaylandı" : "Henüz Onaylanmadı",
                    style: TextStyle(fontSize: 18, color: isAccepted ? Colors.green : Colors.red),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    canEnter ? Color(0xFF76ABAE) : Colors.grey[600],
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: canEnter
                      ? () async {
                    String url = "";
                    if (shouldCreate) {
                      // Yükleniyor animasyonu
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(
                            child: LoadingAnimationWidget.twistingDots(
                                leftDotColor: Color(0xFF222831),
                                rightDotColor: Color(0xFF663366),
                                size: 100),
                          );
                        },
                      );

                      url = (await JitsiService().createMeeting())!;
                      await FirestoreService().updateAppointmentUrl(
                          widget.appointmentUID, url);
                      appData["meetingURL"] = url;
                      Navigator.pop(context); // Yükleniyor animasyonunu kapat
                      Navigator.pop(context); // Modal'ı kapat
                      html.window.open(url, "Redirecting...");
                    } else {
                      url = appData["meetingURL"];
                      Navigator.pop(context); // Modal'ı kapat
                      html.window.open(url, "Redirecting...");
                    }
                  }
                      : null,
                  child: Text(
                    buttonText,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
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
            color: Color(int.parse("#31363F".substring(1, 7), radix: 16) + 0xFF000000),
          ),
        ),
        color: Color(int.parse("#222831".substring(1, 7), radix: 16) + 0xFF000000),
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
                  fontSize: MediaQuery.of(context).size.width >= 800 ? 20 : 15,
                  color: Color(int.parse("#EEEEEE".substring(1, 7), radix: 16) + 0xFF000000),
                ),
              ),
              onPressed: () {
                context.go('/courses/' + courseData["uid"]); // CategoriesPage'e yönlendirme
              },
            ),
            Text(
              authorData["name"],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width >= 800 ? 15 : 12,
                color: Color(int.parse("#EEEEEE".substring(1, 7), radix: 16) + 0xFF000000),
              ),
            ),
            if(MediaQuery.of(context).size.width >= 800) SizedBox(height: 8,),
            if(MediaQuery.of(context).size.width >= 800) Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.calendar_month, color: Color(0xFFEEEEEE),),
                SizedBox(width: 10,),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(int.parse("#EEEEEE".substring(1, 7), radix: 16) + 0xFF000000),
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
