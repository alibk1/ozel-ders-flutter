import 'package:flutter/material.dart';

enum UserType {
  typeA,
  typeB,
  typeC,
}

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({Key? key}) : super(key: key);

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  /// Ekran "Login" mi, yoksa "Register" mı gösteriyor?
  bool isLogin = true;
  bool isMobile = false;

  /// Kayıt esnasında seçilecek kullanıcı tipi
  UserType selectedUserType = UserType.typeA;

  final Gradient _gradientBackground = LinearGradient(
    colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );


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

  BorderRadiusGeometry radius()
  {
    if(isMobile)
    {
      if(isLogin) return BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50));
      else return BorderRadius.only(topRight: Radius.circular(50), topLeft: Radius.circular(50));
    }
    else
      {
        if(isLogin) return BorderRadius.only(topRight: Radius.circular(80), bottomRight: Radius.circular(80));
        else return BorderRadius.only(bottomLeft: Radius.circular(80), topLeft: Radius.circular(80));
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
          decoration: InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person, size: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Köşeleri yuvarladık
              borderSide: BorderSide(width: 2.0,
                  color: Colors.black), // Kenarlık kalınlığı ve rengi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 2.0,
                  color: Colors.grey), // Varsayılan kenarlık kalınlığı
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 3.0,
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
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock, size: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Köşeleri yuvarladık
              borderSide: BorderSide(width: 2.0,
                  color: Colors.black), // Kenarlık kalınlığı ve rengi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 2.0,
                  color: Colors.grey), // Varsayılan kenarlık kalınlığı
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 3.0,
                  color: Colors.blue), // Odaklanıldığında kenarlık kalınlığı
            ),
            contentPadding: EdgeInsets.symmetric(
                vertical: 20, horizontal: 16), // Daha geniş iç boşluk
          ),
          obscureText: true,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // Şifremi unuttum
          },
          child: const Text(
            "Forgot password?",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Giriş yap
          },
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
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email, size: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Köşeleri yuvarladık
              borderSide: BorderSide(width: 2.0, color: Colors.black), // Kenarlık kalınlığı ve rengi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 2.0, color: Colors.grey), // Varsayılan kenarlık kalınlığı
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 3.0, color: Colors.blue), // Odaklanıldığında kenarlık kalınlığı
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Daha geniş iç boşluk
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          style: TextStyle(fontSize: 18), // Yazı boyutunu büyüttük
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock, size: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Köşeleri yuvarladık
              borderSide: BorderSide(width: 2.0, color: Colors.black), // Kenarlık kalınlığı ve rengi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 2.0, color: Colors.grey), // Varsayılan kenarlık kalınlığı
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 3.0, color: Colors.blue), // Odaklanıldığında kenarlık kalınlığı
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Daha geniş iç boşluk
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        // Kullanıcı tipine göre ek fieldlar
        _buildExtraFieldsForUserType(userType),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Kayıt ol
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

  /// Kullanıcı Tipi Dropdown
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

  /// Kullanıcı Tipine göre extra alanlar
  Widget _buildExtraFieldsForUserType(UserType userType) {
    switch (userType) {
      case UserType.typeA:
        return  TextFormField(
          style: TextStyle(fontSize: 18), // Yazı boyutunu büyüttük
          decoration: InputDecoration(
            labelText: 'Type A Specific Field',
            prefixIcon: Icon(Icons.info, size: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Köşeleri yuvarladık
              borderSide: BorderSide(width: 2.0, color: Colors.black), // Kenarlık kalınlığı ve rengi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 2.0, color: Colors.grey), // Varsayılan kenarlık kalınlığı
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 3.0, color: Colors.blue), // Odaklanıldığında kenarlık kalınlığı
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Daha geniş iç boşluk
          ),
        );
      case UserType.typeB:
        return  TextFormField(
          style: TextStyle(fontSize: 18), // Yazı boyutunu büyüttük
          decoration: InputDecoration(
            labelText: 'Type B Specific Field',
            prefixIcon: Icon(Icons.info_outline, size: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Köşeleri yuvarladık
              borderSide: BorderSide(width: 2.0, color: Colors.black), // Kenarlık kalınlığı ve rengi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 2.0, color: Colors.grey), // Varsayılan kenarlık kalınlığı
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 3.0, color: Colors.blue), // Odaklanıldığında kenarlık kalınlığı
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Daha geniş iç boşluk
          ),
        );
      case UserType.typeC:
        return  TextFormField(
          style: TextStyle(fontSize: 18), // Yazı boyutunu büyüttük
          decoration: InputDecoration(
            labelText: 'Type C Specific Field',
            prefixIcon: Icon(Icons.person_add, size: 28,),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Köşeleri yuvarladık
              borderSide: BorderSide(width: 2.0, color: Colors.black), // Kenarlık kalınlığı ve rengi
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 2.0, color: Colors.grey), // Varsayılan kenarlık kalınlığı
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 3.0, color: Colors.blue), // Odaklanıldığında kenarlık kalınlığı
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Daha geniş iç boşluk
          ),
        );
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
}
