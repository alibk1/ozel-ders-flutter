import 'package:flutter/material.dart';
import 'package:ozel_ders/components/NavBar/Navbar.dart';
import 'package:ozel_ders/components/container/About.dart';
import 'package:ozel_ders/components/container/Contact.dart';
import 'package:ozel_ders/components/container/Course/Courses.dart';
import 'package:ozel_ders/components/container/Footer.dart';
import 'package:ozel_ders/components/container/Home.dart';
import 'package:ozel_ders/components/container/Teacher.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ozel Ders'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Navbar(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(child: Column(
          children: [
            Home(),
            About(),
            Courses(),
            Teacher(),
            Contact(),
            Footer(),
          ],
        )),
      ),
      //bottomNavigationBar: Footer(),
    );
  }
}