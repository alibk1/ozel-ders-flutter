import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
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
  String _selectedRole = '';

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
    });
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
      const SizedBox(height: 20.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RoleButton(
            role: 'Öğrenci',
            isSelected: _selectedRole == 'Öğrenci',
            onTap: () => _selectRole('Öğrenci'),
          ),
          RoleButton(
            role: 'Öğretmen',
            isSelected: _selectedRole == 'Öğretmen',
            onTap: () => _selectRole('Öğretmen'),
          ),
        ],
      ),
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
  Future<void> _addUserData(email,password,name,birthDate,role) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {

      if(role=="Öğrenci"){
        await FirestoreService().createStudentDocument(user!.uid, email, name, 21, "Ankara", "");
      }
      else{
        await FirestoreService().createTeacherDocument(user!.uid, email, name, 21, "Terapist", 3.5, "");
    if (user != null) {

      if(role=="Öğretmen"){
        CollectionReference users = FirebaseFirestore.instance.collection('teachers');
        await users.doc(user!.uid).set({
          'displayName': name,
          'email': email,
          'photoURL': user!.photoURL,
          'birthDate': birthDate,
        });

      }
      else{
        CollectionReference users = FirebaseFirestore.instance.collection('Users');
        await users.doc(user!.uid).set({
          'displayName': name,
          'email': email,
          'photoURL': user!.photoURL,
          'birthDate': birthDate,
        });


      }

    }
  }


  Future<void> _signup() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Kayıt başarılı, giriş ekranına yönlendir
      _addUserData(_emailController.text.trim(),_passwordController.text.trim(),_nameController.text.trim(),_nameController.text,_selectedRole);
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
        widget.dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.dateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: const InputDecoration(
        labelText: 'Doğum Tarihinizi Seçin',
        border: OutlineInputBorder(),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Doğum Tarihi Girişi Örneği'),
        ),
        body: BirthdateInputExample(),
      ),
    );
  }
}

class BirthdateInputExample extends StatefulWidget {
  @override
  _BirthdateInputExampleState createState() => _BirthdateInputExampleState();
}

class _BirthdateInputExampleState extends State<BirthdateInputExample> {
  final TextEditingController _dateController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveBirthdate() async {
    final String birthdateString = _dateController.text;
    if (birthdateString.isNotEmpty) {
      try {
        DateTime birthdate = DateFormat('yyyy-MM-dd').parse(birthdateString);
        Timestamp birthdateTimestamp = Timestamp.fromDate(birthdate);


        // Firestore'a kaydetme
        await _firestore.collection('Users').doc('user_id').set({
          'birthdate': birthdateTimestamp,
        });

        print('Doğum tarihi kaydedildi: $birthdateTimestamp');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doğum tarihi kaydedildi')),
        );
      } catch (e) {
        print('Hata: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geçersiz doğum tarihi formatı')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir doğum tarihi seçin')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BirthdateInputWidget(dateController: _dateController),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _saveBirthdate,
            child: const Text('Doğum Tarihini Kaydet'),
          ),
        ],
      ),
    );
  }

}

class RoleButton extends StatelessWidget {
  final String role;
  final bool isSelected;
  final VoidCallback onTap;

  RoleButton({required this.role, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ]
              : [],
        ),
        child: Text(
          role,
          style: TextStyle(
            fontSize: 18.0,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
