import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ozel_ders/Components/ContactForm.dart';
import 'package:ozel_ders/Components/Drawer.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/FirebaseController.dart';
import 'package:ozel_ders/services/JitsiService.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoggedIn = false;
  bool isLoading = true;

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    isLoggedIn = await AuthService().isUserSignedIn();
    print(isLoggedIn);
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Ekran boyutunu belirlemek için MediaQuery kullanıyoruz
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFEEEEEE),
      drawer: screenWidth < 800 ? DrawerMenu(isLoggedIn: isLoggedIn) : null,
      body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/therapy-main.jpg",
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.darken,
              ),
            ),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // SliverAppBar ile logo ve menüyü koruyoruz
                  SliverAppBar(
                    backgroundColor: Color(0xFF222831),
                    title: Image.asset(
                      'assets/vitament1.png',
                      height:
                      MediaQuery
                          .of(context)
                          .size
                          .width < 800 ? 60 : 80,
                    ),
                    centerTitle: true,
                    pinned: true,
                    expandedHeight: 100.0,
                    bottom: PreferredSize(
                      preferredSize: Size(MediaQuery
                          .of(context)
                          .size
                          .width, MediaQuery
                          .of(context)
                          .size
                          .width > 800 ? 30 : 1),
                      child: MediaQuery
                          .of(context)
                          .size
                          .width > 800 ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              context.go('/');
                            },
                            child: Text('Ana Sayfa',
                                style: TextStyle(
                                    color: Color(0xFF76ABAE),
                                    fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/categories');
                            },
                            child: Text('Kategoriler',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/courses');
                            },
                            child: Text('Kurslar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          isLoggedIn
                              ? TextButton(
                            onPressed: () {
                              context.go('/appointments/' +
                                  AuthService().userUID());
                            },
                            child: Text('Randevularım',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )
                              : SizedBox.shrink(),
                          TextButton(
                            onPressed: isLoggedIn
                                ? () {
                              context
                                  .go('/profile/' + AuthService().userUID());
                            }
                                : () {
                              context.go('/login');
                            },
                            child: Text(
                                isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ) : SizedBox.shrink(),
                    ),
                    leading: MediaQuery
                        .of(context)
                        .size
                        .width < 600
                        ? IconButton(
                      icon: Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer();
                      },
                    )
                        : null,
                  ),
                  // İçerik bölümlerini SliverList ile oluşturuyoruz
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        IntroductionSection(),
                        FooterSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
      ),
    );
  }
}

// Header menüsünü ayrı bir widget olarak tanımlıyoruz
class HeaderMenu extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;

  const HeaderMenu({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF222831),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HeaderMenuItem(title: 'Ana Sayfa', route: '/'),
          HeaderMenuItem(title: 'Kategoriler', route: '/categories'),
          HeaderMenuItem(title: 'Kurslar', route: '/courses'),
          if (isLoggedIn)
            HeaderMenuItem(
                title: 'Randevularım',
                route: '/appointments/${AuthService().userUID()}'),
          HeaderMenuItem(
            title: isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol',
            route:
            isLoggedIn ? '/profile/${AuthService().userUID()}' : '/login',
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}

class HeaderMenuItem extends StatelessWidget {
  final String title;
  final String route;

  const HeaderMenuItem({required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.go(route);
      },
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class IntroductionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ekran boyutunu almak için MediaQuery kullanıyoruz
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      padding:
      EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SectionTitle(title: 'Biz Kimiz?'),
          SizedBox(height: 16),
          SectionContent(
            text:
            'Biz, online rehabilitasyon ve terapi hizmetleri sunan, alanında uzman bir ekibiz. Amacımız, bireylerin fiziksel ve mental sağlıklarını iyileştirmek için güvenilir, etkili ve kişiselleştirilmiş çözümler sunmaktır. Tecrübeli terapistlerden oluşan kadromuz, her bireyin ihtiyaçlarına özel yaklaşımlar geliştirerek, onların yaşam kalitesini artırmayı hedeflemektedir. Modern teknolojiyi kullanarak, her yerden erişilebilir hizmetler sunuyor ve danışanlarımızın en iyi sonuçları elde etmeleri için sürekli olarak kendimizi geliştiriyoruz.',
            imagePaths: ["assets/mantalk.jpg", "assets/therapy.jpg"],
            reverse: false,
          ),
          SizedBox(height: 32),
          SectionTitle(title: 'Neler Sunuyoruz?'),
          SizedBox(height: 16),
          SectionContent(
            text:
            'Geniş yelpazede online rehabilitasyon ve terapi hizmetleri sunuyoruz. Fiziksel terapi, konuşma terapisi, psikolojik danışmanlık ve mesleki rehabilitasyon gibi farklı alanlarda uzmanlaşmış ekibimizle, her bireyin ihtiyacına uygun çözümler üretiyoruz. Ayrıca, bireysel ve grup seansları, özel programlar ve danışan takibi gibi hizmetlerle, danışanlarımızın tedavi sürecini destekliyoruz. Modern teknolojik altyapımız sayesinde, kullanıcı dostu ve erişilebilir bir hizmet deneyimi sunuyor, her yerden kolayca erişim imkanı sağlıyoruz.',
            imagePaths: ["assets/therapy.jpg", "assets/mantalk.jpg"],
            reverse: true,
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
    // Başlık stilini daha belirgin hale getiriyoruz
    return Text(
      title,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF222831),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class SectionContent extends StatelessWidget {
  final String text;
  final List<String> imagePaths;
  final bool reverse;

  SectionContent({
    required this.text,
    required this.imagePaths,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    // Ekran boyutuna göre düzeni ayarlıyoruz
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    // İçerik ve görselleri yan yana veya alt alta yerleştiriyoruz
    return Column(
      children: [
        isMobile
            ? Column(
          children: [
            ContentText(text: text),
            SizedBox(height: 20),
            ImageCarousel(imagePaths: imagePaths),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: reverse
              ? [
            Expanded(child: ImageCarousel(imagePaths: imagePaths)),
            SizedBox(width: 40),
            Expanded(child: ContentText(text: text)),
          ]
              : [
            Expanded(child: ContentText(text: text)),
            SizedBox(width: 40),
            Expanded(child: ImageCarousel(imagePaths: imagePaths)),
          ],
        ),
      ],
    );
  }
}

class ContentText extends StatelessWidget {
  final String text;

  ContentText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        color: Color(0xFF393E46),
        height: 1.5,
      ),
      textAlign: TextAlign.justify,
    );
  }
}

class ImageCarousel extends StatelessWidget {
  final List<String> imagePaths;

  ImageCarousel({required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 16 / 9,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
      ),
      items: imagePaths.map<Widget>((photoUrl) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset(
            photoUrl,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      }).toList(),
    );
  }
}
