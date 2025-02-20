import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/LoadingIndicator.dart';
import 'package:ozel_ders/Components/TeacherCard.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:ozel_ders/Components/comment.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Components/Drawer.dart';
import 'Components/Navbar.dart';

class CoursePage extends StatefulWidget {
  final String uid;

  CoursePage({required this.uid});

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  bool isDescExpanded = true;
  bool isTeacherExpanded = false;
  bool isLoading = true; // Loading indicator için durum değişkeni
  bool isLoggedIn = false;
  final PageController _pageController = PageController();
  Map<String, dynamic> course = {};
  Map<String, dynamic> teacher = {};
  List<Map<String, dynamic>> teacherApps = [];
  List<Map<String, dynamic>> teacherCourses = [];
  List<dynamic> teacherAvailableHours = [];
  int _currentPage = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Color _primaryColor = const Color(0xFFA7D8DB);
  final Color _backgroundColor = const Color(0xFFEEEEEE);
  final Color _darkColor = const Color(0xFF3C72C2);
  final Color _headerTextColor = const Color(0xFF222831);
  final Color _bodyTextColor = const Color(0xFF393E46);

  bool _isAppBarExpanded = true;
  bool isCategoriesLoading = true;
  String? selectedCategoryId;
  String? selectedSubCategoryId;
  List<Map<String, dynamic>> categories = [];

  //APPOINTMENT WIDGET VARIABLES
  DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
  List<DateTime> selectedTimes = [];
  List<Map<String, String>> timeSlots = [];
  List<DateTime> teacherAppDates = [];
  List<DateTime> teacherAvailables = [];

  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    initMenu();
    super.initState();
  }

  Future<void> initMenu() async {
    isLoggedIn = await AuthService().isUserSignedIn();
    print(isLoggedIn);
    initData();
    setState(() {});
  }

  Future<void> initData() async {
    course = await FirestoreService().getCourseByUID(widget.uid);
    teacher = await FirestoreService().getTeacherByUID(course["author"]);
    teacherApps =
    await FirestoreService().getUserAppointments(course["author"], true);
    teacherAvailableHours = teacher["availableHours"];

    for (var app in teacherApps) {
      Timestamp date = app["date"];
      DateTime dateTime = date.toDate();
      teacherAppDates.add(dateTime);
    }

    for (Timestamp a in teacherAvailableHours) {
      teacherAvailables.add(a.toDate());
    }

    for (int hour = 8; hour < 20; hour++) {
      String startTime = '${hour.toString().padLeft(2, '0')}:00';
      String endTime = '${hour.toString().padLeft(2, '0')}:50';
      timeSlots.add({'start': startTime, 'end': endTime});
    }
    getTeacherCourses();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getTeacherCourses() async {
    teacherCourses = await FirestoreService().getCoursesByAuthors([teacher["UID"]]);
    setState(() {

    });
  }

  Widget _appointmentsWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF222831),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)),
        gradient: LinearGradient(
          colors:
          [
            Color(0xFF3C72C2),
            Color(0xFF3C72C2)], // Yeni gradyan renkleri
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

      ),

      padding: EdgeInsets.only(
        bottom: MediaQuery
            .of(context)
            .viewInsets
            .bottom + 16,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'Randevu Al',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Tarih Seçimi
            TableCalendar(
              locale: 'tr_TR',
              focusedDay: DateTime.now().add(const Duration(days: 2)),
              firstDay: DateTime.now().add(const Duration(days: 2)),
              lastDay:  DateTime.now().add(const Duration(days: 365)),
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) =>
                  isSameDay(selectedDate, day),
              availableCalendarFormats: {
                CalendarFormat.month: "Ay",
                CalendarFormat.twoWeeks: "2 Hafta",
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SizedBox(height: 16),
            // Saat Seçimi
            Text(
              'Saat Seç (En fazla 3 adet)',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeSlots.map((slot) {
                int slotStart = int.parse(slot["start"]!.split(":")[0]);
                DateTime slotDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  slotStart,
                  0,
                );

                bool canReserve = true;
                for (DateTime date in teacherAppDates) {
                  if (date.year == slotDateTime.year &&
                      date.month == slotDateTime.month &&
                      date.day == slotDateTime.day &&
                      date.hour == slotDateTime.hour) {
                    canReserve = false;
                    break;
                  }
                }
                if (!teacherAvailables.contains(slotDateTime)) {
                  canReserve = false;
                }

                bool isSelected = selectedTimes.any((dateTime) =>
                dateTime.year == slotDateTime.year &&
                    dateTime.month == slotDateTime.month &&
                    dateTime.day == slotDateTime.day &&
                    dateTime.hour == slotDateTime.hour);

                return GestureDetector(
                  onTap: canReserve
                      ? () {
                    if (!isSelected && selectedTimes.length < 3) {
                      setState(() {
                        selectedTimes.add(slotDateTime);
                      });
                    } else if (isSelected) {
                      setState(() {
                        selectedTimes.removeWhere((dateTime) =>
                        dateTime.year == slotDateTime.year &&
                            dateTime.month ==
                                slotDateTime.month &&
                            dateTime.day == slotDateTime.day &&
                            dateTime.hour == slotDateTime.hour);
                      });
                    }
                  }
                      : null,
                  child: Container(
                    width: 120,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xFF23994c)
                          : canReserve
                          ? Color(0xFF393E46)
                          : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${slot['start']} - ${slot['end']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            // Seçilen Randevuların Gösterimi
            selectedTimes.isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seçilen Randevular:',
                  style: TextStyle(
                      fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 8),
                Column(
                  children: selectedTimes.map((dateTime) {
                    String formatted =
                    DateFormat('dd/MM/yyyy - HH:mm')
                        .format(dateTime);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2.0),
                      child: Text(
                        formatted,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
              ],
            )
                : SizedBox(),
            // Randevu Al Butonu
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF23994c),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: selectedTimes.isNotEmpty
                  ? () async {
                LoadingIndicator(context).showLoading();
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  teacher = await FirestoreService()
                      .getTeacherByUID(course["author"]);

                  String appUID =
                  await FirestoreService().createAppointment(
                    course["author"],
                    user.uid,
                    course["UID"],
                    "",
                    selectedTimes, // Liste olarak gönderiyoruz
                  );
                  Map<String, dynamic> userMap =
                  await FirestoreService()
                      .getStudentByUID(user.uid);
                  await FirestoreService()
                      .sendAppointmentToTeacher(
                      appUID,
                      course["author"],
                      user.uid,
                      userMap["name"]);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Randevular başarıyla oluşturuldu')),
                  );
                } else {
                  context.go('/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Lütfen Giriş Yapınız.')),
                  );
                }

                Navigator.pop(context);
              }
                  : null,
              child: Text(
                'Randevu Al',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showFullDescriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          "Hakkında",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            course['desc'] ?? "",
            style: GoogleFonts.poppins(fontSize: 15, color: _bodyTextColor),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Kapat",
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    Widget content = InkWell(
      onTap: () => _showFullDescriptionDialog(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          course['desc'] == null
              ? ""
              : course['desc'].length > 400
              ? course['desc'].substring(0, 400) + "..."
              : course['desc'],
          style: GoogleFonts.poppins(fontSize: 15, color: _bodyTextColor),
        ),
      ),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          'Kurs Açıklaması',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _headerTextColor,
          ),
        ),
        /*trailing: isSelf
            ? IconButton(
          tooltip: "Açıklama'yı Düzenle",
          onPressed: () => _showChangeDescDialog(context),
          icon: const Icon(Icons.edit_note, color: Colors.black),
        )
            : null,
         */
        children: [content],
      ),
    );
  }

  Widget titleSection(){
    return Container(
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [_darkColor, _darkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            course['name'] ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                  aspectRatio: 22 / 9,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                ),
                items: (course['photos'] as List<dynamic>?)
                    ?.map<Widget>((photoUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Image.network(
                        photoUrl,
                        fit: BoxFit.fill,
                        scale: 0.6,
                      );
                    },
                  );
                }).toList() ??
                    [],
              ),
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    _carouselController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () {
                    _carouselController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 15,),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      drawer: MediaQuery
          .of(context)
          .size
          .width < 800
          ? DrawerMenu(isLoggedIn: isLoggedIn)
          : null,
      body: isLoading
          ? Stack(
        children: [
          _buildMainContent(isMobile),
          if (isLoading || isCategoriesLoading) _buildLoadingOverlay(),
        ],
      )
          : SafeArea(
        child: CustomScrollView(slivers: [
          _buildAppBar(isMobile),
          SliverPadding(
            padding: EdgeInsets.symmetric(
                vertical: isMobile ? 0 : 30, horizontal: isMobile ? 12 : 60),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 46.0, horizontal: 0),
                      child: MediaQuery
                          .of(context)
                          .size
                          .width >= 800
                          ? _buildDesktop()
                          : _buildMobile()
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildDesktop() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1500),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol kısım: Kurs başlığı, fotoğraflar ve açıklama
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kurs Başlığı ve Fotoğraflar (Carousel)
                    titleSection(),
                    const SizedBox(height: 16),
                    // Kurs Açıklaması
                    _buildAboutSection(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Sağ kısım: TeacherCard, appointmentsWidget ve yorumlar (CommentRatingWidget)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: TeacherCard(teacherData: teacher, teacherCourses: teacherCourses)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _appointmentsWidget(context),
                    const SizedBox(height: 16),
                    CommentRatingWidget(
                      courseId: course["UID"],
                      paddingInset: 16.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobile()
  {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        titleSection(),
        const SizedBox(height: 16),
        _appointmentsWidget(context),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildAboutSection()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TeacherCard(teacherData: teacher, teacherCourses: teacherCourses)),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            children: [
              Expanded(
                child: CommentRatingWidget(
                  courseId: course["UID"],
                  paddingInset: 8.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ThemeData _customDatePickerTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF23994c), // Seçili tarih & header
        surface: Color(0xFF222831), // Header arkaplan
        onSurface: Colors.white, // Metin renkleri
      ),
      dialogBackgroundColor: const Color(0xFF393E46), // Ana arkaplan
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.redAccent, // İptal butonu
        ),
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
              padding: EdgeInsets.symmetric(
                  vertical: 30, horizontal: isMobile ? 5 : 30),
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
      title: isLoading
          ? const SizedBox.shrink()
          : isMobile
          ? Image.asset(
        'assets/AYBUKOM1.png',
        height: isMobile ? 50 : 70,
        key: const ValueKey('expanded-logo'),
      ).animate().fadeIn(duration: 1000.ms)
          : AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isAppBarExpanded
            ? Image.asset(
          'assets/AYBUKOM1.png',
          height: isMobile ? 50 : 70,
          key: const ValueKey('expanded-logo'),
        ).animate().fadeIn(duration: 1000.ms)
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
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
