import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import '../services/FirebaseController.dart';

class DrawerMenu extends StatelessWidget {
  final bool isLoggedIn;
  DrawerMenu({
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFF222831), // Drawer arka plan rengini ayarladık
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Başlığı
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF222831),
              ),
              accountName: isLoggedIn
                  ? Text(
                'Hoşgeldiniz',
                style: TextStyle(color: Colors.white),
              )
                  : null,
              accountEmail: isLoggedIn
                  ? Text(
                AuthService().userEmail(),
                style: TextStyle(color: Colors.white70),
              )
                  : null,
            ),
            // Drawer Öğeleri
            ListTile(
              leading: Icon(Icons.home, color: Colors.white70),
              title: Text('Ana Sayfa', style: TextStyle(color: Colors.white)),
              onTap: () {
                context.go('/');
              },
            ),
            ListTile(
              leading: Icon(Icons.category, color: Colors.white70),
              title: Text('Kategoriler', style: TextStyle(color: Colors.white)),
              onTap: () {
                context.go('/categories');
              },
            ),
            ListTile(
              leading: Icon(Icons.school, color: Colors.white70),
              title: Text('Kurslar', style: TextStyle(color: Colors.white)),
              onTap: () {
                context.go('/courses');
              },
            ),
            ListTile(
              leading: Icon(Ionicons.book, color: Colors.white70),
              title: Text('Blog', style: TextStyle(color: Colors.white)),
              onTap: () {
                context.go('/blogs');
              },
            ),
            if (isLoggedIn)
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.white70),
                title:
                Text('Randevularım', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.go('/appointments/${AuthService().userUID()}');
                },
              ),
            ListTile(
              leading: Icon(
                isLoggedIn ? Icons.person : Icons.login,
                color: Colors.white70,
              ),
              title: Text(
                isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol',
                style: TextStyle(color: Colors.white),
              ),
              onTap: isLoggedIn
                  ? () {
                context.go('/profile/' + AuthService().userUID());
              }
                  : () {
                context.go('/login');
              },
            ),
            Divider(color: Colors.white54),
            if (isLoggedIn)
              ListTile(
                leading: Icon(Icons.logout, color: Colors.white70),
                title: Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  await AuthService().signOut();
                  context.go('/');
                },
              ),
          ],
        ),
      ),
    );
  }
}
