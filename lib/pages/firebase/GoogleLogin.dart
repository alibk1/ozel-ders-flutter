import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'AccountAvatar.dart';

class GoogleLogin extends StatefulWidget {
  @override
  _GoogleLoginState createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  late String? email;
  late String? avatar;
  late String displayName;

  @override
  void initState() {
    super.initState();
    email = FirebaseAuth.instance.currentUser?.email;
    avatar = FirebaseAuth.instance.currentUser?.photoURL;
    displayName = FirebaseAuth.instance.currentUser?.displayName ?? "User";
  }

  Future<void> handleLogin() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    setState(() {
      email = userCredential.user?.email;
      avatar = userCredential.user?.photoURL;
      displayName = userCredential.user?.displayName ?? "User";
    });
  }

  void handleLogout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      email = null;
      avatar = null;
      displayName = "User";
    });
  }

  @override
  Widget build(BuildContext context) {
    return email != null
        ? AccountMenu(
      avatar: avatar!,
      displayName: displayName,
      logOut: handleLogout,
    )
        : ElevatedButton(
      onPressed: handleLogin,
      child: Text('Giriş Yap'),
    );
  }
}
