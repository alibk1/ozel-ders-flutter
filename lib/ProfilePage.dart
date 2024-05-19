import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth.dart';

class ProfilePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Sayfası'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginSignupPage()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildMobileLayout();
          } else {
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user != null ? _buildProfileInfo() : _buildNoUserInfo(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          width: 600,
          child: user != null ? _buildProfileInfo() : _buildNoUserInfo(),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: user?.photoURL != null
              ? NetworkImage(user!.photoURL!)
              : AssetImage('assets/default_profile.png') as ImageProvider,
        ),
        SizedBox(height: 20),
        Text(
          user?.displayName ?? 'Adı Yok',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 10),
        Text(
          user?.email ?? 'Email Yok',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildNoUserInfo() {
    return Text(
      'Kullanıcı bilgileri alınamadı',
      style: TextStyle(fontSize: 16),
    );
  }
}
