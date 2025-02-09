import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();

  final TextEditingController _dateController = TextEditingController(); // Yeni TextField için controller

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '619520758342-mc02si573tea3f48n429fmbkngnpd38c.apps.googleusercontent.com',
  );

  final Gradient _gradientBackground = LinearGradient(
    colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  final Color _primaryColor = Color(0xFFA7D8DB);
  final Color _backgroundColor = Color(0xFFEEEEEE);
  final Color _darkColor = Color(0xFF3C72C2);

  @override
  void initState() {
    _referenceController.text = widget.reference;
    if(widget.reference != ""){
      _isLogin = false;
      setState(() {});
    }
    super.initState();
  }

  Future<void> _loginWithGoogle() async {
    try {
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
  SliverAppBar _buildAppBar(bool isMobile) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      title: isMobile ? Image.asset(
        'assets/vitament1.png',
        height: isMobile ? 50 : 80,
        key: ValueKey('expanded-logo'),
      ).animate()
          .fadeIn(duration: 1000.ms)
          :
      AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child:  Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/vitament1.png',
            height: isMobile ? 40 : 70,
            key: ValueKey('collapsed-logo'),
          ),
        ),
      ),
      centerTitle: isMobile,
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return FlexibleSpaceBar(
            background: GlassmorphicContainer(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 0,
              blur: 30,
              border: 0,
              linearGradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [Colors.white24, Colors.white12],
              ),
            ),
          );
        },
      ),
      actions: isMobile ? null : [_buildDesktopMenu()],
      leading: isMobile
          ? IconButton(
        icon: Icon(Icons.menu, color: _darkColor),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      drawer: isMobile ? DrawerMenu(isLoggedIn: false) : null,
      body: _buildMainContent(isMobile),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: _gradientBackground
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(isMobile),
            SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 800) {
                          return _buildMobileLayout();
                        } else {
                          return _buildDesktopLayout();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopMenu() {
    return Row(
      children: [
        HeaderButton(title: 'Ana Sayfa', route: '/'),
        HeaderButton(title: 'Danışmanlıklar', route: '/courses'),
        HeaderButton(title: 'Blog', route: '/blogs'),
        HeaderButton(
          title: 'Giriş Yap / Kaydol',
          route: '/login',
        ),
      ],
    );
  }


  Widget _buildDesktopLayout() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: _isLogin ? Offset(-1, 0) : Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: _isLogin
                    ? _buildFormContainer(
                  child: _buildForm(),
                  imagePath: 'assets/therapy-login.jpg',
                )
                    : _buildFormContainer(
                  child: _buildForm(),
                  imagePath: 'assets/therapy-login.jpg',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContainer({required Widget child, required String imagePath}) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.5,
      width: MediaQuery.of(context).size.width / 3,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF222831),
        border: Border.all(color: Color(0xFF76ABAE), width: 2),
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [_backgroundColor, _primaryColor.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  child,
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
                ],
              ),
            ),
          ),
        ],
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
            borderRadius: BorderRadius.circular(3),
            side: const BorderSide(color: Color(0xFFEEEEEE), width: 2),
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
      if(_selectedRole == "Öğrenci")...[
        TextFormField(
          controller: _studentNameController,
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            labelText: 'Çocuğunuzun Adı',
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
          controller: _problemController,
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Çocuğunuzun Durumunu Özetleyin',
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RoleButton(
            role: 'Veli',
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
        onPressed: () async {
          await _signup();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF222831),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
            side: const BorderSide(color: Color(0xFFEEEEEE), width: 2),
          ),
        ),
        child: const Text('Kayıt Ol', style: TextStyle(color: Colors.white),),
      ),
    ];
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
          ],
        ),
      ),
    );
  }


  Future<void> _login() async {
    try {
      User? user = await AuthService().signInWithEmail(_emailController.text, _passwordController.text);
      context.go("/profile/" + user!.uid);
    } on FirebaseAuthException catch (e) {
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
        await FirestoreService().createStudentDocument(user!.uid, _emailController.text, _nameController.text, _studentNameController.text, _problemController.text, 21, "Ankara", "", _referenceController.text);
      }
      context.go("/profile/" + user.uid);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Kayıt hatası')),
      );
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context, String email) async {
    TextEditingController emailController = TextEditingController(text: email);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF222831),
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

class HeaderButton extends StatelessWidget {
  final String title;
  final String route;

  const HeaderButton({required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go(route),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Color(0xFF0344A3),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
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

