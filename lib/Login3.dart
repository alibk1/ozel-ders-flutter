import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders/services/FirebaseController.dart';

import 'Components/LoadingIndicator.dart';

enum UserType {
  Veli,
  Ogretmen,
  Kurum,
}

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({Key? key}) : super(key: key);

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen>
    with SingleTickerProviderStateMixin {
  /// Ekran "Login" mi, yoksa "Register" mı gösteriyor?
  bool isLogin = true;
  bool isMobile = false;

  /// Kayıt esnasında seçilecek kullanıcı tipi
  UserType selectedUserType = UserType.Veli;

  final Gradient _gradientBackground = LinearGradient(
    colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Yeni eklenen controllerlar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(); // Yeni TextField için controller


  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    isMobile = size.width < 800;

    final containerAlignment = isMobile
        ? (isLogin ? Alignment.topCenter : Alignment.bottomCenter)
        : (isLogin ? Alignment.centerLeft : Alignment.centerRight);

    // Form için hizalama
    final formAlignment = isMobile
        ? (isLogin ? Alignment.bottomCenter : Alignment.topCenter)
        : (isLogin ? Alignment.centerRight : Alignment.centerLeft);

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          // İki öğeyi üst üste koymak için Stack kullandık
          child: Stack(
            children: [
              // Mavi Container (Welcome kısmı)
              AnimatedAlign(
                alignment: containerAlignment,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                // Masaüstünde genişliğin belli bir yüzdesini, mobilde yüksekliğin belli bir yüzdesini kaplasın
                child: isMobile
                    ? SizedBox(
                        width: size.width,
                        height: size.height * 0.35,
                        child: _buildWelcomeSection(),
                      )
                    : SizedBox(
                        width: size.width * 0.4,
                        height: size.height,
                        child: _buildWelcomeSection(),
                      ),
              ),

              // Form kısmı (Login veya Register)
              AnimatedAlign(
                alignment: formAlignment,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: isMobile
                    ? SizedBox(
                        width: size.width,
                        height: size.height * 0.65,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: isLogin
                                ? _buildLoginForm()
                                : _buildRegisterForm(selectedUserType),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: size.width * 0.6,
                        height: size.height,
                        child: Center(
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: 400, // Masaüstünde formun genişliği
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: isLogin
                                    ? _buildLoginForm()
                                    : _buildRegisterForm(selectedUserType),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BorderRadiusGeometry radius() {
    if (isMobile) {
      if (isLogin)
        return BorderRadius.only(
            bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50));
      else
        return BorderRadius.only(
            topRight: Radius.circular(50), topLeft: Radius.circular(50));
    } else {
      if (isLogin)
        return BorderRadius.only(
            topRight: Radius.circular(80), bottomRight: Radius.circular(80));
      else
        return BorderRadius.only(
            bottomLeft: Radius.circular(80), topLeft: Radius.circular(80));
    }
  }

  Widget _buildWelcomeSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        gradient: _gradientBackground,
        borderRadius: radius(),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "AYBÜKOM'a Hoşgeldiniz!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Danışmanlık İçin Doğru Adres",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// Login Form'unu döndüren widget metodu
  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Login",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        // Username
        TextFormField(
          style: TextStyle(fontSize: 18), // Yazı boyutunu büyüttük
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.person, size: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Köşeleri yuvarladık
              borderSide: BorderSide(
                  width: 2.0,
                  color: Colors.black), // Kenarlık kalınlığı ve rengi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  width: 2.0,
                  color: Colors.grey), // Varsayılan kenarlık kalınlığı
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  width: 3.0,
                  color: Colors.blue), // Odaklanıldığında kenarlık kalınlığı
            ),
            contentPadding: EdgeInsets.symmetric(
                vertical: 20, horizontal: 16), // Daha geniş iç boşluk
          ),
        ),
        const SizedBox(height: 16),
        // Password
        TextFormField(
          style: TextStyle(fontSize: 18), // Yazı boyutunu büyüttük
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock, size: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Köşeleri yuvarladık
              borderSide: BorderSide(
                  width: 2.0,
                  color: Colors.black), // Kenarlık kalınlığı ve rengi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  width: 2.0,
                  color: Colors.grey), // Varsayılan kenarlık kalınlığı
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  width: 3.0,
                  color: Colors.blue), // Odaklanıldığında kenarlık kalınlığı
            ),
            contentPadding: EdgeInsets.symmetric(
                vertical: 20, horizontal: 16), // Daha geniş iç boşluk
          ),
          obscureText: true,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            _showChangePasswordDialog(context, _emailController.text);
          },
          child: const Text(
            "Forgot password?",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          // giriş yap butonu için düzenlenecek
          onPressed: _login,
          child: const SizedBox(
            width: double.infinity,
            child: Center(child: Text("Login")),
          ),
        ),
        const SizedBox(height: 16),
        // "Don't have an account?"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account? "),
            InkWell(
              onTap: () {
                setState(() {
                  isLogin = false; // Register ekranına geç
                });
              },
              child: const Text(
                "Register",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        )
      ],
    );
  }

  /// Register Form'unu döndüren widget metodu
  Widget _buildRegisterForm(UserType userType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Register",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        // Kullanıcı Tipi Seçimi
        const Text("Kullanıcı Tipi Seçiniz:"),
        const SizedBox(height: 8),
        _buildUserTypeDropdown(),
        const SizedBox(height: 24),
        // Ortak Alanlar

        TextFormField(
          style: TextStyle(fontSize: 18), // Yazı boyutunu büyüttük
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Adınız',
            prefixIcon: Icon(Icons.person, size: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Köşeleri yuvarladık
              borderSide: const BorderSide(
                  width: 2.0,
                  color: Colors.black), // Kenarlık kalınlığı ve rengi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  width: 2.0,
                  color: Colors.grey), // Varsayılan kenarlık kalınlığı
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  width: 3.0,
                  color: Colors.blue), // Odaklanıldığında kenarlık kalınlığı
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 20, horizontal: 16), // Daha geniş iç boşluk
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          style: TextStyle(fontSize: 18), // Yazı boyutunu büyüttük
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email, size: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Köşeleri yuvarladık
              borderSide: const BorderSide(
                  width: 2.0,
                  color: Colors.black), // Kenarlık kalınlığı ve rengi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  width: 2.0,
                  color: Colors.grey), // Varsayılan kenarlık kalınlığı
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  width: 3.0,
                  color: Colors.blue), // Odaklanıldığında kenarlık kalınlığı
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 20, horizontal: 16), // Daha geniş iç boşluk
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          style: const TextStyle(fontSize: 18), // Yazı boyutunu büyüttük
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock, size: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Köşeleri yuvarladık
              borderSide: BorderSide(
                  width: 2.0,
                  color: Colors.black), // Kenarlık kalınlığı ve rengi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  width: 2.0,
                  color: Colors.grey), // Varsayılan kenarlık kalınlığı
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  width: 3.0,
                  color: Colors.blue), // Odaklanıldığında kenarlık kalınlığı
            ),
            contentPadding: EdgeInsets.symmetric(
                vertical: 20, horizontal: 16), // Daha geniş iç boşluk
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _buildExtraFieldsForUserType(userType),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            await _signup();
          },
          child: const SizedBox(
            width: double.infinity,
            child: Center(child: Text("Register")),
          ),
        ),
        const SizedBox(height: 16),
        // Zaten hesabın var mı?
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account? "),
            InkWell(
              onTap: () {
                setState(() {
                  isLogin = true; // Login ekranına geç
                });
              },
              child: const Text(
                "Login",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }

// Kullanıcı Tipi Dropdown
  Widget _buildUserTypeDropdown() {
    return DropdownButton<UserType>(
      value: selectedUserType,
      items: UserType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.toString().split('.').last),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedUserType = value;
          });
        }
      },
    );
  }

// ayrı ayrı kişilikler falan ayru field'lar
  Widget _buildExtraFieldsForUserType(UserType userType) {
    switch (userType) {
      case UserType.Veli: // veli için
        return Column(
          key: ValueKey("Veli"),
          children: [
            TextFormField(
              style: TextStyle(fontSize: 18),
              controller: _referenceController,
              decoration: InputDecoration(
                labelText: 'Referans Kodu',
                prefixIcon: Icon(Icons.code, size: 28),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 2.0, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _studentNameController,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Çocuğunuzun Adı',
                prefixIcon: Icon(Icons.child_care, size: 28),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 2.0, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              style: TextStyle(fontSize: 18),
              controller: _problemController,
              decoration: InputDecoration(
                labelText: 'Çocuğunuzun Durumunu Özetleyiniz',
                prefixIcon: Icon(Icons.notes, size: 28),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 2.0, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // GestureDetector(
            //   onTap: () async {
            //     DateTime? pickedDate = await showDatePicker(
            //       context: context,
            //       initialDate: DateTime.now(),
            //       firstDate: DateTime(1900),
            //       lastDate: DateTime.now(),
            //     );
            //     if (pickedDate != null) {
            //       setState(() {
            //         _dateController.text =
            //             DateFormat('yyyy-MM-dd').format(pickedDate);
            //       });
            //     }
            //   },
            //   child: AbsorbPointer(
            //     child: TextFormField(
            //       controller: _dateController,
            //       style: TextStyle(fontSize: 18),
            //       decoration: InputDecoration(
            //         labelText: 'Doğum Tarihiniz',
            //         prefixIcon: Icon(Icons.calendar_today, size: 28),
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(12),
            //           borderSide: BorderSide(width: 2.0, color: Colors.black),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        );
      case UserType.Ogretmen:
        return Column(
          key: ValueKey("Ogretmen"),
          children: [
            TextFormField(
              style: TextStyle(fontSize: 18),
              controller: _referenceController,
              decoration: InputDecoration(
                labelText: 'Referans Kodu',
                prefixIcon: Icon(Icons.code, size: 28),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 2.0, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // GestureDetector(
            //   onTap: () async {
            //     DateTime? pickedDate = await showDatePicker(
            //       context: context,
            //       initialDate: DateTime.now(),
            //       firstDate: DateTime(1900),
            //       lastDate: DateTime.now(),
            //     );
            //     if (pickedDate != null) {
            //       setState(() {
            //         _dateController.text =
            //             DateFormat('yyyy-MM-dd').format(pickedDate);
            //       });
            //     }
            //   },
            //   child: AbsorbPointer(
            //     child: TextFormField(
            //       controller: _dateController,
            //       style: TextStyle(fontSize: 18),
            //       decoration: InputDecoration(
            //         labelText: 'Doğum Tarihiniz',
            //         prefixIcon: Icon(Icons.calendar_today, size: 28),
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(12),
            //           borderSide: BorderSide(width: 2.0, color: Colors.black),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        );
      default:
        return Container();
    }
  }


  /// Sosyal giriş butonları (örnek)
  Widget _buildSocialButton(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {
        // Sosyal giriş fonksiyonu
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _login() async {
    try {
      User? user = await AuthService()
          .signInWithEmail(_emailController.text, _passwordController.text);
      context.go("/profile/" + user!.uid);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Giriş hatası')),
      );
    }
  }

  Future<void> _signup() async {
    try {
      User? user = await AuthService()
          .registerWithEmail(_emailController.text, _passwordController.text);
      if (UserType == "Öğretmen") {
        await FirestoreService().createTeacherDocument(
            user!.uid,
            _emailController.text,
            _nameController.text,
            21,
            "Ne Ararsan",
            3.5,
            "",
            _referenceController.text);
      }
      if (UserType == "Kurum") {
        await FirestoreService().createTeamDocument(user!.uid,
            _emailController.text, _nameController.text, "Ankara", "", 10);
      } else {
        await FirestoreService().createStudentDocument(
            user!.uid,
            _emailController.text,
            _nameController.text,
            _studentNameController.text,
            _problemController.text,
            21,
            "Ankara",
            "",
            _referenceController.text);
      }
      context.go("/profile/" + user.uid);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Kayıt hatası')),
      );
    }
  }

  Future<void> _showChangePasswordDialog(
      BuildContext context, String email) async {
    TextEditingController emailController = TextEditingController(text: email);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 525, // Kutunun genişliğini 1.5 katına çıkardık
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Yüksekliğin içeriğe göre otomatik olmasını sağlar
              children: [
                // Çarpı (Kapatma) Butonu
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Kapama işlemi
                    },
                  ),
                ),
                Text(
                  "Kayıt Olurken Kullandığınız E-posta'yı Giriniz:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                    height: 20), // E-posta field ile yazı arasındaki boşluk
                TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'E-posta',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    LoadingIndicator(context).showLoading();
                    await AuthService()
                        .sendPasswordResetEmail(emailController.text);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Gönder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF3C72C2),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
