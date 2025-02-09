import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/LoadingIndicator.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:ozel_ders/Components/comment.dart';
import 'Components/Drawer.dart';

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

  @override
  void initState() {
    initMenu();
    super.initState();
  }
  Future<void> initMenu() async
  {
    isLoggedIn = await AuthService().isUserSignedIn();
    print(isLoggedIn);
    initData();
    setState(() {});
  }

  Future<void> initData() async {
    course = await FirestoreService().getCourseByUID(widget.uid);
    teacher = await FirestoreService().getTeacherByUID(course["author"]);
    teacherApps = await FirestoreService().getUserAppointments(course["author"], true);
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

        for(Timestamp a in teacherAvailableHours)
        {
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
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                        backgroundColor: const Color(0xFF76ABAE),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().add(const Duration(days: 2)), // minTime → 2 gün sonrası
                          lastDate: DateTime.now().add(const Duration(days: 365)), // maxTime → 365 gün sonrası
                          locale: const Locale('tr', 'TR'), // Türkçe takvim
                          builder: (context, child) => Theme(
                            data: _customDatePickerTheme(),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked; // Saat bilgisi korunuyor (8AM isterseniz DateTime(picked.year, picked.month, picked.day, 8) yapın)
                          });
                        }
                      },
                      child: Text(
                        'Tarih Seç (${DateFormat('dd/MM/yyyy').format(selectedDate)})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),                    SizedBox(height: 16),
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
                                    dateTime.month == slotDateTime.month &&
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
                                  ? Color(0xFF76ABAE)
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
                              padding:
                              const EdgeInsets.symmetric(vertical: 2.0),
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
                        backgroundColor: Color(0xFF76ABAE),
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

                          String appUID = await FirestoreService().createAppointment(
                            course["author"],
                            user.uid,
                            course["uid"],
                            "",
                            selectedTimes, // Liste olarak gönderiyoruz
                          );
                          Map<String, dynamic> userMap = await FirestoreService().getStudentByUID(user.uid);
                          await FirestoreService().sendAppointmentToTeacher(appUID, course["author"], user.uid, userMap["name"]);
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF222831),
        title: Image.asset('assets/vitament1.png', height: MediaQuery
            .of(context)
            .size
            .width < 800 ? 60 : 80),
        centerTitle: MediaQuery
            .of(context)
            .size
            .width < 800 ? true : false,
        leading: MediaQuery
            .of(context)
            .size
            .width < 800
            ? IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        )
            : null,
        actions: MediaQuery
            .of(context)
            .size
            .width >= 800
            ? [
          TextButton(
            onPressed: () {
              context.go('/');
            },
            child: const Text('Ana Sayfa', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/courses'); // CategoriesPage'e yönlendirme
            },
            child: const Text('Danışmanlıklar', style: TextStyle(
                color: Color(0xFF76ABAE), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/blogs');
            },
            child: Text('Blog',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          isLoggedIn ? TextButton(
            onPressed: () {
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
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]
            : null,
      ),
      drawer: MediaQuery
          .of(context)
          .size
          .width < 800
          ? DrawerMenu(isLoggedIn: isLoggedIn)
          : null,
      body: isLoading
          ? Center(child: LoadingAnimationWidget.dotsTriangle(
          color: const Color(0xFF222831), size: 200))
          : SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(2.0),
                    color: const Color(0xFF222831),
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
                              .height * 2 / 4 : MediaQuery
                              .of(context)
                              .size
                              .height * 1 / 4,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              aspectRatio: 22 / 9,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: false,
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
                            }).toList() ??
                                [],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MediaQuery
                        .of(context)
                        .size
                        .width >= 800
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side
                        Expanded(
                          flex: 4,
                          child: Card(
                            color: const Color(0xFF222831),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: [
                                      Text(
                                        'Kurs Açıklaması',
                                        style: TextStyle(fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(
                                      thickness: 2, color: Colors.white),
                                  const SizedBox(height: 8),
                                  Text(
                                    course['desc'] ?? '',
                                    style: const TextStyle(fontSize: 15,
                                        fontWeight: FontWeight.bold,
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                            0xFF222831),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10.0), // İstediğiniz kenar yuvarlama miktarını belirleyebilirsiniz
                                          // Diğer shape özelliklerini de belirleyebilirsiniz
                                        ),
                                      ),
                                      onPressed: () {
                                        if (isLoggedIn)
                                          _showDateTimePicker(context);
                                        else
                                          context.go('/login');
                                      },
                                      child: Text(
                                        '\n Bu Kursu Satın Al - ${course['hourlyPrice']} TL \n',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Card(
                                      color: const Color(0xFF50727B),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center,
                                          children: [
                                            CircleAvatar(
                                              foregroundColor: Colors.white,
                                              radius: 60,
                                              backgroundImage: NetworkImage(
                                                  teacher['profilePictureUrl'] ??
                                                      ''),
                                            ),
                                            const SizedBox(height: 16),
                                            TextButton(
                                              child: Text(
                                                teacher['name'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    color: Colors.white),
                                              ),
                                              onPressed: () {
                                                context.go("/profile/" +
                                                    teacher["uid"]);
                                              },
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              teacher['fieldOfStudy'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF222831),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // İstediğiniz kenar yuvarlama miktarını belirleyebilirsiniz
                              // Diğer shape özelliklerini de belirleyebilirsiniz
                            ),
                          ),
                          onPressed: () {
                            _showDateTimePicker(context);
                          },
                          child: Text(
                            'Bu Kursu Satın Al - ${course['hourlyPrice']} TL',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          color: const Color(0xFF222831),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            title: const Text(
                              'Kurs Açıklaması',
                              style: TextStyle(fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  course['desc'] ?? '',
                                  style: const TextStyle(color: Colors.white),
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
                              style: TextStyle(fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center,
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          teacher['profilePictureUrl'] ?? ''),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      teacher['name'] ?? '',
                                      style: const TextStyle(fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      teacher['fieldOfStudy'] ?? '',
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
            ),
          ),
      backgroundColor: Color(0xFFEEEEEE),
    );
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
}
