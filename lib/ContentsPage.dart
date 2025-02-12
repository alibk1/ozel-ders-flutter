import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/Components/Drawer.dart';
import 'package:ozel_ders/Components/MenuBlogsWidget.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Components/MenuYoutubeWidget.dart';

final Color _primaryColor = Color(0xFFA7D8DB);
final Color _backgroundColor = Color(0xFFEEEEEE);
final Color _darkColor = Color(0xFF3C72C2);

class ContentsPage extends StatefulWidget {
  @override
  _ContentsPageState createState() => _ContentsPageState();
}

class _ContentsPageState extends State<ContentsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isAppBarExpanded = true;

  FirestoreService _firestore = FirestoreService();
  List<Map<String, dynamic>> blogsHolder = [];
  List<Map<String, dynamic>> videosHolder = [];

  bool isLoading = true;
  bool isLoggedIn = false;

  String searchText = '';
  String sortBy = 'date_desc';
  int currentPage = 1;
  final int blogsPerPage = 10;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    isLoggedIn = await AuthService().isUserSignedIn();
    await loadInitialData();
    setState(() {});
  }

  Future<void> loadInitialData() async {
    blogsHolder = await _firestore.getAllBlogs20Times();
    videosHolder = await _firestore.getAllVideos();
    isLoading = false;
    setState(() {

    });
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _darkColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "İçerikler",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Bilgilendirici İçerikler Burada...",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
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
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    double screenWidth = MediaQuery.of(context).size.width;
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
            SliverToBoxAdapter(child: _buildHeaderSection()),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : screenWidth * 0.08,
                vertical: 20,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  TopYoutubeVideosWidget(
                    onSeeAllPressed: () {
                      context.go("/videos");
                    },
                    youtubeVideos: videosHolder,

                  ),
                  SizedBox(height: 30),
                  TopBlogsWidget(
                      onSeeAllPressed: (){
                        context.go("/blogs");
                      },
                      blogs: blogsHolder
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isMobile) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      title: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _isAppBarExpanded
            ? Image.asset(
          'assets/vitament1.png',
          height: isMobile ? 50 : 70,
          key: ValueKey('expanded-logo'),
        ).animate().fadeIn(duration: 500.ms)
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

  Widget _buildDesktopMenu() {
    return Row(
      children: [
        _HeaderButton(title: 'Ana Sayfa', route: '/'),
        _HeaderButton(title: 'Danışmanlıklar', route: '/courses'),
        _HeaderButton(title: 'Blog', route: '/blogs'),
        if (isLoggedIn)
          _HeaderButton(
            title: 'Randevularım',
            route: '/appointments/${AuthService().userUID()}',
          ),
        _HeaderButton(
          title: isLoggedIn ? 'Profilim' : 'Giriş Yap',
          route: isLoggedIn ? '/profile/${AuthService().userUID()}' : '/login',
        ),
      ],
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
}

class _HeaderButton extends StatelessWidget {
  final String title;
  final String route;

  const _HeaderButton({required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go(route),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFF0344A3),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}