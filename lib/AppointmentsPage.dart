import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/AppointmentCard.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/services/FirebaseController.dart';

import 'Components/Drawer.dart';

class AppointmentsPage extends StatefulWidget {
  final String uid;
  AppointmentsPage({required this.uid});

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirestoreService _firestore = FirestoreService();
  List<Map<String, dynamic>> userAppointments = [];
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;
  bool showSubCategories = false;
  bool isLoggedIn = false;
  bool isTeacher = true;

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async
  {
    isLoggedIn = await AuthService().isUserSignedIn();
    if (isLoggedIn) {
      String currentUser = AuthService().userUID();
      if (currentUser == widget.uid) {
        userInfo = await FirestoreService().getTeacherByUID(widget.uid);
        if (userInfo.isNotEmpty) {
          isTeacher = true;
        } else {
          userInfo = await FirestoreService().getStudentByUID(widget.uid);
          isTeacher = false;
        }
        userAppointments = await FirestoreService().getUserAppointments(widget.uid, isTeacher);
        sortUserAppointments();
      }
      else
      {
        context.go('/');
      }
    }
    else
    {
      context.go('/');
    }
    isLoading = false;
    setState(() {});
  }

  void sortUserAppointments() {
    userAppointments.sort((a, b) {
      Timestamp dateA = a['date'] as Timestamp;
      Timestamp dateB = b['date'] as Timestamp;

      DateTime aD = dateA.toDate();
      DateTime bD = dateB.toDate();
      return aD.compareTo(bD);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF222831),
        title: Image.asset(
          'assets/vitament1.png',
          height: MediaQuery.of(context).size.width < 800 ? 60 : 80,
        ),
        centerTitle: MediaQuery.of(context).size.width < 800 ? true : false,
        leading: MediaQuery.of(context).size.width < 800
            ? IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        )
            : null,
        actions: MediaQuery.of(context).size.width >= 800
            ? [
          TextButton(
            onPressed: () {
              context.go('/');
            },
            child: Text('Ana Sayfa',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories');
            },
            child: Text('Kategoriler',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/courses');
            },
            child: Text('Terapiler',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/blogs');
            },
            child: Text('Blog',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          isLoggedIn
              ? TextButton(
            onPressed: () {
              context.go('/appointments/' + AuthService().userUID());
            },
            child: Text('Randevularım',
                style: TextStyle(
                    color: Color(0xFF76ABAE),
                    fontWeight: FontWeight.bold)),
          )
              : SizedBox.shrink(),
          TextButton(
            onPressed: isLoggedIn
                ? () {
              context.go('/profile/' + AuthService().userUID());
            }
                : () {
              context.go('/login');
            },
            child: Text(
                isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]
            : null,
      ),
      drawer: MediaQuery.of(context).size.width < 800
          ? DrawerMenu(isLoggedIn: isLoggedIn)
          : null,
      body: isLoading
          ? Center(
        child: Column(
          children: [
            HeaderSection(),
            LoadingAnimationWidget.dotsTriangle(
                color: Color(0xFF222831), size: 200),
          ],
        ),
      )
          : SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HeaderSection(),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 750),
                            child: buildAppointmentsGrid(),
                          ),
                        ),
                        FooterSection(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      backgroundColor: Color(0xFFEEEEEE),
    );
  }


  Widget buildAppointmentsGrid() {
    return GridView.builder(
      key: ValueKey('categoriesGrid'),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width >= 800 ? 4 : 2,
        crossAxisSpacing: 50,
        mainAxisSpacing: 50,
        childAspectRatio: MediaQuery.of(context).size.width >= 800 ? 1.5 : 0.75,
      ),
      itemCount: userAppointments.length,
      itemBuilder: (context, index) {
        final appointment = userAppointments[index];
        //print(appointment["UID"].toString() + " - " + appointment["author"].toString() + " - " + appointment["student"].toString());
        if(appointment["author"] != appointment["student"]) {
          return AppointmentCard(
            appointmentUID: appointment["UID"],
            isTeacher: isTeacher,
          );
        }
        return SizedBox.shrink();
      },
    );
  }

}

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF222831),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 55,),
            Text("Randevular", style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20),),

          ],
        ),
      ),
    );
  }
}
