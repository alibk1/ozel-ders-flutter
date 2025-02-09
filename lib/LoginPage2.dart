import 'package:flutter/material.dart';
import 'package:ozel_ders/services/FirebaseController.dart';

import 'Components/LoadingIndicator.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({Key? key}) : super(key: key);

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  // Durum kontrolü
  bool _isLogin = false; // false => Kayıt ekranı, true => Giriş ekranı
  String _selectedRole = "Öğrenci";

  // TextEditingController örnekleri
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referenceController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _problemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Genişliğe göre responsive davranış
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      // Arka plan rengi, görsel benzeri bir peach rengiyle ayarlanabilir
      backgroundColor: const Color(0xFFFDEAE0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 800) {
              // Mobil görünüm => Üstte görsel, altta form
              return _buildMobileLayout();
            } else {
              // Masaüstü görünüm => Solda görsel, sağda form
              return _buildDesktopLayout();
            }
          },
        ),
      ),
    );
  }

  // ******************** DESKTOP LAYOUT ********************
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Arka plan görseli
                Image.asset(
                  'assets/therapy-login3.jpg',
                  fit: BoxFit.cover,
                ),
                // Üstüne slogan
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "En Yenilikçi Danışmanlık Platformu",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "AYBÜKOM © 2025",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        // İsterseniz slider noktaları vb.
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sağdaki kısım: Formun bulunduğu bölge
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      _isLogin ? "Welcome Back" : "Get Started",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Alt metin: already have an account? sign in ...
                    _isLogin
                        ? Row(
                      children: [
                        const Text("Henüz kayıt olmadınız mı? ",
                            style: TextStyle(color: Colors.black54)),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLogin = false;
                            });
                          },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                        : Row(
                      children: [
                        const Text("Hesabınız var mı? ",
                            style: TextStyle(color: Colors.black54)),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLogin = true;
                            });
                          },
                          child: const Text(
                            "Sign in",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Form
                    _buildForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ******************** MOBILE LAYOUT ********************
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Üstte görsel
          SizedBox(
            height: 250,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/therapy-login3.jpg',
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "En Yenilikçi Danışmanlık Platformu",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "AYBÜKOM © 2025",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Altta form
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLogin ? "Tekrar Hoşgeldiniz" : "Sizi Bekliyoruz",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Alt metin
                  _isLogin
                      ? Row(
                    children: [
                      const Text("Henüz kayıt olmadınız mı? ",
                          style: TextStyle(color: Colors.black54)),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = false;
                          });
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                      : Row(
                    children: [
                      const Text("Hesabınız var mı? ",
                          style: TextStyle(color: Colors.black54)),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = true;
                          });
                        },
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ******************** FORM ALANI (LOGIN / SIGNUP) ********************
  Widget _buildForm() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isLogin
          ? Column(
        key: const ValueKey<bool>(true),
        children: _buildLoginFields(),
      )
          : Column(
        key: const ValueKey<bool>(false),
        children: _buildSignupFields(),
      ),
    );
  }

  // **** GİRİŞ EKRANI FİELD'LARI ****
  List<Widget> _buildLoginFields() {
    return [
      // Name (Örnek: Screenshot'ta sign in'de "Name" alanı var)
      TextFormField(
        controller: _nameController,
        decoration: _inputDecoration(labelText: "İsim"),
      ),
      const SizedBox(height: 12),
      // Password
      TextFormField(
        controller: _passwordController,
        decoration: _inputDecoration(labelText: "Şifre"),
        obscureText: true,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text("Sign In",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () {
          // Şifremi unuttum işlemi
          _showChangePasswordDialog(context, _emailController.text);
        },
        child: const Text(
          "Forgot your password or your login details?\nGet help signing in",
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
      ),
    ];
  }

  // **** KAYIT EKRANI FİELD'LARI ****
  List<Widget> _buildSignupFields() {
    return [
      // Name
      TextFormField(
        controller: _nameController,
        decoration: _inputDecoration(labelText: "İsim"),
      ),
      const SizedBox(height: 12),
      // Email
      TextFormField(
        controller: _emailController,
        decoration: _inputDecoration(labelText: "E-posta"),
      ),
      const SizedBox(height: 12),
      // Password
      TextFormField(
        controller: _passwordController,
        decoration: _inputDecoration(labelText: "Şifre"),
        obscureText: true,
      ),
      const SizedBox(height: 12),

      // 3 farklı kullanıcı seçeneği
      // (Öğrenci, Öğretmen, Kurum) => örnek
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _roleButton("Öğrenci"),
          _roleButton("Öğretmen"),
          _roleButton("Kurum"),
        ],
      ),
      const SizedBox(height: 12),

      // Kurum seçili değilse Referans Kodu
      if (_selectedRole != "Kurum")
        TextFormField(
          controller: _referenceController,
          decoration:
          _inputDecoration(labelText: "Referans Kodu (Opsiyonel)"),
        ),
      if (_selectedRole != "Kurum") const SizedBox(height: 12),

      // Öğrenci ise ekstra iki alan
      if (_selectedRole == "Öğrenci") ...[
        TextFormField(
          controller: _studentNameController,
          decoration: _inputDecoration(labelText: "Çocuğunuzun Adı"),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _problemController,
          maxLines: 3,
          decoration:
          _inputDecoration(labelText: "Çocuğunuzun Durumunu Özetleyin"),
        ),
      ],
      if (_selectedRole == "Öğrenci") const SizedBox(height: 12),

      // Sign Up butonu
      ElevatedButton(
        onPressed: _signup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text("Sign Up",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      const SizedBox(height: 12),
      // Terms of Service
      const Text(
        "By signing up, I agree to the Terms of Service and Privacy Policy",
        style: TextStyle(color: Colors.black54, fontSize: 13),
      ),
    ];
  }

  // Ortak input dekorasyonu
  InputDecoration _inputDecoration({required String labelText}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.black87),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.orangeAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Rol seçimi için buton
  Widget _roleButton(String role) {
    final isSelected = (role == _selectedRole);
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orangeAccent.withOpacity(0.2) : null,
          border: Border.all(
            color: isSelected ? Colors.orangeAccent : Colors.black26,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          role,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ******************** BUTON FONKSİYONLARI ********************
  void _login() {
    // Giriş işlemleri
    debugPrint(
        "Giriş Yapılıyor: ${_nameController.text} / ${_passwordController.text}");
  }

  void _signup() {
    // Kayıt işlemleri
    debugPrint("Kayıt => Ad: ${_nameController.text}");
    debugPrint("Rol: $_selectedRole");
    if (_selectedRole == "Öğrenci") {
      debugPrint("Çocuk: ${_studentNameController.text}");
      debugPrint("Durumu: ${_problemController.text}");
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context, String email) async {
    TextEditingController emailController = TextEditingController(text: email);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Arka planı saydam, üstte "Container" var
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFFfdeae0), // Alt katman: beyaz kart görünümü
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Wrap(
            children: [
              const SizedBox(height: 50),
              const Text(
                "Kayıt Olurken Kullandığınız E-posta'yı Giriniz:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'E-posta',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.orangeAccent),
                  ),
                ),
              ),
              const SizedBox(height: 75),
              ElevatedButton(
                onPressed: () async {
                  LoadingIndicator(context).showLoading();
                  await AuthService().sendPasswordResetEmail(emailController.text);
                  Navigator.pop(context); // BottomSheet kapat
                  Navigator.pop(context); // Şifre sıfırlama için açılan başka bir sayfanız varsa, onu da kapatabilir
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white, // Metin rengi
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Şifre Sıfırlama Bağlantısı Gönder'),
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }
}
