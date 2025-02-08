import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/AppointmentCard.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:ozel_ders/Components/Drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';

class AppointmentsPage extends StatefulWidget {
  final String uid;
  AppointmentsPage({required this.uid});

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirestoreService _firestore = FirestoreService();
  List<Map<String, dynamic>> userAppointments = [];
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;
  bool isLoggedIn = false;
  bool isTeacher = true;
  bool _isAppBarExpanded = true;

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    isLoggedIn = await AuthService().isUserSignedIn();
    if (isLoggedIn) {
      String currentUser = AuthService().userUID();
      if (currentUser == widget.uid) {
        userInfo = await FirestoreService().getTeacherByUID(widget.uid);
        if (userInfo.isNotEmpty) {
          isTeacher = true;
        } else {
          userInfo = await FirestoreService().getStudentByUID(widget.uid);
          isTeacher = false;
        }
        userAppointments =
        await FirestoreService().getUserAppointments(widget.uid, isTeacher);
        sortUserAppointments();
      } else {
        context.go('/');
      }
    } else {
      context.go('/');
    }
    isLoading = false;
    setState(() {});
  }

  void sortUserAppointments() {
    userAppointments.sort((a, b) {
      Timestamp dateA = a['date'] as Timestamp;
      Timestamp dateB = b['date'] as Timestamp;
      DateTime aD = dateA.toDate();
      DateTime bD = dateB.toDate();
      return aD.compareTo(bD);
    });
  }

  // Tasarım şemasına uygun renkler:
  final Color _primaryColor = Color(0xFFA7D8DB);
  final Color _backgroundColor = Color(0xFFEEEEEE);
  final Color _darkColor = Color(0xFF3C72C2);
  final Color _textColor = Color(0xFF222831);

  // HomePage'deki header tarzını referans alarak header kısmı
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
            "Randevular",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // İsteğe bağlı: kısa açıklama ekleyebilirsiniz
          SizedBox(height: 10),
          Text(
            "Tüm randevularınızı buradan takip edebilirsiniz.",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsGrid() {
    return GridView.builder(
      key: ValueKey('appointmentsGrid'),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width >= 800 ? 4 : 2,
        crossAxisSpacing: 30,
        mainAxisSpacing: 30,
        childAspectRatio: MediaQuery.of(context).size.width >= 800 ? 1.5 : 0.75,
      ),
      itemCount: userAppointments.length,
      itemBuilder: (context, index) {
        final appointment = userAppointments[index];
        // Sadece eğitmen ile öğrencinin farklı olduğu randevuları göster
        if (appointment["author"] != appointment["student"]) {
          return AppointmentCard(
            appointmentUID: appointment["UID"],
            isTeacher: isTeacher,
          );
        }
        return SizedBox.shrink();
      },
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
      actions: isMobile ? null : _buildDesktopMenu(),
      leading: isMobile
          ? IconButton(
        icon: Icon(Icons.menu, color: _darkColor),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      )
          : null,
    );
  }


  List<Widget> _buildDesktopMenu() {
    return [
      HeaderButton(title: 'Ana Sayfa', route: '/'),
      HeaderButton(title: 'Danışmanlıklar', route: '/courses'),
      HeaderButton(title: 'Blog', route: '/blogs'),
      if (isLoggedIn)
        HeaderButton(title: 'Randevularım', route: '/appointments/' + AuthService().userUID()),
      HeaderButton(
          title: isLoggedIn ? 'Profilim' : 'Giriş Yap',
          route: isLoggedIn ? '/profile/' + AuthService().userUID() : '/login'),
    ];
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


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? DrawerMenu(isLoggedIn: isLoggedIn) : null,
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Asıl sayfa içeriği
          Container(
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
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16.0 : screenWidth * 0.2,
                            vertical: 30,
                          ),
                          child: _buildAppointmentsGrid(),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(child: FooterSection()),
                ],
              ),
            ),
          ),

          // Loading overlay (HomePage’teki mantıkla)
          if (isLoading) _buildLoadingOverlay(),
        ],
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
          color: Color(0xFF0344A3),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
