import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/Components/Drawer.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/Components/MenuBlogsWidget.dart';
import 'package:ozel_ders/Components/MenuCoursesWidget.dart';
import 'package:ozel_ders/Components/MenuTeachersWidget.dart';
import 'package:ozel_ders/Components/MenuYoutubeWidget.dart';
import 'package:ozel_ders/services/FirebaseController.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color _primaryColor = Color(0xFFA7D8DB);
  final Color _backgroundColor = Color(0xFFEEEEEE);
  final Color _darkColor = Color(0xFF3C72C2);
  bool _isAppBarExpanded = true;

  bool isLoggedIn = false;
  bool isLoading = true;
  bool isCategoriesLoading = true;
  String? selectedCategoryId;
  String? selectedSubCategoryId;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> topCourses = [];
  List<Map<String, dynamic>> topTeachers = [];
  List<Map<String, dynamic>> neededCourses = [];
  List<Map<String, dynamic>> neededTeachers = [];
  List<Map<String, dynamic>> youtubeVideos = [];
  List<Map<String, dynamic>> blogs = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      isLoggedIn = await AuthService().isUserSignedIn();
      await _loadData();
    } catch (e) {
      print('Initialization error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      categories = await FirestoreService().getCategories();
      youtubeVideos = await FirestoreService().getAllVideos();
      topCourses = await FirestoreService().getCoursesByPopularity(0, 5);
      topTeachers = await FirestoreService().getTeachersByPopularity(0, 5);
      blogs = await FirestoreService().getAllBlogs();
      List<String> neededTeacherList = [];
      for (var course in topCourses) {
        neededTeacherList.add(course["author"]);
      }
      for (var teacher in topTeachers) {
        neededTeacherList.add(teacher["uid"]);
      }

      neededTeachers =
          await FirestoreService().getSpesificTeachers(neededTeacherList);
      neededCourses =
          await FirestoreService().getCoursesByAuthors(neededTeacherList);

      /*print(neededCourses.length);
      for(var course in topCourses)
      {
        if(!neededCourses.contains(course)) neededCourses.add(course);
      }
      print(neededCourses.length);

      for(var teacher in topTeachers)
      {
        if(!neededTeachers.contains(teacher)) neededTeachers.add(teacher);
      }
       */

      setState(() {
        isCategoriesLoading = false;
      });
    } catch (e) {
      print('Category load error: $e');
      setState(() => isCategoriesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      drawer: isMobile ? DrawerMenu(isLoggedIn: isLoggedIn) : null,
      body: Stack(
        children: [
          _buildMainContent(isMobile),
          if (isLoading || isCategoriesLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_backgroundColor, _primaryColor.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(isMobile),
            SliverToBoxAdapter(child: _buildHeroSection()),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                  vertical: 30, horizontal: isMobile ? 5 : 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  IntroductionSection(),
                  SizedBox(height: 30),
                  TopCoursesWidget(
                    onSeeAllPressed: () {
                      context.go("/courses");
                    },
                    courses: topCourses,
                    teachers: neededTeachers,
                  ),
                  SizedBox(height: 30),
                  TopTeachersWidget(
                    onSeeAllPressed: () {
                      context.go("/courses");
                    },
                    topTeachers: topTeachers,
                    courses: neededCourses,
                  ),
                  SizedBox(height: 30),
                  TopYoutubeVideosWidget(
                    onSeeAllPressed: () {
                      context.go("/courses");
                    },
                    youtubeVideos: youtubeVideos,
                  ),
                  SizedBox(height: 30),
                  TopBlogsWidget(
                      onSeeAllPressed: (){

                      },
                      blogs: blogs
                  ),
                  SizedBox(height: 30),
                ]),
              ),
            ),
            // FooterSection widget'ı padding olmadan ekleniyor
            SliverToBoxAdapter(child: FooterSection()),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isMobile) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      title: isLoading
          ? SizedBox.shrink()
          : isMobile
              ? Image.asset(
                  'assets/vitament1.png',
                  height: isMobile ? 50 : 70,
                  key: ValueKey('expanded-logo'),
                ).animate().fadeIn(duration: 1000.ms)
              : AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: _isAppBarExpanded
                      ? Image.asset(
                          'assets/vitament1.png',
                          height: isMobile ? 50 : 70,
                          key: ValueKey('expanded-logo'),
                        ).animate().fadeIn(duration: 1000.ms)
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/vitament1.png',
                            height: isMobile ? 40 : 50,
                            key: ValueKey('collapsed-logo'),
                          ),
                        ),
                ),
      centerTitle: isMobile || _isAppBarExpanded,
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final isExpanded = constraints.maxHeight > kToolbarHeight;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_isAppBarExpanded != isExpanded) {
              setState(() {
                _isAppBarExpanded = isExpanded;
              });
            }
          });
          return FlexibleSpaceBar(
            background: GlassmorphicContainer(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 0,
              blur: 30,
              border: 0,
              linearGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05)
                ],
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

  Widget _buildDesktopMenu() {
    return Row(
      children: [
        HeaderButton(title: 'Ana Sayfa', route: '/'),
        HeaderButton(title: 'Danışmanlıklar', route: '/courses'),
        HeaderButton(title: 'İçerikler', route: '/contents'),
        if (isLoggedIn)
          HeaderButton(
            title: 'Randevularım',
            route: '/appointments/${AuthService().userUID()}',
          ),
        HeaderButton(
          title: isLoggedIn ? 'Profilim' : 'Giriş Yap',
          route: isLoggedIn ? '/profile/${AuthService().userUID()}' : '/login',
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        gradient: LinearGradient(
          colors: [_primaryColor, _darkColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sağlığınız İçin Uzman Eller',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            SizedBox(height: 20),
            Text(
              'Lisanslı danışmanlarla online çözümler',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),
            _buildSearchCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return GlassmorphicContainer(
      width: 800,
      height: 230,
      borderRadius: 20,
      blur: 20,
      border: 2,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
      ),
      borderGradient: LinearGradient(colors: [Colors.white24, Colors.white12]),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildCategoryDropdown(),
            SizedBox(height: 15),
            _buildSubCategoryDropdown(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleSearch(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Ara', style: GoogleFonts.poppins(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategoryId,
      decoration: _inputDecoration('Kategori Seçin'),
      items: categories.map<DropdownMenuItem<String>>((category) {
        return DropdownMenuItem<String>(
          value: category['uid'] as String, // Explicit type casting
          child: Text(
            category['name'] as String,
            style: GoogleFonts.poppins(color: _darkColor),
          ),
        );
      }).toList(),
      onChanged: (String? value) => setState(() {
        selectedCategoryId = value;
        selectedSubCategoryId = null;
      }),
      dropdownColor: _backgroundColor,
      icon: Icon(Icons.arrow_drop_down, color: _darkColor),
    );
  }

  Widget _buildSubCategoryDropdown() {
    final category = categories.firstWhere(
      (c) => c['uid'] == selectedCategoryId,
      orElse: () => <String, dynamic>{},
    );

    final subCategories = (category['subCategories'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return DropdownButtonFormField<String>(
      value: selectedSubCategoryId,
      decoration: _inputDecoration('Alt Kategori Seçin (Opsiyonel)'),
      items: subCategories.map<DropdownMenuItem<String>>((subCat) {
        return DropdownMenuItem<String>(
          value: subCat['uid'] as String, // Explicit type casting
          child: Text(
            subCat['name'] as String,
            style: GoogleFonts.poppins(color: _darkColor),
          ),
        );
      }).toList(),
      onChanged: (String? value) =>
          setState(() => selectedSubCategoryId = value),
      dropdownColor: _backgroundColor,
      icon: Icon(Icons.arrow_drop_down, color: _darkColor),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: _darkColor.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: SpinKitFadingCircle(
          color: _primaryColor,
          size: 50,
        ),
      ),
    );
  }

  void _handleSearch() {
     String category = selectedCategoryId ?? "";
     String subCategory = selectedSubCategoryId ?? "";
     if(category == "")
     {
       context.go('/courses');
     }
    else if(subCategory == ""){
       context.go('/courses/' + category);
    }
    else{
       context.go('/courses/' + category + "/" + subCategory);
     }
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

// Diğer widget'larınız (TopCoursesWidget, IntroductionSection vb.) buraya gelecek

class HeaderMenu extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;

  const HeaderMenu({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 60,
      borderRadius: 0,
      blur: 30,
      alignment: Alignment.center,
      border: 0,
      linearGradient: LinearGradient(
        colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [Colors.blue.withOpacity(0.2), Colors.blue.withOpacity(0.1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HeaderMenuItem(title: 'Ana Sayfa', route: '/'),
          HeaderMenuItem(title: 'Danışmanlıklar', route: '/courses'),
          HeaderMenuItem(title: 'Blog', route: '/blogs'),
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
  Size get preferredSize => Size.fromHeight(60);
}

class HeaderMenuItem extends StatefulWidget {
  final String title;
  final String route;

  const HeaderMenuItem({required this.title, required this.route});

  @override
  _HeaderMenuItemState createState() => _HeaderMenuItemState();
}

class _HeaderMenuItemState extends State<HeaderMenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isHovered
              ? Color(0xFF76ABAE).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.title,
          style: TextStyle(
            color: isHovered ? Color(0xFF76ABAE) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}

class IntroductionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // İlk Bölüm: Başlık ve yazı solda, resimler ve ikonlar sağda

          SectionContent(
            title: 'Biz Kimiz?',
            text:
                //'Biz, online rehabilitasyon ve terapi hizmetleri sunan, alanında uzman bir ekibiz. Amacımız, bireylerin fiziksel ve mental sağlıklarını iyileştirmek için güvenilir, etkili ve kişiselleştirilmiş çözümler sunmaktır. Tecrübeli terapistlerden oluşan kadromuz, her bireyin ihtiyaçlarına özel yaklaşımlar geliştirerek, onların yaşam kalitesini artırmayı hedeflemektedir. Modern teknolojiyi kullanarak, her yerden erişilebilir hizmetler sunuyor ve danışanlarımızın en iyi sonuçları elde etmeleri için sürekli olarak kendimizi geliştiriyoruz.',
                'Biz, online rehabilitasyon ve terapi hizmetleri sunan, alanında uzman bir ekibiz. Amacımız, bireylerin fiziksel ve mental sağlıklarını iyileştirmek için güvenilir, etkili ve kişiselleştirilmiş çözümler sunmaktır.',
            imagePaths: ["assets/mantalk.jpg", "assets/therapy.jpg"],
            reverse: false,
          ),
          SizedBox(height: 32),
          // İkinci Bölüm: Başlık ve yazı sağda, resimler ve ikonlar solda
          SectionContent(
            title: 'Neler Sunuyoruz?',
            text:
                //'Geniş yelpazede online rehabilitasyon ve terapi hizmetleri sunuyoruz. Fiziksel terapi, konuşma terapisi, psikolojik danışmanlık ve mesleki rehabilitasyon gibi farklı alanlarda uzmanlaşmış ekibimizle, her bireyin ihtiyacına uygun çözümler üretiyoruz. Ayrıca, bireysel ve grup seansları, özel programlar ve danışan takibi gibi hizmetlerle, danışanlarımızın tedavi sürecini destekliyoruz. Modern teknolojik altyapımız sayesinde, kullanıcı dostu ve erişilebilir bir hizmet deneyimi sunuyor, her yerden kolayca erişim imkanı sağlıyoruz.',
                'Geniş yelpazede online rehabilitasyon ve terapi hizmetleri sunuyoruz. Fiziksel terapi, konuşma terapisi, psikolojik danışmanlık ve mesleki rehabilitasyon gibi farklı alanlarda uzmanlaşmış ekibimizle, her bireyin ihtiyacına uygun çözümler üretiyoruz.',
            imagePaths: ["assets/therapy.jpg", "assets/mantalk.jpg"],
            reverse: true,
          ),


          SizedBox(height: 32),
          //ContactForm(),
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
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF222831),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class SectionContent extends StatelessWidget {
  final String title;
  final String text;
  final List<String> imagePaths;
  final bool reverse;

  SectionContent({
    required this.title,
    required this.text,
    required this.imagePaths,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      margin:
          EdgeInsets.symmetric(vertical: 16, horizontal: isMobile ? 20 : 100),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SectionTitle(title: title),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                    padding: EdgeInsets.all(8), child: ContentText(text: text)),
                SizedBox(height: 20),
                ImageCarousel(imagePaths: imagePaths),
                SizedBox(height: 20),
                FeatureGrid(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reverse
                  ? [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SectionTitle(title: title),
                              ],
                            ),
                            SizedBox(height: 16),
                            Container(
                                padding: EdgeInsets.all(8),
                                child: ContentText(text: text)),
                            SizedBox(height: 20),
                            FeatureGrid(),
                          ],
                        ),
                      ),
                      SizedBox(width: 40),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            ImageCarousel(imagePaths: imagePaths),
                          ],
                        ),
                      ),
                    ]
                  : [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageCarousel(imagePaths: imagePaths),
                          ],
                        ),
                      ),
                      SizedBox(width: 40),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SectionTitle(title: title),
                              ],
                            ),
                            SizedBox(height: 16),
                            Container(
                                padding: EdgeInsets.all(8),
                                child: ContentText(text: text)),
                            SizedBox(height: 20),
                            FeatureGrid(),
                          ],
                        ),
                      ),
                    ],
            ),
    );
  }
}

class FeatureGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;
    if (!isMobile) {
      return GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
        children: [
          FeatureCard(
            icon: FontAwesomeIcons.userMd,
            title: 'Uzman\nDanışmanlar',
            description: 'Alanında uzman danışmanlarımızla hizmetinizdeyiz.',
          ),
          FeatureCard(
            icon: FontAwesomeIcons.stethoscope,
            title: 'Kişiselleştirilmiş Çözümler',
            description: 'Her bireyin ihtiyacına özel çözümler sunuyoruz.',
          ),
          FeatureCard(
            icon: FontAwesomeIcons.calendarCheck,
            title: 'Esnek Randevu Sistemi',
            description: 'Size uygun zamanlarda randevu alabilirsiniz.',
          ),
          FeatureCard(
            icon: FontAwesomeIcons.video,
            title: 'Online\nTerapi',
            description: 'Her yerden erişilebilir online terapi hizmeti.',
          ),
        ],
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          FeatureCard(
            icon: FontAwesomeIcons.userMd,
            title: 'Uzman\nDanışmanlar',
            description: 'Alanında uzman danışmanlarımızla hizmetinizdeyiz.',
          ),
          FeatureCard(
            icon: FontAwesomeIcons.stethoscope,
            title: 'Kişiselleştirilmiş Çözümler',
            description: 'Her bireyin ihtiyacına özel çözümler sunuyoruz.',
          ),
          FeatureCard(
            icon: FontAwesomeIcons.calendarCheck,
            title: 'Esnek Randevu Sistemi',
            description: 'Size uygun zamanlarda randevu alabilirsiniz.',
          ),
          FeatureCard(
            icon: FontAwesomeIcons.video,
            title: 'Online\nTerapi',
            description: 'Her yerden erişilebilir online terapi hizmeti.',
          ),
        ],
      );
    }
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: 200,
      height: 160,
      borderRadius: 20,
      blur: 80,
      alignment: Alignment.center,
      border: 0,
      linearGradient: LinearGradient(
        colors: [
          Color(0xFF76ABAE).withOpacity(0.1),
          Color(0xFF4CAF50).withOpacity(0.1)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [Color(0xFF76ABAE), Color(0xFF4CAF50)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30,
            color: Color(0xFF76ABAE),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222831),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF393E46),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
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
        height: 1.6,
      ),
      textAlign: TextAlign.justify,
    );
  }
}

class ImageCarousel extends StatelessWidget {
  final List<String> imagePaths;

  const ImageCarousel({required this.imagePaths, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemBuilder: (BuildContext context, int index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Image.asset(
            imagePaths[index],
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      },
      itemCount: imagePaths.length,
      autoplay: true,
      viewportFraction: 0.8,
      scale: 0.9,
      pagination: SwiperPagination(),
      itemHeight: 400,
      itemWidth: 600,
      layout: SwiperLayout.STACK,
    );
  }
}
