import 'package:flutter/material.dart';
import 'package:ozel_ders/components/NavBar/Navbar.dart';
import 'package:ozel_ders/pages/HomePage.dart';
import 'package:ozel_ders/pages/Categories.dart';
import 'package:ozel_ders/pages/SelectedCategory.dart';
import 'package:ozel_ders/pages/Courses.dart';
import 'package:ozel_ders/pages/Contact.dart';
import 'package:ozel_ders/components/container/Footer.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ozel Ders',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomePage(), // Default olarak ana sayfayı göster
      routes: {
        '/categories': (context) => Categories(),
        '/categories/:categoryName': (context) => SelectedCategory(categoryName: ''), // Değiştirin
        '/courses': (context) => Courses(),
        '/contact': (context) => Contact(),
      },
    );
  }
}
