import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/Components/LoadingIndicator.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'Components/Drawer.dart';
import 'HomePage.dart';

class LoginSignupPage extends StatefulWidget {
  final String reference;

  LoginSignupPage({required this.reference});

  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _dateController = TextEditingController(); // Yeni TextField için controller

  // Yeni TextField için controller
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '619520758342-mc02si573tea3f48n429fmbkngnpd38c.apps.googleusercontent.com',

  );

  @override
  void initState() {
    _referenceController.text = widget.reference;
    if(widget.reference != ""){
      _isLogin = false;
      setState(() {

      });
    }

    super.initState();
  }

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Google ile giriş hatası')),
      );
    }
  }


  String _selectedRole = 'Öğrenci';

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
        backgroundColor: const Color(0xFF222831),
        title: Image.asset('assets/vitament1.png', height: MediaQuery
            .of(context)
            .size
            .width < 800 ? 60 : 80),
        centerTitle: MediaQuery
            .of(context)
            .size
            .width < 800 ? true : false,
        leading: MediaQuery
            .of(context)
            .size
            .width < 800
            ? IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        )
            : null,
        actions: MediaQuery
            .of(context)
            .size
            .width >= 800
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
            onPressed: () {
              context.go('/blogs');
            },
            child: Text('Blog',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/login');
            },
            child: const Text('Giriş Yap / Kaydol',
                style: TextStyle(
                    color: Color(0xFF76ABAE), fontWeight: FontWeight.bold)),
          ),
        ]
            : null,),
      drawer: MediaQuery
          .of(context)
          .size
          .width < 800
          ? DrawerMenu(isLoggedIn: false)
          : null,
      body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/therapy-login.jpg", // Buraya arkaplan resmini ekle
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.darken,
                color: Colors.grey[500],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HeaderSection(),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 800) {
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
              ),
            ),
          ]
      ),
      backgroundColor: Color(0xFFEEEEEE),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xFF222831),
          border: Border.all(color: Color(0xFF76ABAE), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
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
              child: Text(_isLogin
                  ? 'Hala kayıt olmadın mı? Kayıt Ol'
                  : 'Zaten hesabın var mı? Giriş Yap', style: TextStyle(color: Color(0xFF76ABAE)),),
            ),
            const SizedBox(height: 10),
            // _buildGoogleSignInButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xFF222831),
          border: Border.all(color: Color(0xFF76ABAE), width: 2),
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
              child: Text(_isLogin
                  ? 'Hala kayıt olmadın mı? Kayıt Ol'
                  : 'Zaten hesabın var mı? Giriş Yap', style: TextStyle(color: Color(0xFF76ABAE)),),
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
      TextFormField(
        cursorColor: Colors.white,
        controller: _emailController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Color(0xFF76ABAE)),
            borderRadius: BorderRadius.circular(5),
          ),
          labelText: 'E-mail',
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderSide: const BorderSide(width: 4, color: Colors.white),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: _passwordController,
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Color(0xFF76ABAE)),
            borderRadius: BorderRadius.circular(5),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(width: 4, color: Colors.white),
            borderRadius: BorderRadius.circular(5),
          ),
          labelText: 'Şifre',
          labelStyle: const TextStyle(color: Colors.white),
        ),
        obscureText: true,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF222831),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3), // Köşeleri 3 birim yuvarlat
            side: const BorderSide(color: Color(0xFFEEEEEE), width: 2), // 2 birim border
          ),
        ),
        child: const Text('Giriş Yap', style: TextStyle(color: Colors.white),),
      ),
      const SizedBox(height: 10),
      TextButton(
        onPressed: () {
          _showChangePasswordDialog(context, _emailController.text);
        },
        child: Text('Şifreni mi unuttun?', style: TextStyle(color: Color(0xFF76ABAE)),),
      ),
    ];
  }

  List<Widget> _buildSignupFields() {
    return [
      TextFormField(
        controller: _nameController,
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
            labelText: 'Adınız',
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Color(0xFF76ABAE)),
            borderRadius: BorderRadius.circular(5),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(width: 4, color: Colors.white),
            borderRadius: BorderRadius.circular(5),
          ),
          labelStyle: const TextStyle(color: Colors.white),

        ),
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: _emailController,
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
            labelText: 'E-mail',
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Color(0xFF76ABAE)),
            borderRadius: BorderRadius.circular(5),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(width: 4, color: Colors.white),
            borderRadius: BorderRadius.circular(5),
          ),
          labelStyle: const TextStyle(color: Colors.white),

        ),
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: _passwordController,
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
            labelText: 'Şifre',
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Color(0xFF76ABAE)),
            borderRadius: BorderRadius.circular(5),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(width: 4, color: Colors.white),
            borderRadius: BorderRadius.circular(5),
          ),
          labelStyle: const TextStyle(color: Colors.white),

        ),
        obscureText: true,
      ),
      if(_selectedRole != "Kurum")...[
        SizedBox(height: 10,),
        TextFormField(
          controller: _referenceController,
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
              labelText: 'Referans Kodu (Opsiyonel)',
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: Color(0xFF76ABAE)),
              borderRadius: BorderRadius.circular(5),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 4, color: Colors.white),
              borderRadius: BorderRadius.circular(5),
            ),
            labelStyle: const TextStyle(color: Colors.white),

          ),
        ),
      ],
      const SizedBox(height: 20),
      //BirthdateInputWidget(dateController: _dateController),
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
          RoleButton(
            role: 'Kurum',
            isSelected: _selectedRole == 'Kurum',
            onTap: () => _selectRole('Kurum'),
          ),
        ],
      ),
      const SizedBox(height: 20),

      ElevatedButton(
        onPressed: () async
        {
          await _signup();
        },
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
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        // Set the button to fill the width
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: const BorderSide(color: Colors.grey),
      ),
    );
  }

  Future<void> _login() async {
    try {
      User? user = await AuthService().signInWithEmail(_emailController.text, _passwordController.text);
      // Login başarılı, ana sayfaya yönlendir
      context.go("/profile/" + user!.uid);
    } on FirebaseAuthException catch (e) {
      // Hata mesajını göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Giriş hatası')),
      );
    }
  }

  Future<void> _signup() async {
    try {
      User? user = await AuthService().registerWithEmail(_emailController.text, _passwordController.text);
      if(_selectedRole == "Öğretmen") {
        await FirestoreService().createTeacherDocument(user!.uid, _emailController.text, _nameController.text, 21, "Ne Ararsan", 3.5, "", _referenceController.text);
      }
      if(_selectedRole == "Kurum") {
        await FirestoreService().createTeamDocument(user!.uid, _emailController.text, _nameController.text, "Ankara", "", 10);
      } else {
        await FirestoreService().createStudentDocument(user!.uid, _emailController.text, _nameController.text, 21, "Ankara", "", _referenceController.text);
      }
      // Kayıt başarılı, giriş ekranına yönlendir
      context.go("/profile/" + user.uid);
    } on FirebaseAuthException catch (e) {
      // Hata mesajını göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Kayıt hatası')),
      );
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context, String email) async {
    TextEditingController emailController =
    TextEditingController(text: email);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Arka planı saydam yapıyoruz
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF222831), // Arka plan rengini ayarlıyoruz
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Wrap(
            children: [
              SizedBox(height: 10),
              Text("Kayıt Olurken Kullandığınız E-posta'yı Giriniz:",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'E-posta',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF393E46),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  LoadingIndicator(context).showLoading();
                  await AuthService().sendPasswordResetEmail(emailController.text);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Şifre Sıfırlama Bağlantısı Gönder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF76ABAE),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

}

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF222831),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 15,),
            Text("Vitament'e Giriş Yap", style: TextStyle(color: Colors.white,
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
          color: isSelected ? Color(0xFF76ABAE) : Colors.grey[200],
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
