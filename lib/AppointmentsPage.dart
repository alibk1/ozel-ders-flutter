import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/AppointmentCard.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/FirebaseController.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF183A37),
        title: Image.asset('assets/header.png', height: MediaQuery
            .of(context)
            .size
            .width < 600 ? 250 : 300),
        centerTitle: MediaQuery
            .of(context)
            .size
            .width < 600 ? true : false,
        leading: MediaQuery
            .of(context)
            .size
            .width < 600
            ? IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        )
            : null,
        actions: MediaQuery
            .of(context)
            .size
            .width >= 600
            ? [
          TextButton(
            onPressed: () {
              context.go('/');
            },
            child: Text('Ana Sayfa', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories'); // CategoriesPage'e yönlendirme
            },
            child: Text('Kategoriler', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/courses'); // CategoriesPage'e yönlendirme
            },
            child: Text('Kurslar', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          isLoggedIn ? TextButton(
            onPressed: ()
            {
              context.go('/appointments/' + AuthService().userUID());

            },
            child: Text('Randevularım', style: TextStyle(
                color: Color(0xFFC44900), fontWeight: FontWeight.bold)),
          ) : SizedBox.shrink(),
          TextButton(
            onPressed: isLoggedIn ?
                () {
              context.go('/profile/' + AuthService().userUID());
            }
                :
                () {
              context.go('/login');
            },
            child: Text(isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]
            : null,
      ),
      drawer: MediaQuery
          .of(context)
          .size
          .width < 600
          ? DrawerMenu(isLoggedIn: isLoggedIn)
          : null,
      body: isLoading
          ? Center(child: Column(
        children: [
          HeaderSection(),
          LoadingAnimationWidget.dotsTriangle(
              color: Color(0xFF183A37), size: 200),
        ],
      ))
          : Center(
        child: Column(
          children: [
            HeaderSection(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 750),
                  child: buildAppointmentsGrid(),
                ),
              ),
            ),
            FooterSection(),
          ],
        ),
      ),
      backgroundColor: Color(0xFFEFD6AC),
    );
  }


  Widget buildAppointmentsGrid() {
    return GridView.builder(
      key: ValueKey('categoriesGrid'),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery
            .of(context)
            .size
            .width >= 600 ? 4 : 2,
        crossAxisSpacing: 50,
        mainAxisSpacing: 50,
        childAspectRatio: 1.5,
      ),
      itemCount: userAppointments.length,
      itemBuilder: (context, index) {
        final appointment = userAppointments[index];
        return AppointmentCard(appointmentUID: appointment["UID"]);
      },
    );
  }
}

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF183A37),
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
