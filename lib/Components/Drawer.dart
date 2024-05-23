import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../FirebaseController.dart';

class DrawerMenu extends StatefulWidget {
  final bool isLoggedIn;
  DrawerMenu({
    required this.isLoggedIn,
  });
  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF183A37),
            ),
            child: Image.asset('assets/header.png', height: 200,),
          ),
          ListTile(
            title: Text('Ana Sayfa'),
            onTap: () {
              context.go('/');
            },
          ),
          ListTile(
            title: Text('Kategoriler'),
            onTap: () {
              context.go('/categories');
            },
          ),
          ListTile(
            title: Text('Kurslar'),
            onTap: () {
              context.go('/courses');
            },
          ),
          ListTile(
            title: Text('Randevularım'),
            onTap: () {},
          ),
          ListTile(
            title: Text(widget.isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol'),
            onTap: widget.isLoggedIn
                ? () {
              context.go('/profile/' + AuthService().userUID());
            }
                : () {
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
