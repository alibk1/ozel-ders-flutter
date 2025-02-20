import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as dt_picker;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders/Components/AppointmentCard.dart';
import 'package:ozel_ders/Components/CourseCard.dart';
import 'package:ozel_ders/Components/MenuCoursesWidget.dart';
import 'package:ozel_ders/Components/NotificationIconButton.dart';
import 'package:ozel_ders/Components/BlogCard.dart';
import 'package:ozel_ders/Components/Drawer.dart';
import 'package:ozel_ders/Components/TeacherCard.dart';
import 'package:ozel_ders/HomePage.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Components/LoadingIndicator.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  ProfilePage({required this.uid});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Renk teması – HomePage ve CoursesPage’de kullandığınız renkler:
  final Color _primaryColor = const Color(0xFFA7D8DB);
  final Color _backgroundColor = const Color(0xFFEEEEEE);
  final Color _darkColor = const Color(0xFF3C72C2);
  final Color _headerTextColor = const Color(0xFF222831);
  final Color _bodyTextColor = const Color(0xFF393E46);

  bool isTeacher = false;
  bool isTeam = false;
  bool isLoading = true;
  bool isCategoriesLoading = true;
  Map<String, dynamic> userInfo = {};
  bool isLoggedIn = false;
  bool isSelf = false;
  bool isCurrentTeam = false;
  bool _isAppBarExpanded = true;
  bool _isCoursesExpanded = false;
  bool _isTeachersExpanded = false;
  List<dynamic> teacherAvailableHours = [];

  String teamUidIfCurrent = "";
  String teamNameIfCurrent = "";
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> blogs = [];
  List<Map<String, dynamic>> coursesNeeded = [];
  List<Map<String, dynamic>> teachersNeeded = [];

  //APPOINTMENT WIDGET FOR STUDENT VARIABLES
  DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
  List<DateTime> selectedTimes = [];
  List<Map<String, String>> timeSlots = [];
  List<DateTime> teacherAppDates = [];
  List<DateTime> teacherAvailables = [];
  Map<String, dynamic> course = {};

  //APPOINTMENT WIDGET VARIABLES
  List<DateTime> availableHours = [];
  Map<DateTime, List<Map<String, dynamic>>> eventsMap = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool selectedAvailable = false;
  DateTime? _selectedTime;

  Map<String, dynamic> courseCreationSelectedTeacher = {};


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      setState(() {
        isTeacher = false;
        isTeam = false;
        isLoading = true;
        userInfo = {};
        isLoggedIn = false;
        isSelf = false;
        isCurrentTeam = false;
        categories = [];
        selectedDate = DateTime.now().add(const Duration(days: 2));
        selectedTimes = [];
        timeSlots = [];
        teacherAppDates = [];
        teacherAvailables = [];
        course = {};
        _isCoursesExpanded = false;
        teacherAvailableHours = [];
        teamUidIfCurrent = "";
        teamNameIfCurrent = "";
        notifications = [];
        appointments = [];
        blogs = [];
        coursesNeeded = [];
        teachersNeeded = [];
        availableHours = [];
        eventsMap = {};
        _focusedDay = DateTime.now();
        _selectedDay;
        selectedAvailable = false;
        _selectedTime;
      });
      initData();
    }
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    isLoggedIn = await AuthService().isUserSignedIn();
    Map<String, dynamic> teamCheck = {};
    if (isLoggedIn) {
      String currentUID = AuthService().userUID();
      teamCheck = await FirestoreService().getTeamByUID(currentUID);
      if (teamCheck.isNotEmpty) {
        isCurrentTeam = true;
        teamUidIfCurrent = teamCheck["UID"];
        teamNameIfCurrent = teamCheck["name"];
      }
      if (widget.uid == AuthService().userUID()) {
        isSelf = true;
      }
    }

    userInfo = await FirestoreService().getTeacherByUID(widget.uid);
    List<String> neededTeacherUIDs = [];
    if (userInfo.isNotEmpty) {
      isTeacher = true;
      notifications = await FirestoreService().getNotificationsForTeacher(widget.uid);
      blogs = await FirestoreService().getTeacherBlogs(widget.uid);
      neededTeacherUIDs.add(widget.uid);
      teacherAvailableHours = userInfo["availableHours"];
      coursesNeeded = await FirestoreService().getCoursesByAuthors([widget.uid]);
    } else {
      userInfo = await FirestoreService().getStudentByUID(widget.uid);
      if (userInfo.isNotEmpty) {
        userInfo = await FirestoreService().getStudentByUID(widget.uid);
        List<dynamic> courses = userInfo["courses"];
        coursesNeeded = await FirestoreService().getSpesificCourses(courses);
        for (var course in coursesNeeded) {
          if (!neededTeacherUIDs.contains(course["author"]))
            neededTeacherUIDs.add(course["author"]);
        }
        notifications =
        await FirestoreService().getNotificationsForStudent(widget.uid);
        isTeacher = false;
      }
      else{
        if(teamCheck["UID"] == widget.uid) userInfo = teamCheck;
        else userInfo = await FirestoreService().getTeamByUID(widget.uid);
        List<dynamic> teacherUIDs = userInfo["teachers"];
        for(String uid in teacherUIDs)
        {
          neededTeacherUIDs.add(uid);
        }
        coursesNeeded = await FirestoreService().getCoursesByAuthors(neededTeacherUIDs);
        isTeacher = false;
        isTeam = true;
      }
    }

    teachersNeeded = await FirestoreService().getSpesificTeachers(neededTeacherUIDs);

    appointments = await FirestoreService().getUserAppointments(widget.uid, isTeacher);
    categories = await FirestoreService().getCategories();

    if (isSelf && !isTeacher && !isTeam && userInfo["hasPersonalCheck"] == false) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        btnOkText: "Tamam",
        title: 'Bireysel Değerlendirme',
        desc:
        'Başka Terapi Almadan Önce "Bireysel Değerlendirme" Terapisi Almanız Gerekmektedir. Danışmanlıklar Sayfasından Bireysel Değerlendirme Terapisi Alabilirsiniz.',
        btnOkOnPress: () {},
      ).show();
    }

    if(isTeacher)
    {
      for (var app in appointments) {
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
    }
    if(isTeacher && isSelf){
      for(Timestamp a in userInfo["availableHours"])
      {
        availableHours.add(a.toDate());
      }
      for (var app in appointments) {
        Timestamp date = app["date"];
        DateTime dateTime = date.toDate().toUtc();
        print(dateTime);
        teacherAppDates.add(dateTime);
      }

      for (var appointment in appointments) {
        final dateTime = (appointment['date'] as Timestamp).toDate();
        final dayOnly = DateTime(
            dateTime.year, dateTime.month, dateTime.day);

        if (!eventsMap.containsKey(dayOnly)) {
          eventsMap[dayOnly] = [];
        }
        eventsMap[dayOnly]!.add(appointment);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      // AppBar’da HomePage ve CoursesPage’deki gibi sade, şeffaf arka plan ve logo animasyonu
      drawer: isMobile ? DrawerMenu(isLoggedIn: isLoggedIn) : null,
      body: isLoading
          ? Stack(
        children: [
          _buildMainContent(isMobile),
          if (isLoading || isCategoriesLoading) _buildLoadingOverlay(),
        ],
      )
          : SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(isMobile),
            SliverToBoxAdapter(
              child: isMobile
                  ? _buildMobileProfile()
                  : _buildDesktopProfile(),
            ),
          ],
        ),
      ),
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

  SliverAppBar _buildSliverAppBar(bool isMobile) {
    return SliverAppBar(
      backgroundColor: Color(0xFFEEEEEE),
      pinned: true,
      expandedHeight: 120,
      centerTitle: isMobile || _isAppBarExpanded,
      leading: isMobile
          ? IconButton(
        icon: Icon(Icons.menu, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState!.openDrawer(),
      )
          : null,
      title: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _isAppBarExpanded
            ? Image.asset(
          'assets/AYBUKOM1.png',
          height: isMobile ? 50 : 70,
          key: ValueKey('expanded-logo'),
        ).animate().fadeIn(duration: 500.ms)
            : Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/AYBUKOM1.png',
            height: isMobile ? 40 : 50,
            key: ValueKey('collapsed-logo'),
          ),
        ),
      ),
      actions: isMobile ? null : [_buildDesktopMenuActions()],
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
                    _backgroundColor,
                    _primaryColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopMenuActions() {
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

  // ************************ Mobil Versiyon ************************
  Widget _buildMobileProfile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 16),
          if(isTeacher && isSelf) appointmentsWidget(context),
          if(isTeacher && !isSelf && !isCurrentTeam) appointmentWidgetForStudents(context),
          const SizedBox(height: 16),
          _buildAboutSection(),
          const SizedBox(height: 16),
          if(!isTeam && !isTeacher) buildSelectedCategoriesChips(),
          const SizedBox(height: 16),
          _buildCoursesSection(isMobile: true),
          if(isTeam) const SizedBox(height: 16),
          if(isTeam) _buildTeachersSection(isMobile: true),
          const SizedBox(height: 16),
          if(isTeacher) _buildBlogsSection(isExpanded: true),
          if(isTeacher) const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ************************ Masaüstü Versiyon ************************
  Widget _buildDesktopProfile() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1500),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SOL SÜTUN: Profil Header, Hakkında ve Kurslar
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 16),
                        _buildAboutSection(),
                        if(!isTeam && !isTeacher) const SizedBox(height: 16),
                        if(!isTeam && !isTeacher) buildSelectedCategoriesChips(),
                        const SizedBox(height: 16),
                        _buildCoursesSection(isMobile: false),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: isTeacher || isTeam ? 1 : 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if(isTeacher && isSelf) appointmentsWidget(context),
                        if(isTeacher && !isSelf && !isCurrentTeam) appointmentWidgetForStudents(context),
                        if(isTeam) const SizedBox(height: 16),
                        if(isTeam) _buildTeachersSection(isMobile: false),
                      ],
                    ),
                  ),
                ],
              ),
             if(isTeacher) const SizedBox(height: 16),
              if(isTeacher) _buildBlogsSection(isExpanded: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSelectedCategoriesChips() {
    List<dynamic> selected = userInfo["selectedCategories"];
    List<dynamic> selectedCategoriesNames = [];
    for(var cat in selected){
      List<String> split = cat.split("-");
      List<Map<String, dynamic>> subCategories = categories.firstWhere((c) => c["UID"] == split[0])["subCategories"];
      String name = subCategories.firstWhere((sc) => sc["UID"] == split[1])["name"];
      selectedCategoriesNames.add(name);
    }
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("İlgilendiği Kategoriler", style: GoogleFonts.poppins(color: Colors.black)),
                  SizedBox(height: 12,),
                  Wrap(
                    spacing: 8.0, // Yatay boşluk
                    runSpacing: 8.0, // Dikey boşluk
                    alignment: WrapAlignment.center,
                    children: List.generate(selectedCategoriesNames.length, (index) {
                      return Chip(
                        label: Text(selectedCategoriesNames[index]),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  // **************** Kurslar (Danışmanlıklar) Bölümü ****************
  Widget _buildCoursesSection({required bool isMobile}) {
    int column = isMobile ? 2 : isTeacher || isTeam ? 3 : 5;
    List<Map<String, dynamic>> lowerList = coursesNeeded.length >= column ? coursesNeeded.sublist(0, column) : coursesNeeded;

    double width = MediaQuery.of(context).size.width;
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // 🔹 İçeriği hizala
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isTeam ? "Kurumda Verilen Danışmanlıklar" : isTeacher ? 'Verdiği Danışmanlıklar' : 'Aldığı Danışmanlıklar',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _headerTextColor),
            ),
            if (isSelf || (isCurrentTeam && teamUidIfCurrent == userInfo["reference"]))
              IconButton(
                onPressed: () => _showCreateCourseDialog(context),
                icon: const Icon(Icons.add_circle, color: Colors.black),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: width < 800 ? 0.65 : 0.75,
            ),
            itemCount: _isCoursesExpanded ? coursesNeeded.length : lowerList.length,
            itemBuilder: (context, index) {
              final course = _isCoursesExpanded ? coursesNeeded[index] : lowerList[index];
              final teacher = teachersNeeded.firstWhere(
                    (teacher) => teacher["UID"] == course["author"],
                orElse: () => {},
              );
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: Duration(milliseconds: 500),
                columnCount: (width / 300).floor(),
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: CourseCard(
                      course: course,
                      author: teacher,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        TextButton(
            onPressed: (){
              _isCoursesExpanded = !_isCoursesExpanded;
              setState(() {
                
              });
            },
            child: Text(_isCoursesExpanded ? "Daralt" : "Genişlet", style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,),
            ),
        )
      ],
    ).animate().fadeIn(duration: 500.ms);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }

  // **************** Danışmanlar Bölümü ****************
  Widget _buildTeachersSection({required bool isMobile}) {
    int column = isMobile ? 1 : 2;
    List<Map<String, dynamic>> lowerList = teachersNeeded.length >= column * 2 ? teachersNeeded.sublist(0, column * 2) : teachersNeeded;

    double width = MediaQuery.of(context).size.width;
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // 🔹 İçeriği hizala
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Kurumdaki Danışmanlar" ,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _headerTextColor),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile  ? 0.65 : 0.55,
            ),
            itemCount: _isTeachersExpanded ? teachersNeeded.length : lowerList.length,
            itemBuilder: (context, index) {
              final teacher = _isTeachersExpanded ? teachersNeeded[index] : lowerList[index];
              final courses = coursesNeeded.where((c) => c["author"] == teacher["UID"]).toList();
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: Duration(milliseconds: 500),
                columnCount: (width / 300).floor(),
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: TeacherCard(
                      teacherData: teacher,
                      teacherCourses: courses,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        TextButton(
          onPressed: (){
            _isTeachersExpanded = !_isTeachersExpanded;
            setState(() {

            });
          },
          child: Text(_isTeachersExpanded ? "Daralt" : "Genişlet", style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,),
          ),
        )
      ],
    ).animate().fadeIn(duration: 500.ms);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }

  // **************** Bloglar Bölümü ****************
  Widget _buildBlogsSection({required bool isExpanded}) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // 🔹 İçeriği hizala
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Yazdığı Bloglar',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _headerTextColor),
            ),
            if (isSelf)
              IconButton(
                onPressed: () {
                  context.go("/blog-create/${userInfo["UID"]}");
                },
                icon: const Icon(Icons.add_circle, color: Colors.black),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Container( // 🔹 Genişliği zorunlu tutuyoruz
          width: double.infinity,
          child: AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 500),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: BlogCard(blog: blogs[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        ),
      ],
    ).animate().fadeIn(duration: 500.ms);

    return isExpanded
        ? Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    )
        : content;
  }

  void showAppointmentsBottomSheet(BuildContext context,) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState2) {
            return Padding(
              padding: MediaQuery
                  .of(context)
                  .viewInsets,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Başlık
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: const Text(
                        'Randevu Takvimi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: ElevatedButton(
                        onPressed: () async
                        {
                          DateTime firstSelectedDate = DateTime.now().add(Duration(days: 1));
                          DateTime secondSelectedDate = DateTime.now().add(Duration(days: 2));
                          List<TimeOfDay> times = [];
                          AwesomeDialog(
                            context: context,
                            width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
                            dialogType: DialogType.noHeader,
                            animType: AnimType.bottomSlide,
                            title: 'Yeni Randevu Talebi',
                            desc: "",
                            // Body kısmında StatefulBuilder kullanarak dinamik içerik oluşturuyoruz
                            body: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setModalState) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF76ABAE),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(double.infinity, 50),
                                      ),
                                      onPressed: () async {
                                        final DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: secondSelectedDate,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(const Duration(days: 365)),
                                          locale: const Locale('tr', 'TR'), // Türkçe için
                                          builder: (context, child) => Theme(
                                            data: _customDatePickerTheme(), // Özel tema
                                            child: child!,
                                          ),
                                        );
                                        if (picked != null) {
                                          setModalState(() {
                                            firstSelectedDate = DateTime(picked.year, picked.month, picked.day, 8);
                                          });
                                        }
                                      },
                                      child: Text(
                                        'Başlangıç Tarihi Seç (${DateFormat('dd/MM/yyyy').format(firstSelectedDate)})',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF76ABAE),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(double.infinity, 50),
                                      ),
                                      onPressed: () async {
                                        final DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: secondSelectedDate,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(const Duration(days: 365)),
                                          locale: const Locale('tr', 'TR'), // Türkçe için
                                          builder: (context, child) => Theme(
                                            data: _customDatePickerTheme(), // Özel tema
                                            child: child!,
                                          ),
                                        );
                                        if (picked != null) {
                                          setModalState(() {
                                            secondSelectedDate = DateTime(picked.year, picked.month, picked.day, 8);
                                          });
                                        }
                                      },
                                      child: Text(
                                        'Bitiş Tarihi Seç (${DateFormat('dd/MM/yyyy').format(secondSelectedDate)})',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      alignment: WrapAlignment.center,
                                      children: timeSlots.map((slot) {
                                        // Başlangıç saati
                                        final int slotStart =
                                        int.parse(slot["start"]!.split(":")[0]);

                                        final bool isSelected = times.contains(TimeOfDay(hour: slotStart, minute: 0));

                                        return GestureDetector(
                                          onTap: () {
                                            setModalState(() {
                                              if(isSelected)
                                              {
                                                times.remove(TimeOfDay(hour: slotStart, minute: 0));
                                              }
                                              else{
                                                times.add(TimeOfDay(hour: slotStart, minute: 0));
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: 80,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(
                                                  0xFF76ABAE)
                                                  : const Color(0xFF393E46),
                                              borderRadius: BorderRadius.circular(8),
                                              border: isSelected
                                                  ? Border.all(
                                                  color: Colors.white, width: 2)
                                                  : null,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${slot['start']} - ${slot['end']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),

                                  ],
                                );
                              },
                            ),
                            btnOkText: "Seç",
                            btnCancelText: "İptal",
                            btnOkOnPress: () async {
                              LoadingIndicator(context).showLoading();
                              if(firstSelectedDate == secondSelectedDate)
                              {
                                for(TimeOfDay time in times)
                                {
                                  DateTime newDate = DateTime(firstSelectedDate.year, firstSelectedDate.month, firstSelectedDate.day, time.hour, time.minute);
                                  await FirestoreService().updateTeacherAvailableHours(widget.uid, newDate);
                                }
                                setState((){});
                              }
                              else if(firstSelectedDate.isBefore(secondSelectedDate))
                              {
                                DateTime first = firstSelectedDate;
                                while(true){
                                  for(TimeOfDay time in times)
                                  {
                                    print("Girdi");
                                    DateTime newDate = DateTime(first.year, first.month, first.day, time.hour, time.minute);
                                    await FirestoreService().updateTeacherAvailableHours(widget.uid, newDate);
                                  }
                                  if(first == secondSelectedDate){
                                    break;
                                  }
                                  first = first.add(Duration(days: 1));
                                }
                                setState((){});
                              }
                              else if(firstSelectedDate.isAfter(secondSelectedDate))
                              {
                                AwesomeDialog(
                                    context: context,
                                    width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,

                                    dialogType: DialogType.error,
                                    animType: AnimType.bottomSlide,
                                    body: const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Hatalı veya Eksik Bilgi (Tarihleri Kontrol Ediniz)',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    dismissOnTouchOutside: false,
                                    dismissOnBackKeyPress: false,
                                    btnOkText: "Tamam",
                                    btnOkOnPress: () {}
                                ).show();
                              }
                              await initData();
                              print(firstSelectedDate);
                              print(secondSelectedDate);
                              Navigator.pop(context);

                            },
                            btnCancelOnPress: () {},
                          ).show();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF222831),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                            side: const BorderSide(color: Color(0xFFEEEEEE), width: 2),
                          ),
                        ),
                        child: const Text('Çoklu Müsaitlik Ayarlama', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    TableCalendar(
                      locale: 'tr_TR',
                      focusedDay: _focusedDay,
                      firstDay: DateTime.now().add(Duration(days: -1)),
                      lastDay: DateTime.utc(2030, 12, 31),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      eventLoader: (day) {
                        final dayOnly = DateTime(
                            day.year, day.month, day.day);
                        return eventsMap[dayOnly] ?? [];
                      },
                      availableCalendarFormats: {
                        CalendarFormat.month: "Ay",
                        CalendarFormat.twoWeeks: "2 Hafta",
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectedTime = null;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        markerDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    if (_selectedDay != null) ...[
                      const SizedBox(height: 16),

                      // Seçilen Gün
                      Text(
                        'Seçilen Gün: '
                            '${_selectedDay!.day}.${_selectedDay!
                            .month}.${_selectedDay!.year}',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 8),

                      // Saat Seçimi
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.center,
                        children: timeSlots.map((slot) {
                          // Başlangıç saati
                          final int slotStart =
                          int.parse(slot["start"]!.split(":")[0]);

                          // Seçili güne bu saati ekliyoruz
                          final DateTime slotDateTime = DateTime(
                            _selectedDay!.year,
                            _selectedDay!.month,
                            _selectedDay!.day,
                            slotStart,
                            0,
                          );

                          bool canReserve = true;
                          for (DateTime date in teacherAppDates) {
                            if (date.year == slotDateTime.toUtc().year &&
                                date.month == slotDateTime.toUtc().month &&
                                date.day == slotDateTime.toUtc().day &&
                                date.hour == slotDateTime.toUtc().hour) {
                              canReserve = false; // Bu saat dolu
                              break;
                            }
                          }

                          bool hasAvailable = false;
                          for (DateTime date in availableHours) {
                            if (date.year == slotDateTime.year &&
                                date.month == slotDateTime.month &&
                                date.day == slotDateTime.day &&
                                date.hour == slotDateTime.hour) {
                              hasAvailable = true; // Bu saat dolu
                              break;
                            }
                          }

                          // Seçilen saat mi?
                          final bool isSelected = _selectedTime != null &&
                              _selectedTime!.year == slotDateTime.year &&
                              _selectedTime!.month == slotDateTime.month &&
                              _selectedTime!.day == slotDateTime.day &&
                              _selectedTime!.hour == slotDateTime.hour;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTime = slotDateTime;
                                selectedAvailable = hasAvailable;
                              });
                            },
                            child: Container(
                              width: 80,
                              // 4 slotun yan yana gelmesi için
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(
                                    0xFF76ABAE) // Seçilen slot rengi
                                    : !hasAvailable
                                    ? Colors.red // Boş slot
                                    : canReserve ? Colors.green : const Color(0xFF393E46), // Dolu slot
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(
                                    color: Colors.white, width: 2)
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${slot['start']} - ${slot['end']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          // Henüz saat seçilmediyse (null) => buton da pasif kalsın
                          if (_selectedTime == null) {
                            return ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF76ABAE),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 50),
                              ),
                              child: const Text("Saat Seçiniz"),
                            );
                          }

                          final existingAppointment = appointments
                              .firstWhere((app) {
                            final dt = (app['date'] as Timestamp).toDate();
                            return dt.year == _selectedTime!.year &&
                                dt.month == _selectedTime!.month &&
                                dt.day == _selectedTime!.day &&
                                dt.hour == _selectedTime!.hour;
                          }, orElse: () => {});
                          if (existingAppointment.isNotEmpty) {
                            return Container(
                              height: 400,
                              child: AppointmentCard(
                                appointmentUID: existingAppointment["UID"],
                                isTeacher: false,
                              ),
                            );
                          } else {
                            return selectedAvailable ? ElevatedButton(
                              onPressed: () async {
                                AwesomeDialog(
                                  context: context,
                                  width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,

                                  dialogType: DialogType.noHeader,
                                  animType: AnimType.bottomSlide,
                                  title: 'Randevuya Ayırdığın Saati Sil',
                                  desc: 'Randevuya Ayırdığınız Saati Silmek İstiyor Musunuz?',
                                  body: StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setModalState) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: 10),
                                          Text(
                                            'Randevuya Ayırdığınız Saati Silmek İstiyor Musunuz?',
                                            style: TextStyle(
                                                fontSize: 16),
                                          ), SizedBox(height: 10),
                                        ],
                                      );
                                    },
                                  ),
                                  btnOkText: "Evet",
                                  btnCancelText: "Hayır",
                                  btnOkOnPress: () async {
                                    await FirestoreService()
                                        .removeTeacherAvailableHour(
                                        widget.uid,
                                        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, _selectedTime!.hour, _selectedTime!.minute));
                                    userInfo = await FirestoreService().getTeacherByUID(widget.uid);
                                    setState((){});
                                  },
                                  btnCancelOnPress: () {},
                                ).show();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF76ABAE),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 50),
                              ),
                              child: const Text(
                                "Randevuya Ayırdığın Saati İptal Et",
                                style: TextStyle(color: Colors.red),),
                            ) :
                            ElevatedButton(
                              onPressed: () async {
                                AwesomeDialog(
                                  context: context,
                                  width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,

                                  dialogType: DialogType.noHeader,
                                  animType: AnimType.bottomSlide,
                                  title: 'Saati Randevuya Ayır',
                                  desc: 'Bu Saati Randevuya Ayırmak İstiyor Musunuz?',
                                  // Body kısmında StatefulBuilder kullanarak dinamik içerik oluşturuyoruz
                                  body: StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setModalState) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: 10),
                                          Text(
                                            'Bu Saati Randevuya Ayırmak İstiyor Musunuz?',
                                            style: TextStyle(fontSize: 16),
                                          ), SizedBox(height: 10),
                                        ],
                                      );
                                    },
                                  ),
                                  // Dialog'un altındaki butonlar
                                  btnOkText: "Evet",
                                  btnCancelText: "Hayır",
                                  btnOkOnPress: () async {
                                    await FirestoreService()
                                        .updateTeacherAvailableHours(
                                        widget.uid,
                                        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, _selectedTime!.hour, _selectedTime!.minute));
                                    userInfo = await FirestoreService().getTeacherByUID(widget.uid);
                                    setState((){});
                                  },
                                  btnCancelOnPress: () {},
                                ).show();

                                debugPrint("Yeni randevu ekleme işlemi");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF76ABAE),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 50),
                              ),
                              child: const Text("Bu Saati Randevuya Ayır"),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget appointmentsWidget(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState2) {
        return Padding(
          padding: MediaQuery
              .of(context)
              .viewInsets,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: const Text(
                    'Randevu Takvimi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: () async
                    {
                      DateTime firstSelectedDate = DateTime.now().add(Duration(days: 1));
                      DateTime secondSelectedDate = DateTime.now().add(Duration(days: 2));
                      List<TimeOfDay> times = [];
                      AwesomeDialog(
                        context: context,
                        width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
                        dialogType: DialogType.noHeader,
                        animType: AnimType.bottomSlide,
                        title: 'Yeni Randevu Talebi',
                        desc: "",
                        // Body kısmında StatefulBuilder kullanarak dinamik içerik oluşturuyoruz
                        body: StatefulBuilder(
                          builder: (BuildContext context, StateSetter setModalState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF76ABAE),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: secondSelectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                      locale: const Locale('tr', 'TR'), // Türkçe için
                                      builder: (context, child) => Theme(
                                        data: _customDatePickerTheme(), // Özel tema
                                        child: child!,
                                      ),
                                    );
                                    if (picked != null) {
                                      setModalState(() {
                                        firstSelectedDate = DateTime(picked.year, picked.month, picked.day, 8);
                                      });
                                    }
                                  },
                                  child: Text(
                                    'Başlangıç Tarihi Seç (${DateFormat('dd/MM/yyyy').format(firstSelectedDate)})',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF76ABAE),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: secondSelectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                      locale: const Locale('tr', 'TR'), // Türkçe için
                                      builder: (context, child) => Theme(
                                        data: _customDatePickerTheme(), // Özel tema
                                        child: child!,
                                      ),
                                    );
                                    if (picked != null) {
                                      setModalState(() {
                                        secondSelectedDate = DateTime(picked.year, picked.month, picked.day, 8);
                                      });
                                    }
                                  },
                                  child: Text(
                                    'Bitiş Tarihi Seç (${DateFormat('dd/MM/yyyy').format(secondSelectedDate)})',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  alignment: WrapAlignment.center,
                                  children: timeSlots.map((slot) {
                                    // Başlangıç saati
                                    final int slotStart =
                                    int.parse(slot["start"]!.split(":")[0]);

                                    final bool isSelected = times.contains(TimeOfDay(hour: slotStart, minute: 0));

                                    return GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          if(isSelected)
                                          {
                                            times.remove(TimeOfDay(hour: slotStart, minute: 0));
                                          }
                                          else{
                                            times.add(TimeOfDay(hour: slotStart, minute: 0));
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 80,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(
                                              0xFF76ABAE)
                                              : const Color(0xFF393E46),
                                          borderRadius: BorderRadius.circular(8),
                                          border: isSelected
                                              ? Border.all(
                                              color: Colors.white, width: 2)
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${slot['start']} - ${slot['end']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                              ],
                            );
                          },
                        ),
                        btnOkText: "Seç",
                        btnCancelText: "İptal",
                        btnOkOnPress: () async {
                          LoadingIndicator(context).showLoading();
                          if(firstSelectedDate == secondSelectedDate)
                          {
                            for(TimeOfDay time in times)
                            {
                              DateTime newDate = DateTime(firstSelectedDate.year, firstSelectedDate.month, firstSelectedDate.day, time.hour, time.minute);
                              await FirestoreService().updateTeacherAvailableHours(widget.uid, newDate);
                            }
                            setState((){});
                          }
                          else if(firstSelectedDate.isBefore(secondSelectedDate))
                          {
                            DateTime first = firstSelectedDate;
                            while(true){
                              for(TimeOfDay time in times)
                              {
                                print("Girdi");
                                DateTime newDate = DateTime(first.year, first.month, first.day, time.hour, time.minute);
                                await FirestoreService().updateTeacherAvailableHours(widget.uid, newDate);
                              }
                              if(first == secondSelectedDate){
                                break;
                              }
                              first = first.add(Duration(days: 1));
                            }
                            setState((){});
                          }
                          else if(firstSelectedDate.isAfter(secondSelectedDate))
                          {
                            AwesomeDialog(
                                context: context,
                                width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
                                dialogType: DialogType.error,
                                animType: AnimType.bottomSlide,
                                body: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Hatalı veya Eksik Bilgi (Tarihleri Kontrol Ediniz)',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                dismissOnTouchOutside: false,
                                dismissOnBackKeyPress: false,
                                btnOkText: "Tamam",
                                btnOkOnPress: () {}
                            ).show();
                          }
                          await initData();
                          print(firstSelectedDate);
                          print(secondSelectedDate);
                          Navigator.pop(context);

                        },
                        btnCancelOnPress: () {},
                      ).show();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF222831),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                        side: const BorderSide(color: Color(0xFFEEEEEE), width: 2),
                      ),
                    ),
                    child: const Text('Çoklu Müsaitlik Ayarlama', style: TextStyle(color: Colors.white),),
                  ),
                ),
                TableCalendar(
                  locale: 'tr_TR',
                  focusedDay: _focusedDay,
                  firstDay: DateTime.now().add(Duration(days: -1)),
                  lastDay: DateTime.utc(2030, 12, 31),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) =>
                      isSameDay(_selectedDay, day),
                  eventLoader: (day) {
                    final dayOnly = DateTime(
                        day.year, day.month, day.day);
                    return eventsMap[dayOnly] ?? [];
                  },
                  availableCalendarFormats: {
                    CalendarFormat.month: "Ay",
                    CalendarFormat.twoWeeks: "2 Hafta",
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedTime = null;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                if (_selectedDay != null) ...[
                  const SizedBox(height: 16),

                  // Seçilen Gün
                  Text(
                    'Seçilen Gün: '
                        '${_selectedDay!.day}.${_selectedDay!
                        .month}.${_selectedDay!.year}',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 8),

                  // Saat Seçimi
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: timeSlots.map((slot) {
                      // Başlangıç saati
                      final int slotStart =
                      int.parse(slot["start"]!.split(":")[0]);

                      // Seçili güne bu saati ekliyoruz
                      final DateTime slotDateTime = DateTime(
                        _selectedDay!.year,
                        _selectedDay!.month,
                        _selectedDay!.day,
                        slotStart,
                        0,
                      );

                      bool canReserve = true;
                      for (DateTime date in teacherAppDates) {
                        if (date.year == slotDateTime.toUtc().year &&
                            date.month == slotDateTime.toUtc().month &&
                            date.day == slotDateTime.toUtc().day &&
                            date.hour == slotDateTime.toUtc().hour) {
                          canReserve = false; // Bu saat dolu
                          break;
                        }
                      }

                      bool hasAvailable = false;
                      for (DateTime date in availableHours) {
                        if (date.year == slotDateTime.year &&
                            date.month == slotDateTime.month &&
                            date.day == slotDateTime.day &&
                            date.hour == slotDateTime.hour) {
                          hasAvailable = true; // Bu saat dolu
                          break;
                        }
                      }

                      // Seçilen saat mi?
                      final bool isSelected = _selectedTime != null &&
                          _selectedTime!.year == slotDateTime.year &&
                          _selectedTime!.month == slotDateTime.month &&
                          _selectedTime!.day == slotDateTime.day &&
                          _selectedTime!.hour == slotDateTime.hour;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTime = slotDateTime;
                            selectedAvailable = hasAvailable;
                          });
                        },
                        child: Container(
                          width: 80,
                          // 4 slotun yan yana gelmesi için
                          padding: const EdgeInsets.symmetric(
                              vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(
                                0xFF76ABAE) // Seçilen slot rengi
                                : !hasAvailable
                                ? Colors.red // Boş slot
                                : canReserve ? Colors.green : const Color(0xFF393E46), // Dolu slot
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(
                                color: Colors.white, width: 2)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${slot['start']} - ${slot['end']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      // Henüz saat seçilmediyse (null) => buton da pasif kalsın
                      if (_selectedTime == null) {
                        return ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF76ABAE),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 50),
                          ),
                          child: const Text("Saat Seçiniz"),
                        );
                      }

                      final existingAppointment = appointments
                          .firstWhere((app) {
                        final dt = (app['date'] as Timestamp).toDate();
                        return dt.year == _selectedTime!.year &&
                            dt.month == _selectedTime!.month &&
                            dt.day == _selectedTime!.day &&
                            dt.hour == _selectedTime!.hour;
                      }, orElse: () => {});
                      if (existingAppointment.isNotEmpty) {
                        return Container(
                          height: 400,
                          child: AppointmentCard(
                            appointmentUID: existingAppointment["UID"],
                            isTeacher: false,
                          ),
                        );
                      } else {
                        return selectedAvailable ? ElevatedButton(
                          onPressed: () async {
                            AwesomeDialog(
                              context: context,
                              width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
                              dialogType: DialogType.noHeader,
                              animType: AnimType.bottomSlide,
                              title: 'Randevuya Ayırdığın Saati Sil',
                              desc: 'Randevuya Ayırdığınız Saati Silmek İstiyor Musunuz?',
                              body: StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setModalState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        'Randevuya Ayırdığınız Saati Silmek İstiyor Musunuz?',
                                        style: TextStyle(
                                            fontSize: 16),
                                      ), SizedBox(height: 10),
                                    ],
                                  );
                                },
                              ),
                              btnOkText: "Evet",
                              btnCancelText: "Hayır",
                              btnOkOnPress: () async {
                                await FirestoreService()
                                    .removeTeacherAvailableHour(
                                    widget.uid,
                                    DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, _selectedTime!.hour, _selectedTime!.minute));
                                userInfo = await FirestoreService().getTeacherByUID(widget.uid);
                                setState((){});
                              },
                              btnCancelOnPress: () {},
                            ).show();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF76ABAE),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 50),
                          ),
                          child: const Text(
                            "Randevuya Ayırdığın Saati İptal Et",
                            style: TextStyle(color: Colors.red),),
                        ) :
                        ElevatedButton(
                          onPressed: () async {
                            AwesomeDialog(
                              context: context,
                              width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
                              dialogType: DialogType.noHeader,
                              animType: AnimType.bottomSlide,
                              title: 'Saati Randevuya Ayır',
                              desc: 'Bu Saati Randevuya Ayırmak İstiyor Musunuz?',
                              // Body kısmında StatefulBuilder kullanarak dinamik içerik oluşturuyoruz
                              body: StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setModalState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        'Bu Saati Randevuya Ayırmak İstiyor Musunuz?',
                                        style: TextStyle(fontSize: 16),
                                      ), SizedBox(height: 10),
                                    ],
                                  );
                                },
                              ),
                              // Dialog'un altındaki butonlar
                              btnOkText: "Evet",
                              btnCancelText: "Hayır",
                              btnOkOnPress: () async {
                                await FirestoreService()
                                    .updateTeacherAvailableHours(
                                    widget.uid,
                                    DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, _selectedTime!.hour, _selectedTime!.minute));
                                userInfo = await FirestoreService().getTeacherByUID(widget.uid);
                                setState((){});
                              },
                              btnCancelOnPress: () {},
                            ).show();

                            debugPrint("Yeni randevu ekleme işlemi");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF76ABAE),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 50),
                          ),
                          child: const Text("Bu Saati Randevuya Ayır"),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget appointmentWidgetForStudents(BuildContext context){
    return Container(
          decoration: BoxDecoration(
            color: Color(0xFF222831),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)),
            gradient:  LinearGradient(
              colors:
              [
                Color(0xFF3C72C2),
                Color(0xFF3C72C2),
              ], // Yeni gradyan renkleri
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
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
                const Center(
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
                DropdownButtonFormField<String>(
                  dropdownColor: _backgroundColor,
                  value: course["UID"],
                  decoration: _inputDecoration('Bir Danışmanlık Seçin'),
                  icon: Icon(Icons.arrow_drop_down, color: _darkColor),
                  onChanged: (String? newValue) {
                    setState(() {
                      course = coursesNeeded.firstWhere((c) => c["UID"] == newValue);
                      print(course);
                    });
                  },
                  items: coursesNeeded.map<DropdownMenuItem<String>>((cou) {
                    return DropdownMenuItem<String>(
                      value: cou['UID'],
                      child: Text(cou['name'], style: GoogleFonts.poppins(color: _bodyTextColor)),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
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
                            print(selectedTimes.length);
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
                      print(course);
                      userInfo = await FirestoreService()
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Randevu başarıyla oluşturuldu')),
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
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [_darkColor, _darkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: userInfo['profilePictureUrl'] != null
                ? NetworkImage(userInfo['profilePictureUrl'])
                : const AssetImage('assets/default_profile.png')
            as ImageProvider,
          ).animate().fadeIn(duration: 500.ms),
          if (isSelf)
            TextButton(
              onPressed: () => _showChangePhotoDialog(context),
              child: Text(
                "Profil Fotoğrafını Değiştir",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontStyle: FontStyle.italic),
              ),
            ),
          const SizedBox(height: 5),
          // İsim ve düzenleme / çıkış seçenekleri:
          isSelf
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: "İsmi Düzenle",
                onPressed: () => _showChangeNameDialog(context),
                icon: const Icon(Icons.edit_note, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Text(
                userInfo['name'] ?? '',
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _headerTextColor),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(width: 15),
              IconButton(
                tooltip: "Çıkış Yap",
                onPressed: () => _showLogOutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.red),
              ),
            ],
          )
              : (!isSelf && !isCurrentTeam
              ? Text(
            userInfo['name'] ?? '',
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _headerTextColor),
          ).animate().fadeIn(duration: 500.ms)
              : Column(
            children: [
              Text(
                userInfo['name'] ?? '',
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _headerTextColor),
              ).animate().fadeIn(duration: 500.ms),
              if(isTeam == false)
              TextButton(
                onPressed: () => _showOurEmployeeDialog(context),
                child: Text(
                  "Bu Kişi Benim Ekibimden",
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.white),
                ),
              )
            ],
          )),
          const SizedBox(height: 10),
          if (isSelf)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NotificationIconButtonWithBadge(
                  userType: isTeacher ? UserType.teacher : UserType.student,
                  userUID: widget.uid,
                ),
                const SizedBox(width: 4),
                Text(
                  isTeacher ? 'Eğitimci' : isTeam ? "Eğitim Kurumu" : 'Öğrenci',
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // **************** Hakkında (About) Bölümü ****************
  Widget _buildAboutSection() {
    Widget content = InkWell(
      onTap: () => _showFullDescriptionDialog(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          userInfo['desc'] == null
              ? ""
              : userInfo['desc'].length > 300
              ? userInfo['desc'].substring(0, 300) + "..."
              : userInfo['desc'],
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
          'Hakkında',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _headerTextColor,
          ),
        ),
        trailing: isSelf
            ? IconButton(
          tooltip: "Hakkında'yı Düzenle",
          onPressed: () => _showChangeDescDialog(context),
          icon: const Icon(Icons.edit_note, color: Colors.black),
        )
            : null,
        children: [content],
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
            userInfo['desc'] ?? "",
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

  // **************** Diyalog ve Yardımcı Metotlar ****************
  Future<void> _showChangePhotoDialog(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: LoadingAnimationWidget.twistingDots(
                leftDotColor: _darkColor,
                rightDotColor: Colors.deepPurple,
                size: 100),
          );
        },
      );
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_photos')
            .child(widget.uid)
            .child(fileName);
        final uploadTask = storageRef.putData(fileBytes);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();
        if(!isTeam) await FirestoreService().changeUserPhoto(widget.uid, downloadUrl, isTeacher);
        else await FirestoreService().changeTeamPhoto(widget.uid, downloadUrl);
        setState(() {
          userInfo['profilePictureUrl'] = downloadUrl;
        });
        Navigator.of(context).pop();
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotoğrafı yüklenirken hata oluştu')),
        );
      }
    }
  }

  Future<void> _showChangeDescDialog(BuildContext context) async {
    TextEditingController descController = TextEditingController(text: userInfo['desc']);
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Açıklamayı Değiştir',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _headerTextColor)),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 5,
                style: GoogleFonts.poppins(color: _bodyTextColor),
                decoration: InputDecoration(
                  hintText: 'Yeni Açıklama',
                  hintStyle: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if(!isTeam) await FirestoreService().changeUserDesc(widget.uid, descController.text, isTeacher);
                  else await FirestoreService().changeTeamDesc(widget.uid, descController.text);
                  setState(() {
                    userInfo['desc'] = descController.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Kaydet', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showChangeNameDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController(text: userInfo['name']);
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration:BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3C72C2), Color(0xFF3C72C2)], // Gradyan renkleri
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('İsmi Değiştir',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    )),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.poppins(color: _bodyTextColor),
                  decoration: InputDecoration(
                    hintText: 'Yeni İsim',
                    hintStyle: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if(!isTeam) await FirestoreService().changeUserName(widget.uid, nameController.text, isTeacher);
                    else await FirestoreService().changeTeamName(widget.uid, nameController.text);
                    setState(() {
                      userInfo['name'] = nameController.text;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Kaydet', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),

                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLogOutDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              Text('Çıkış Yapmak İstiyor Musunuz?',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _headerTextColor)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  bool a = await AuthService().signOut();
                  if (a)
                    context.go("/login");
                  else
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Çıkış Yapılırken Hata Oluştu')),
                    );
                },
                child: Text('Evet, Çıkış Yap', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showOurEmployeeDialog(BuildContext context) async {
    String type = isTeacher ? "Eğitimci" : "Öğrenci";
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              Text('Bu $type Sizin Ekibinizden Mi?',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _headerTextColor)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (isTeacher) {
                    await FirestoreService().sendRFromTeamToTeacher(widget.uid, teamUidIfCurrent, teamNameIfCurrent);
                  } else {
                    await FirestoreService().sendRFromTeamToStudent(widget.uid, teamUidIfCurrent, teamNameIfCurrent);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Katılma isteği gönderildi')),
                  );
                },
                child: Text('Evet, Katılma İsteği Gönder', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCreateCourseDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    List<PlatformFile> photos = [];
    List<Map<String, dynamic>> subCategories = [];
    String? selectedCategory;
    String? selectedSubCategory;

    void updateSubCategories() {
      if (selectedCategory != null) {
        final category = categories.firstWhere((cat) => cat['UID'] == selectedCategory);
        subCategories = List<Map<String, dynamic>>.from(category['subCategories']);
      } else {
        subCategories = [];
      }
      selectedSubCategory = null;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Yeni Kurs Oluştur',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _headerTextColor)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      dropdownColor: _backgroundColor,
                      value: courseCreationSelectedTeacher["UID"],
                      decoration: _inputDecoration('Bir Danışman Seçin'),
                      icon: Icon(Icons.arrow_drop_down, color: _darkColor),
                      onChanged: (String? newValue) {
                        setState(() {
                          courseCreationSelectedTeacher = teachersNeeded.firstWhere((t) => t["UID"] == newValue);
                          print(courseCreationSelectedTeacher);
                        });
                      },
                      items: teachersNeeded.map<DropdownMenuItem<String>>((cou) {
                        return DropdownMenuItem<String>(
                          value: cou['UID'],
                          child: Text(cou['name'], style: GoogleFonts.poppins(color: _bodyTextColor)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.poppins(color: _bodyTextColor),
                      decoration: InputDecoration(
                        hintText: 'Kurs Adı',
                        hintStyle: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      maxLines: 5,
                      style: GoogleFonts.poppins(color: _bodyTextColor),
                      decoration: InputDecoration(
                        hintText: 'Kurs Açıklaması',
                        hintStyle: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      value: selectedCategory,
                      hint: Text('Kategori Seç', style: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7))),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setModalState(() {
                          selectedCategory = newValue;
                          updateSubCategories();
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
                    if (selectedCategory != null)
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: selectedSubCategory,
                        hint: Text('Alt Kategori Seç', style: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7))),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (String? newValue) {
                          setModalState(() {
                            selectedSubCategory = newValue;
                          });
                        },
                        items: subCategories.map<DropdownMenuItem<String>>((subCat) {
                          return DropdownMenuItem<String>(
                            value: subCat['UID'],
                            child: Text(subCat['name'], style: GoogleFonts.poppins(color: _bodyTextColor)),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(color: _bodyTextColor),
                      decoration: InputDecoration(
                        hintText: 'Saatlik Ücret',
                        hintStyle: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: true,
                        );
                        if (result != null) {
                          if (result.files.length > 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('En fazla 4 fotoğraf seçebilirsiniz')),
                            );
                          } else {
                            setModalState(() {
                              photos = result.files;
                            });
                          }
                        }
                      },
                      child: Text('Fotoğrafları Seç (${photos.length})', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (photos.isNotEmpty)
                      CarouselSlider(
                        options: CarouselOptions(
                          aspectRatio: 2.0,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                          scrollDirection: Axis.horizontal,
                        ),
                        items: photos.map((file) {
                          return Stack(
                            key: UniqueKey(),
                            children: [
                              Image.memory(
                                file.bytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              Positioned(
                                top: 8.0,
                                right: 8.0,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setModalState(() {
                                      photos.remove(file);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          if (nameController.text.isNotEmpty &&
                              descController.text.isNotEmpty &&
                              selectedCategory != null &&
                              selectedSubCategory != null &&
                              priceController.text.isNotEmpty &&
                              photos.isNotEmpty) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Center(
                                  child: LoadingAnimationWidget.twistingDots(
                                      leftDotColor: _darkColor,
                                      rightDotColor: Colors.deepPurple,
                                      size: 100),
                                );
                              },
                            );
                            final photoUrls = await Future.wait(
                              photos.map((photo) async {
                                final storageRef = FirebaseStorage.instance
                                    .ref()
                                    .child('course_photos')
                                    .child(widget.uid)
                                    .child(photo.name);
                                final uploadTask = storageRef.putData(photo.bytes!);
                                final snapshot = await uploadTask.whenComplete(() => null);
                                return await snapshot.ref.getDownloadURL();
                              }).toList(),
                            );
                            await FirestoreService().createCourse(
                              nameController.text,
                              descController.text,
                              widget.uid,
                              selectedCategory!,
                              selectedSubCategory!,
                              double.parse(priceController.text),
                              photoUrls,
                            );
                            Navigator.pop(context); // Yükleniyor animasyonunu kapat
                            Navigator.pop(context); // Modal'ı kapat
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kurs Onaya Gönderildi')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lütfen tüm alanları doldurun ve en az bir fotoğraf seçin')),
                            );
                          }
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kurs oluşturulurken bir hata oluştu')),
                          );
                        }
                      },
                      child: Text('Oluştur', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
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
          ? SizedBox.shrink()
          : isMobile
          ? Image.asset(
        'assets/AYBUKOM1.png',
        height: isMobile ? 50 : 70,
        key: ValueKey('expanded-logo'),
      ).animate().fadeIn(duration: 1000.ms)
          : AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _isAppBarExpanded
            ? Image.asset(
          'assets/AYBUKOM1.png',
          height: isMobile ? 50 : 70,
          key: ValueKey('expanded-logo'),
        ).animate().fadeIn(duration: 1000.ms)
            : Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/AYBUKOM1.png',
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

}




ThemeData _customDatePickerTheme() {
  return ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF76ABAE),       // Seçili tarih & header
      surface: Color(0xFF222831),       // Header arkaplan
      onSurface: Colors.white,          // Metin renkleri
    ),
    dialogBackgroundColor: const Color(0xFF393E46), // Ana arkaplan
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.redAccent, // İptal butonu
      ),
    ),
  );
}
