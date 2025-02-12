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
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:ozel_ders/Components/comment.dart';
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
  List<dynamic> teacherAvailableHours = [];
  int _currentPage = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Color _primaryColor = const Color(0xFFA7D8DB);
  final Color _backgroundColor = const Color(0xFFEEEEEE);
  final Color _darkColor = const Color(0xFF3C72C2);
  bool _isAppBarExpanded = true;
  bool isCategoriesLoading = true;
  String? selectedCategoryId;
  String? selectedSubCategoryId;
  List<Map<String, dynamic>> categories = [];

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
    setState(() {
      isLoading = false; // Yüklenme işlemi tamamlandığında false yapıyoruz
    });
  }

  void _showDateTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
        List<DateTime> selectedTimes = [];
        List<Map<String, String>> timeSlots = [];
        List<DateTime> teacherAppDates = [];
        List<DateTime> teacherAvailables = [];

        for (var app in teacherApps) {
          Timestamp date = app["date"];
          DateTime dateTime = date.toDate();
          teacherAppDates.add(dateTime);
        }

        for (Timestamp a in teacherAvailableHours) {
          teacherAvailables.add(a.toDate());
        }

        // 08:00'dan 20:00'e kadar 50 dakikalık süreler oluştur
        for (int hour = 8; hour < 20; hour++) {
          String startTime = '${hour.toString().padLeft(2, '0')}:00';
          String endTime = '${hour.toString().padLeft(2, '0')}:50';
          timeSlots.add({'start': startTime, 'end': endTime});
        }

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Color(0xFF222831),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                gradient:  LinearGradient(
                  colors:
                  [
                    Color(0xFF3C72C2),
                    Color(0xFFA7D8DB)], // Yeni gradyan renkleri
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
                    Text(
                      'Tarih Seç',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF23994c),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate:
                          DateTime.now().add(const Duration(days: 2)),
                          // minTime → 2 gün sonrası
                          lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                          // maxTime → 365 gün sonrası
                          locale: const Locale('tr', 'TR'),
                          // Türkçe takvim
                          builder: (context, child) =>
                              Theme(
                                data: _customDatePickerTheme(),
                                child: child!,
                              ),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate =
                                picked; // Saat bilgisi korunuyor (8AM isterseniz DateTime(picked.year, picked.month, picked.day, 8) yapın)
                          });
                        }
                      },
                      child: Text(
                        'Tarih Seç (${DateFormat('dd/MM/yyyy').format(
                            selectedDate)})',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                              setModalState(() {
                                selectedTimes.add(slotDateTime);
                              });
                            } else if (isSelected) {
                              setModalState(() {
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
                            course["uid"],
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
          },
        );
      },
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
          ? Center(
          child: LoadingAnimationWidget.dotsTriangle(
              color: const Color(0xFF222831), size: 200))
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
            Container(
            padding: const EdgeInsets.all(2.0),
            // round the corners also add linear gradient
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
                colors: [_darkColor, _primaryColor],
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
                Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .width >= 800
                      ? MediaQuery
                      .of(context)
                      .size
                      .height * 2 / 4
                      : MediaQuery
                      .of(context)
                      .size
                      .height * 1 / 4,
                  child: Stack(
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
                        items: course['photos']?.map<Widget>((photoUrl) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Image.network(
                                photoUrl,
                                fit: BoxFit.fill,
                                scale: 0.6,
                              );
                            },
                          );
                        }).toList() ?? [],
                      ),
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            _carouselController.previousPage(
                              duration: Duration(milliseconds: 300),
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
                          icon: Icon(Icons.arrow_forward, color: Colors.white),
                          onPressed: () {
                            _carouselController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 46.0, horizontal: 0),
            child: MediaQuery
                .of(context)
                .size
                .width >= 800
                ? Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // Left side
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [
                          _darkColor,
                          _primaryColor
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                'Kurs Açıklaması',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight:
                                    FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(
                              thickness: 2,
                              color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            course['desc'] ?? '',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Right side
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                Colors.blueGrey,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(20.0),
                                ),
                              ),
                              onPressed: () {
                                if (isLoggedIn)
                                  _showDateTimePicker(
                                      context);
                                else
                                  context.go('/login');
                              },
                              child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                                  children: [
                                    const Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                      size: 29.0,
                                    ),
                                    const SizedBox(
                                        width: 8),
                                    Text(
                                      '\n Bu Kursu Satın Al : ${course['hourlyPrice']} TL \n',
                                      style: const TextStyle(
                                          color: Colors
                                              .white,
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                          fontSize: 24),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              color:
                              const Color(0xFF50727B),
                              child: Padding(
                                padding:
                                const EdgeInsets.all(
                                    16.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .center,
                                  children: [
                                    CircleAvatar(
                                      foregroundColor:
                                      Colors.white,
                                      radius: 60,
                                      backgroundImage:
                                      NetworkImage(
                                          teacher['profilePictureUrl'] ??
                                              ''),
                                    ),
                                    const SizedBox(
                                        height: 16),
                                    TextButton(
                                      child: Text(
                                        teacher['name'] ??
                                            '',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight
                                                .bold,
                                            color: Colors
                                                .white),
                                      ),
                                      onPressed: () {
                                        context.go(
                                            "/profile/" +
                                                teacher[
                                                "uid"]);
                                      },
                                    ),
                                    const SizedBox(
                                        height: 4),
                                    Text(
                                      teacher['fieldOfStudy'] ??
                                          '',
                                      style:
                                      const TextStyle(
                                          fontSize:
                                          12,
                                          color: Colors
                                              .white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CommentRatingWidget(
                              courseId: course["uid"],
                              paddingInset: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
                : Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
            ElevatedButton(

            style: ElevatedButton.styleFrom(
              shadowColor: Colors.black,
            backgroundColor:
                _darkColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  20.0), // İstediğiniz kenar yuvarlama miktarını belirleyebilirsiniz
              // Diğer shape özelliklerini de belirleyebilirsiniz
            ),
          ),
          onPressed: () {
            _showDateTimePicker(context);
          },
          child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .center,
              children: [
                const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 29.0,
                ),
                const SizedBox(
                    width: 8),
                Text(
                  '\n Bu Kursu Satın Al : ${course['hourlyPrice']} TL \n',
                  style: const TextStyle(
                      color: Colors
                          .white,
                      fontWeight:
                      FontWeight
                          .bold,
                      fontSize: 18),

                ),
              ]),
          ),

    const SizedBox(height: 16),
    Card(
    color: _darkColor,
    child: ExpansionTile(
    initiallyExpanded: true,
    title: const Text(
    'Kurs Açıklaması',
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white),
    ),
    children: [
    Padding(
    padding:
    const EdgeInsets.all(16.0),
    child: Text(
    course['desc'] ?? '',
    style: const TextStyle(
    color: Colors.white),
    ),
    ),
    ],
    ),
    ),
    const SizedBox(height: 16),
    Card(
    color: const Color(0xFF50727B),
    child: ExpansionTile(
    initiallyExpanded: false,
    title: const Text(
    'Öğretmen Bilgileri',
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white),
    ),
    children: [
    Padding(
    padding:
    const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment:
    CrossAxisAlignment.center,
    children: [
    CircleAvatar(
    radius: 50,
    backgroundImage:
    NetworkImage(teacher[
    'profilePictureUrl'] ??
    ''),
    ),
    const SizedBox(height: 16),
    Text(
    teacher['name'] ?? '',
    style: const TextStyle(
    fontSize: 18,
    fontWeight:
    FontWeight.bold,
    color: Colors.white),
    ),
    const SizedBox(height: 8),
    Text(
    teacher['fieldOfStudy'] ??
    '',
    style: const TextStyle(
    color: Colors.white),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    const SizedBox(height: 16),
    Padding(
    padding: const EdgeInsets.all(0.0),
    child: Row(
    children: [
    Expanded(
    child: CommentRatingWidget(
    courseId: course["uid"],
    paddingInset: 8.0,
    ),
    ),
    ],
    ),
    ),
    ],
    ),
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
      backgroundColor: Colors.transparent,
      title: isLoading
          ? const SizedBox.shrink()
          : isMobile
          ? Image.asset(
        'assets/vitament1.png',
        height: isMobile ? 50 : 70,
        key: const ValueKey('expanded-logo'),
      ).animate().fadeIn(duration: 1000.ms)
          : AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isAppBarExpanded
            ? Image.asset(
          'assets/vitament1.png',
          height: isMobile ? 50 : 70,
          key: const ValueKey('expanded-logo'),
        ).animate().fadeIn(duration: 1000.ms)
            : Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/vitament1.png',
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
        const HeaderButton(title: 'Blog', route: '/blogs'),
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
