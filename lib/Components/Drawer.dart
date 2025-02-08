import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/FirebaseController.dart';

class DrawerMenu extends StatelessWidget {
  final bool isLoggedIn;

  DrawerMenu({
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFFA7D8DB);
    final Color backgroundColor = Color(0xFFEEEEEE);
    final Color darkColor = Color(0xFF3C72C2);

    return Drawer(
      backgroundColor: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF222831), Color(0xFF393E46)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, darkColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: isLoggedIn
                  ? Text(
                'Hoşgeldiniz',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )
                  : null,
              accountEmail: isLoggedIn
                  ? Text(
                AuthService().userEmail(),
                style: TextStyle(color: Colors.white70),
              )
                  : null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: darkColor,
                  size: 40,
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.home,
              text: 'Ana Sayfa',
              onTap: () => context.go('/'),
              primaryColor: primaryColor,
              darkColor: darkColor,
            ),
            _buildDrawerItem(
              icon: Icons.school,
              text: 'Danışmanlıklar',
              onTap: () => context.go('/courses'),
              primaryColor: primaryColor,
              darkColor: darkColor,
            ),
            _buildDrawerItem(
              icon: Ionicons.book,
              text: 'Blog',
              onTap: () => context.go('/blogs'),
              primaryColor: primaryColor,
              darkColor: darkColor,
            ),
            if (isLoggedIn)
              _buildDrawerItem(
                icon: Icons.calendar_today,
                text: 'Randevularım',
                onTap: () => context.go('/appointments/${AuthService().userUID()}'),
                primaryColor: primaryColor,
                darkColor: darkColor,
              ),
            _buildDrawerItem(
              icon: isLoggedIn ? Icons.person : Icons.login,
              text: isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol',
              onTap: isLoggedIn
                  ? () => context.go('/profile/' + AuthService().userUID())
                  : () => context.go('/login'),
              primaryColor: primaryColor,
              darkColor: darkColor,
            ),
            Divider(color: Colors.white54),
            if (isLoggedIn)
              _buildDrawerItem(
                icon: Icons.logout,
                text: 'Çıkış Yap',
                onTap: () async {
                  await AuthService().signOut();
                  context.go('/');
                },
                primaryColor: primaryColor,
                darkColor: darkColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color darkColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(text, style: TextStyle(color: Colors.white)),
      onTap: onTap,
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      hoverColor: primaryColor.withOpacity(0.2),
      splashColor: primaryColor.withOpacity(0.3),
    );
  }
}