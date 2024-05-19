import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/Components/ContactForm.dart';
import 'package:ozel_ders/Components/Footer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoggedIn = false; // Bu alan giriş yapma durumunu kontrol etmek için kullanılacak.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF009899),
        title: Image.asset('assets/header.png', height: MediaQuery.of(context).size.width < 600 ? 300 : 400),
        centerTitle: MediaQuery.of(context).size.width < 600 ? true : false,
        leading: MediaQuery.of(context).size.width < 600
            ? IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        )
            : null,
        actions: MediaQuery.of(context).size.width >= 600
            ? [
          TextButton(
            onPressed: ()
            {
              context.go('/'); // CategoriesPage'e yönlendirme
            },             child: Text('Ana Sayfa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: ()
            {
              context.go('/categories'); // CategoriesPage'e yönlendirme
            },
            child: Text('Kategoriler', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: ()
            {
              context.go('/courses'); // CategoriesPage'e yönlendirme
            },
            child: Text('Kurslar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {}, //
            child: Text('Randevularım', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: isLoggedIn ? () {} : () {}, // TODO: Giriş Yap / Kaydol veya Profilim sayfasına git
            child: Text(isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]
            : null,
      ),
      drawer: MediaQuery.of(context).size.width < 600
          ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF009899),
              ),
              child: Image.asset('assets/header.png', height: 200),
            ),
            ListTile(
              title: Text('Ana Sayfa'),
              onTap: () {}, // TODO: Ana Sayfa'ya git
            ),
            ListTile(
              title: Text('Kategoriler'),
              onTap: () {}, // TODO: Kategoriler sayfasına git
            ),
            ListTile(
              title: Text('Kurslar'),
              onTap: () {}, // TODO: Kurslar sayfasına git
            ),
            ListTile(
              title: Text('Randevularım'),
              onTap: () {}, // TODO: Randevularım sayfasına git
            ),
            ListTile(
              title: Text(isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol'),
              onTap: isLoggedIn ? () {} : () {}, // TODO: Giriş Yap / Kaydol veya Profilim sayfasına git
            ),
          ],
        ),
      )
          : null,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HeaderSection(),
            IntroductionSection(),
            FooterSection(),
          ],
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Color(0xFF009899),
      child: Center(
        child: Image.asset('assets/mantalk.jpg', height: 0),
      ),
    );
  }
}

class IntroductionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SectionTitle(title: 'Biz Kimiz?'),
          SizedBox(height: 16),
          SectionContent(
            text:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet.',
            imagePath: "assets/mantalk.jpg",
          ),
          SizedBox(height: 32),
          SectionTitle(title: 'Neler Sunuyoruz?'),
          SizedBox(height: 16),
          SectionContent(
            text:
            'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
            imagePath: "assets/therapy.jpg",
          ),
          SizedBox(height: 32),
          SectionTitle(title: 'Bizimle İletişime Geçin'),
          SizedBox(height: 16),
          ContactForm(),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class SectionContent extends StatelessWidget {
  final String text;
  final String imagePath;

  SectionContent({required this.text, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 20,),
        Image.asset(
          imagePath,
          width: MediaQuery.of(context).size.width < 600
              ?  MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 7 / 10,

        ),
      ],
    );
  }
}