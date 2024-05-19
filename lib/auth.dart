import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/FirebaseController.dart';
import 'Components/Drawer.dart';
import 'HomePage.dart';

class LoginSignupPage extends StatefulWidget {
  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _dateController = TextEditingController(); // Yeni TextField için controller

  // Yeni TextField için controller
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '619520758342-mc02si573tea3f48n429fmbkngnpd38c.apps.googleusercontent.com',

  );

  Future<void> _loginWithGoogle() async {
    try {
      /*final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Kullanıcı Google Sign-In penceresini kapattı
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );


      final UserCredential userCredential = await _auth.signInWithCredential(credential);*/
      await AuthService().signInWithGoogle();
      // Giriş başarılı, ana sayfaya yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Hata mesajını göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Google ile giriş hatası')),
      );
    }
  }
  //title: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol')
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF009899),
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
          icon: const Icon(Icons.menu),
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
            child: const Text('Ana Sayfa', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories'); // CategoriesPage'e yönlendirme
            },
            child: const Text('Kategoriler', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/courses'); // CategoriesPage'e yönlendirme
            },
            child: const Text('Kurslar', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed:() {
              context.go('/login');
            },
            child: const Text('Giriş Yap / Kaydol',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]
            : null,),
      drawer: MediaQuery.of(context).size.width < 600
          ? DrawerMenu(isLoggedIn: false)
          : null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          HeaderSection(),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Small screen (e.g. mobile)
                return _buildMobileLayout();
              } else {
                // Large screen (e.g. tablet, desktop)
                return _buildDesktopLayout();
              }
            },
          ),
          FooterSection(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildForm(),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = !_isLogin;
              });
            },
            child: Text(_isLogin ? 'Hala kayıt olmadın mı? Kayıt Ol' : 'Zaten hesabın var mı? Giriş Yap'),
          ),
          const SizedBox(height: 10),
         // _buildGoogleSignInButton(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildForm(),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin ? 'Hala kayıt olmadın mı? Kayıt Ol' : 'Zaten hesabın var mı? Giriş Yap'),
            ),
            const SizedBox(height: 10),
            //_buildGoogleSignInButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        key: ValueKey<bool>(_isLogin),
        children: _isLogin ? _buildLoginFields() : _buildSignupFields(),
      ),
    );
  }

  List<Widget> _buildLoginFields() {
    return [
      TextField(
        controller: _emailController,
        decoration: const InputDecoration(labelText: 'E-mail'),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _passwordController,
        decoration: const InputDecoration(labelText: 'Şifre'),
        obscureText: true,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _login,
        child: const Text('Giriş Yap'),
      ),
    ];
  }

  List<Widget> _buildSignupFields() {
    return [
      TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Adınız'),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _emailController,
        decoration: const InputDecoration(labelText: 'E-mail'),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _passwordController,
        decoration: const InputDecoration(labelText: 'Şifre'),
        obscureText: true,
      ),
      const SizedBox(height: 20),
      BirthdateInputWidget(dateController: _dateController),
      const SizedBox(height: 20),

      ElevatedButton(
        onPressed: _signup,
        child: const Text('Kayıt Ol'),
      ),
    ];
  }

  Widget _buildGoogleSignInButton() {
    return ElevatedButton.icon(
      onPressed: _loginWithGoogle,
      icon: Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/512px-Google_%22G%22_Logo.svg.png',
        height: 24.0,
        width: 24.0,
      ),
      label: const Text('Google ile Giriş Yap'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50), // Set the button to fill the width
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: const BorderSide(color: Colors.grey),
      ),
    );
  }

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Login başarılı, ana sayfaya yönlendir
      context.go("/profile");
    } on FirebaseAuthException catch (e) {
      // Hata mesajını göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Giriş hatası')),
      );
    }
  }
  Future<void> _addUserData(email,password,name,birthDate) async {
    final User? user = FirebaseAuth.instance.currentUser;


    if (user != null) {


      DateTime birthdate = DateTime.parse(birthDate);
      Timestamp birthdateTimestamp = Timestamp.fromDate(birthdate);

      CollectionReference users = FirebaseFirestore.instance.collection('Users');
      await users.doc(user!.uid).set({
        'displayName': name,
        'email': email,
        'photoURL': user!.photoURL,
        "birthDate": birthdateTimestamp,
      });
    }
  }

  Future<void> _signup() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Kayıt başarılı, giriş ekranına yönlendir
      _addUserData(_emailController.text.trim(),_passwordController.text.trim(),_nameController.text.trim(),_nameController.text);
      context.go("/profile");

    } on FirebaseAuthException catch (e) {
      // Hata mesajını göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Kayıt hatası')),
      );
    }
  }
}

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF009899),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 15,),
            Text("WellDo'ya Giriş Yap", style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25),),
            SizedBox(height: 5,),

          ],
        ),
      ),
    );
  }
}
class BirthdateInputWidget extends StatefulWidget {
  final TextEditingController dateController;

  BirthdateInputWidget({required this.dateController});

  @override
  _BirthdateInputWidgetState createState() => _BirthdateInputWidgetState();
}

class _BirthdateInputWidgetState extends State<BirthdateInputWidget> {
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        widget.dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.dateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: 'Doğum Tarihinizi Seçin',
        border: OutlineInputBorder(),
      ),
    );
  }
}
