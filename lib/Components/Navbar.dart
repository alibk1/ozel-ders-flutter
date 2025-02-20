import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/Components/Drawer.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color _primaryColor = const Color(0xFFA7D8DB);
  final Color _backgroundColor = const Color(0xFFEEEEEE);
  final Color _darkColor = const Color(0xFF3C72C2);
  bool _isAppBarExpanded = true;

  bool isLoggedIn = false;
  bool isLoading = true;
  bool isCategoriesLoading = true;
  String? selectedCategoryId;
  String? selectedSubCategoryId;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      isLoggedIn = await AuthService().isUserSignedIn();
      await _loadCategories();
    } catch (e) {
      print('Initialization error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final result = await FirestoreService().getCategories();
      setState(() {
        categories = result;
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
          colors: [_backgroundColor, _primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(isMobile),
            SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: isMobile ? 5 : 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  const SizedBox(height: 30),

                  const SizedBox(height: 30),

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
      backgroundColor: Color(0xFFEEEEEE),
      title: isLoading ? const SizedBox.shrink() : isMobile ? Image.asset(
        'assets/AYBUKOM1.png',
        height: isMobile ? 50 : 70,
        key: const ValueKey('expanded-logo'),
      ).animate()
          .fadeIn(duration: 1000.ms)
          :
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isAppBarExpanded
            ? Image.asset(
          'assets/AYBUKOM1.png',
          height: isMobile ? 50 : 70,
          key: const ValueKey('expanded-logo'),
        ).animate()
            .fadeIn(duration: 1000.ms)
            : Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/AYBUKOM1.png',
            height: isMobile ? 40 : 50,
            key: const ValueKey('collapsed-logo'),
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
                colors: [Colors.white, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: const LinearGradient(
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
        const HeaderButton(title: 'Ana Sayfa', route: '/'),
        const HeaderButton(title: 'Danışmanlıklar', route: '/courses'),
        const HeaderButton(title: 'İçerikler', route: '/contents'),
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
          color: const Color(0xFF0344A3),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
