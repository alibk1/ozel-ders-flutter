import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:flutter/services.dart';


import 'Components/LoadingIndicator.dart';

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
  String selectedUserType = "Danışan";
  List<String> userTypes = ["Danışan", "Danışman", "Kurum"];

  final Gradient _gradientBackground = const LinearGradient(
    colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  final Color _headerTextColor = const Color(0xFF222831);
  final Color _bodyTextColor = const Color(0xFF393E46);
  // Yeni eklenen controllerlar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> subCategories = [];
  String selectedCategoryTemp = "";
  String? selectedSubCategoryTemp;
  List<String> selectedCategories = [];
  List<String> selectedCategoriesNames = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isKVKKChecked = false;
  String kvkkText = "KVKK metni yükleniyor...";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }
  Future<void> loadData() async {
    categories = await FirestoreService().getCategories();
    print("yüklendi");
    setState(() {});
  }
  Future<void> _loadKVKKText() async {
    kvkkText = "VERİ SAHİBİNİN AÇIK RIZA BEYAN FORMU\n\nKişisel verilerimin, özel nitelikli kişisel verilerimin, sağlık verilerimin işlenmesine,\n"
        "tarafımca sözlü/yazılı ve/veya elektronik ortamda verilen kimliğimi belirleyen veya belirlemeye yarayanlar da dahil olmak üzere her türlü kişisel\n"
        "verimin, 6698 sayılı “Kişisel Verilerin Korunması Kanunu” ve “Kişisel Sağlık Verilerinin İşlenmesi ve Mahremiyetinin Sağlanması Hakkında Yönetmelik”\n"
        "gereğince, Ankara Yıldırım Beyazıt Üniversitesi tarafından;   Kişinin kimliğine dair bilgilerin bulunduğu verilerdir; ad-soyad, T.C.Kimlik numarası,\n"
        "uyruk bilgisi, anne adı-baba adı, doğum yeri, doğum tarihi, cinsiyet gibi bilgileri içeren ehliyet, nüfus cüzdanı ve pasaport gibi belgeler ile vergi numarası,\n"
        "SGK numarası, imza bilgisi, taşıt plakası v.b. bilgiler Telefon numarası, adres, e-mail adresi, faks numarası, IP adresi gibi bilgiler Fiziksel mekana girişte,\n"
        "fiziksel mekanın içerisinde kalış sırasında alınan kayıtlar ve belgelere ilişkin kişisel veriler; kamera kayıtları, parmak izi kayıtları ve güvenlik noktasında\n"
        "alınan kayıtlar Fotoğraf, kamera, video konferans ve toplantı kayıtları (Fiziksel Mekan Güvenlik Bilgisi kapsamında giren kayıtlar hariç), kişisel veri içeren belgelerin\n"
        "kopyası niteliğindeki belgelerde yer alan veriler Kişisel Verilerin Korunması Kanunu’nun 6. maddesinde belirtilen veriler (örn. kan grubu da dahil sağlık verileri,\n"
        " biyometrik veriler vb.) (Yabancı Öğrenciler İçin) ırkı, etnik kökeni, (Kimlikte Bulunması Halinde) dini, dernek, vakıf ya da sendika üyeliği, (Engel Durumu Olanlar İçin)\n"
        "sağlığı, ceza mahkûmiyeti ve güvenlik tedbirleriyle ilgili verileri ile biyometrik ve genetik verileri Ankara Yıldırım Beyazıt Üniversitesi’ne yöneltilmiş olan\n"
        "her türlü talep veya şikayetin alınması ve değerlendirilmesine ilişkin kişisel verilerimin  Yasadaki esaslar çerçevesinde toplanmasına, kaydedilmesine, işlenmesine,\n"
        "saklanmasına ve mevzuatta sayılı görevleri yerine getirebilmesi için yurt içi ve yurt dışı menşeili kurumlarla paylaşılmasına peşinen izin verdiğimi gayri kabili rücu\n"
        "olarak kabul, beyan ve taahhüt ederim.\n\n"
        "Ankara Yıldırım Beyazıt Üniversitesi tarafından Kişisel Verilerin Korunması ve İşlenmesi Hakkında web sitesinde bulunan Bilgilendirme metnini ve haklarımı okudum ve kabul ediyorum. ";
  }
  Widget kvkkCheckbox(BuildContext context, VoidCallback onChanged) {
    return Row(
      children: [
        Checkbox(
          value: isKVKKChecked,
          onChanged: (bool? newValue) {
            isKVKKChecked = newValue ?? false;
            onChanged();
          },
        ),
        GestureDetector(
          onTap: () async {
            await _loadKVKKText();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("KVKK Aydınlatma Metni"),
                content: SingleChildScrollView(
                  child: Text(kvkkText),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tamam"),
                  ),
                ],
              ),
            );
          },
          child: const Text(
            "KVKK Aydınlatma Metni'ni kabul ediyorum",
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    isMobile = size.width < 800;

    final containerAlignment = isMobile
        ? (isLogin ? Alignment.topCenter : Alignment.topCenter)
        : (isLogin ? Alignment.centerLeft : Alignment.centerRight);

    // Form için hizalama
    final formAlignment = isMobile
        ? (isLogin ? Alignment.bottomCenter : Alignment.bottomCenter)
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
        return const BorderRadius.only(
            bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50));
      else
        return const BorderRadius.only(
            topRight: Radius.circular(50), topLeft: Radius.circular(50));
    } else {
      if (isLogin)
        return const BorderRadius.only(
            topRight: Radius.circular(80), bottomRight: Radius.circular(80));
      else
        return const BorderRadius.only(
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "AYBÜKOM'a Hoşgeldiniz!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Danışmanlık İçin Doğru Adres",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Hoş Geldiniz",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        // Username
        TextFormField(
          style: const TextStyle(fontSize: 18), // Yazı boyutunu büyüttük
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'E-posta',
            prefixIcon: const Icon(Icons.person, size: 28),
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
        // Password
        TextFormField(
          style: const TextStyle(fontSize: 18), // Yazı boyutunu büyüttük
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Şifre',
            prefixIcon: const Icon(Icons.lock, size: 28),
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
          obscureText: true,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            _showChangePasswordDialog(context, _emailController.text);
          },
          child: const Text(
            "Şifrenizi mi unuttunuz?",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Gradient renkler
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20), // Köşeleri yuvarlak
          ),
          child: ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // Butonun kendi arkaplanını transparan yap
              shadowColor: Colors.transparent, // Gölgeyi kaldır
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Köşeleri yuvarlak
              ),
            ),
            child: const SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  "Giriş Yap",
                  style: TextStyle(
                    color: Colors.white, // Yazı rengi
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // "Don't have an account?"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Hesabınız yok mu? "),
            InkWell(
              onTap: () {
                setState(() {
                  isLogin = false; // Register ekranına geç
                });
              },
              child: const Text(
                "Kayıt Ol",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        )
      ],
    );
  }

  /// Register Form'unu döndüren widget metodu
  Widget _buildRegisterForm(String userType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Aramıza Katılmaya Bir Adım Uzaktasın!",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        // Kullanıcı Tipi Seçimi
        const Text(
          "Kullanıcı Tipi Seçiniz:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),

        ),
        const SizedBox(height: 20),
        //_buildUserTypeDropdown(),
        _buildUserTypeSelection(),
        const SizedBox(height: 24),
        TextFormField(
          style: const TextStyle(fontSize: 18), // Yazı boyutunu büyüttük
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Adınız',
            prefixIcon: const Icon(Icons.person, size: 28),
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
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'E-posta',
            prefixIcon: const Icon(Icons.email, size: 28),
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
            labelText: 'Şifre',
            prefixIcon: const Icon(Icons.lock, size: 28),
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
          obscureText: true,
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _buildExtraFieldsForUserType(userType),
        ),
        const SizedBox(height: 16),
        kvkkCheckbox(context, () => setState(() {})),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Gradient renkler
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20), // Köşeleri yuvarlak
          ),
          child: ElevatedButton(
            onPressed: () async {
              await _signup();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // Butonun kendi arkaplanını transparan yap
              shadowColor: Colors.transparent, // Gölgeyi kaldır
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Köşeleri yuvarlak
              ),
            ),
            child: const SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  "Kayıt Ol",
                  style: TextStyle(
                    color: Colors.white, // Yazı rengi beyaz
                    fontWeight: FontWeight.bold, // Font kalın (bold)
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Zaten hesabın var mı?
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Kayıtlı bir hesabınız mı var? "),
            InkWell(
              onTap: () {
                setState(() {
                  isLogin = true; // Login ekranına geç
                });
              },
              child: const Text(
                "Giriş Yap!",
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
    return DropdownButton<String>(
      value: selectedUserType,
      items: userTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
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

  Widget _buildUserTypeSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: userTypes.map((type) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // Köşeleri yuvarlak
              border: selectedUserType == type
                  ? null // Seçili olan için border yok
                  : Border.all(color: Colors.black, width: 1), // Seçili olmayanlar için siyah border
              gradient: selectedUserType == type
                  ? const LinearGradient(
                colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Seçiliyse gradient ekle
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null, // Seçili değilse arkaplan yok
            ),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  selectedUserType = type;
                });
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent, // Arkaplanı transparan bırak
                side: const BorderSide(color: Colors.transparent), // Border'ı transparan yap
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Köşeleri yuvarlak
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                type.toString().split('.').last,
                style: const TextStyle(
                  color: Colors.black, // Yazı rengi siyah
                  fontWeight: FontWeight.normal, // Font kalın (bold) değil
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildSelectedCategoriesChips() {
    return Wrap(
      spacing: 8.0, // Yatay boşluk
      runSpacing: 4.0, // Dikey boşluk
      children: List.generate(selectedCategoriesNames.length, (index) {
        return Chip(
          label: Text(selectedCategoriesNames[index]),
          deleteIcon: const Icon(Icons.close),
          onDeleted: () {
            setState(() {
              // İki listede de aynı index'teki değeri kaldırıyoruz
              selectedCategoriesNames.removeAt(index);
              selectedCategories.removeAt(index);
              print(selectedCategoriesNames);
              print(selectedCategories);
            });
          },
        );
      }),
    );
  }

// ayrı ayrı kişilikler falan ayru field'lar
  Widget _buildExtraFieldsForUserType(String userType) {
    switch (userType) {
      case "Danışan":
        return Column(
          key: const ValueKey("Danışan"),
          children: [
            TextFormField(
              style: const TextStyle(fontSize: 18),
              controller: _referenceController,
              decoration: InputDecoration(
                labelText: 'Referans Kodu',
                prefixIcon: const Icon(Icons.code, size: 28),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 2.0, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _studentNameController,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Çocuğunuzun Adı',
                prefixIcon: const Icon(Icons.child_care, size: 28),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 2.0, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('İlgilendiğiniz Kategorileri Seçiniz:', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            buildSelectedCategoriesChips(),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              value: selectedCategoryTemp.isEmpty ? null : selectedCategoryTemp,
              hint: Text('Kategori Seç', style: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7))),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategoryTemp = newValue ?? "";
                  // Kategori değiştiği için alt kategoriler listesi yenileniyor
                  subCategories = categories.firstWhere((c) => c["UID"] == selectedCategoryTemp)["subCategories"];
                  // İkinci dropdown'ın seçili değerini sıfırlıyoruz
                  selectedSubCategoryTemp = null;
                });
              },
              items: categories.map<DropdownMenuItem<String>>((cat) {
                return DropdownMenuItem<String>(
                  value: cat['UID'],
                  child: Text(cat['name'], style: GoogleFonts.poppins(color: _bodyTextColor)),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            if(selectedCategoryTemp != "") DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              value: selectedSubCategoryTemp,
              hint: Text('Alt Kategori Seç', style: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7))),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSubCategoryTemp = newValue;
                if (newValue != null) {
                  final String combined = "$selectedCategoryTemp-$newValue";
                  if(!selectedCategories.contains(combined)) {
                    selectedCategories.add(combined);
                  }
                  String subCatName = subCategories.firstWhere((c) => c["UID"] == newValue)["name"];
                  if(!selectedCategoriesNames.contains(subCatName)) {
                    selectedCategoriesNames.add(subCatName);
                  }
                  print(selectedCategoriesNames);
                  print(selectedCategories);
                }
                });
              },
              items: subCategories.map<DropdownMenuItem<String>>((cat) {
                return DropdownMenuItem<String>(
                  value: cat['UID'],
                  child: Text(cat['name'], style: GoogleFonts.poppins(color: _bodyTextColor)),
                );
              }).toList(),
            ),
          ],
        );
      case "Danışman":
        return Column(
          key: const ValueKey("Danışman"),
          children: [
            TextFormField(
              style: const TextStyle(fontSize: 18),
              controller: _referenceController,
              decoration: InputDecoration(
                labelText: 'Referans Kodu',
                prefixIcon: const Icon(Icons.code, size: 28),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 2.0, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      default:
        return Container();
    }
  }

  Future<void> _login() async {
    try {
      // Giriş işlemi yapılırken hata alırsan catch bloğuna düşecek
      User? user = await AuthService()
          .signInWithEmail(_emailController.text, _passwordController.text);

      context.go("/profile/" + user!.uid);

    } catch (e) {
      // Herhangi bir hata oluştuğunda burada yakalanır
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is FirebaseAuthException
                ? e.message ?? 'Giriş hatası'
                : 'Giriş Yaparken Bir Sorun Oluştu',
          ),
        ),
      );
    }
  }

  Future<void> _signup() async {
    try {
      User? user = await AuthService()
          .registerWithEmail(_emailController.text, _passwordController.text);
      if (selectedUserType == "Danışman") {
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
      if (selectedUserType == "Kurum") {
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
            _referenceController.text, selectedCategories);
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
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
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Kapama işlemi
                    },
                  ),
                ),
                const Text(
                  "Kayıt Olurken Kullandığınız E-posta'yı Giriniz:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                    height: 20), // E-posta field ile yazı arasındaki boşluk
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.black),
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    LoadingIndicator(context).showLoading();
                    await AuthService()
                        .sendPasswordResetEmail(emailController.text);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Gönder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3C72C2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
