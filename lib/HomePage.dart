import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/Components/ContactForm.dart';
import 'package:ozel_ders/Components/Drawer.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/FirebaseController.dart';
import 'package:ozel_ders/services/BBB.dart';

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
    // TODO: implement initState
    initData();
    super.initState();
  }

  Future<void> initData() async
  {
    isLoggedIn = await AuthService().isUserSignedIn();
    print(isLoggedIn);
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF183A37),
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
          icon: Icon(Icons.menu),
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
            child: Text('Ana Sayfa', style: TextStyle(
                color: Color(0xFFC44900), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories'); // CategoriesPage'e yönlendirme
            },
            child: Text('Kategoriler', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/courses'); // CategoriesPage'e yönlendirme
            },
            child: Text('Kurslar', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          isLoggedIn ? TextButton(
            onPressed: ()
            {
              context.go('/appointments/' + AuthService().userUID());

            },
            child: Text('Randevularım', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ) : SizedBox.shrink(),
          TextButton(
            onPressed: isLoggedIn ?
                () {
              context.go('/profile/' + AuthService().userUID());
            }
                :
                () {
              context.go('/login');
            },
            child: Text(isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]
            : null,
      ),
      drawer: MediaQuery
          .of(context)
          .size
          .width < 600
          ? DrawerMenu(isLoggedIn: isLoggedIn)
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
      backgroundColor: Color(0xFFEFD6AC),
    );
  }
}

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Color(0xFF183A37),
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
            'Biz, online rehabilitasyon ve terapi hizmetleri sunan, alanında uzman bir ekibiz. Amacımız, bireylerin fiziksel ve mental sağlıklarını iyileştirmek için güvenilir, etkili ve kişiselleştirilmiş çözümler sunmaktır. Tecrübeli terapistlerden oluşan kadromuz, her bireyin ihtiyaçlarına özel yaklaşımlar geliştirerek, onların yaşam kalitesini artırmayı hedeflemektedir. Modern teknolojiyi kullanarak, her yerden erişilebilir hizmetler sunuyor ve danışanlarımızın en iyi sonuçları elde etmeleri için sürekli olarak kendimizi geliştiriyoruz.',
            imagePaths: ["assets/mantalk.jpg", "assets/therapy.jpg"],
          ),
          SizedBox(height: 32),
          SectionTitle(title: 'Neler Sunuyoruz?'),
          SizedBox(height: 16),
          SectionContent(
            text:
            'Geniş yelpazede online rehabilitasyon ve terapi hizmetleri sunuyoruz. Fiziksel terapi, konuşma terapisi, psikolojik danışmanlık ve mesleki rehabilitasyon gibi farklı alanlarda uzmanlaşmış ekibimizle, her bireyin ihtiyacına uygun çözümler üretiyoruz. Ayrıca, bireysel ve grup seansları, özel programlar ve danışan takibi gibi hizmetlerle, danışanlarımızın tedavi sürecini destekliyoruz. Modern teknolojik altyapımız sayesinde, kullanıcı dostu ve erişilebilir bir hizmet deneyimi sunuyor, her yerden kolayca erişim imkanı sağlıyoruz',
            imagePaths: ["assets/therapy.jpg", "assets/mantalk.jpg"],
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
  final List<String> imagePaths;

  SectionContent({required this.text, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 3 * 2,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 20,),
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 23 / 9,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
          ),
          items: imagePaths.map<Widget>((photoUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Image.asset(
                  photoUrl,
                  fit: BoxFit.contain,
                  scale: 0.6,
                );
              },
            );
          }).toList() ??
              [],
        ),
      ],
    );
  }
}
