import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/FirebaseController.dart';
import 'package:ozel_ders/services/BBB.dart';

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
  int _currentPage = 0;

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
    setState(() {
      isLoading = false; // Yüklenme işlemi tamamlandığında false yapıyoruz
    });
  }

  void _showDateTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
        TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 400,
              width: MediaQuery.of(context).size.width / 4 * 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Tarih Seç',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        initialEntryMode: DatePickerEntryMode.calendarOnly,
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 1),
                        selectableDayPredicate: (DateTime date) {
                          return date.weekday != DateTime.saturday && date.weekday != DateTime.sunday;
                        },
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setModalState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text('Tarih Seç (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Saat Seç',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          );
                        },
                      );
                      if (pickedTime != null && pickedTime != selectedTime) {
                        if (pickedTime.minute == 0) {
                          setModalState(() {
                            selectedTime = pickedTime!;
                          });
                        } else {
                          setModalState(() {
                            pickedTime = TimeOfDay(hour: pickedTime!.hour, minute: 0);
                            selectedTime = pickedTime!;
                          });
                        }
                      }
                    },
                    child: Text('Saat Seç (${selectedTime.format(context)})'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // selectedDate ve selectedTime birleştirilmesi
                      final DateTime selectedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      // TODO: RANDEVU OLUŞTURMA KODLARI randevu datayı oluştur teacher ve user id leri burda kullan
                      User? user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        teacher = await FirestoreService().getTeacherByUID(course["author"]);

                        await FirestoreService().createAppointment(
                          course["author"],
                          user.uid,
                          course["uid"],
                          "https://www.google.com",
                          selectedDateTime, // selectedDate yerine selectedDateTime kullanılıyor
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lütfen Giriş Yapınız.')),
                        );
                      }

                      Navigator.pop(context);
                    },
                    child: const Text('Randevu Al'),
                  ),
                ],
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF009899),
        title: Image.asset('assets/header.png', height: MediaQuery.of(context).size.width < 600 ? 250 : 300),
        centerTitle: MediaQuery.of(context).size.width < 600 ? true : false,
        leading: MediaQuery.of(context).size.width < 600
            ? IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
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
            child: const Text('Ana Sayfa', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories'); // CategoriesPage'e yönlendirme
            },
            child: const Text('Kategoriler', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/courses'); // CategoriesPage'e yönlendirme
            },
            child: const Text('Kurslar', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          isLoggedIn ? TextButton(
            onPressed: () {}, //
            child: const Text('Randevularım', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ) : const SizedBox.shrink(),
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
      drawer: MediaQuery.of(context).size.width < 600
          ? DrawerMenu(isLoggedIn: isLoggedIn)
          : null,
      body: isLoading
          ? Center(child: LoadingAnimationWidget.dotsTriangle(color: const Color(0xFF009899), size: 200))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(2.0),
              color: const Color(0xFF009899),
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
                  CarouselSlider(
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MediaQuery.of(context).size.width >= 600
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side
                  Expanded(
                    flex: 4,
                    child: Card(
                      color: const Color(0xFF40E0D0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Kurs Açıklaması',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(thickness: 2, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              course['desc'] ?? '',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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
                                  backgroundColor: const Color(0xFF009899),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0), // İstediğiniz kenar yuvarlama miktarını belirleyebilirsiniz
                                    // Diğer shape özelliklerini de belirleyebilirsiniz
                                  ),
                                ),
                                onPressed: () {
                                  _showDateTimePicker(context);
                                },
                                child: Text(
                                  '\n Bu Kursu Satın Al - ${course['hourlyPrice']} TL \n',
                                  style: const TextStyle(color: Colors.white, fontSize: 20),
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
                                color: const Color(0xFF663366),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        foregroundColor: Colors.white,
                                        radius: 60,
                                        backgroundImage: NetworkImage(teacher['profilePictureUrl'] ?? ''),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        teacher['name'] ?? '',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        teacher['fieldOfStudy'] ?? '',
                                        style: const TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
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
                      backgroundColor: const Color(0xFF009899),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // İstediğiniz kenar yuvarlama miktarını belirleyebilirsiniz
                        // Diğer shape özelliklerini de belirleyebilirsiniz
                      ),
                    ),
                    onPressed: () {
                      _showDateTimePicker(context);
                    },
                    child: Text(
                      'Bu Kursu Satın Al - ${course['hourlyPrice']} TL',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: const Color(0xFF40E0D0),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: const Text(
                        'Kurs Açıklaması',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
                    color: const Color(0xFF663366),
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      title: const Text(
                        'Öğretmen Bilgileri',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(teacher['profilePictureUrl'] ?? ''),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                teacher['name'] ?? '',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                teacher['fieldOfStudy'] ?? '',
                                style: const TextStyle(color: Colors.white),
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
          ],
        ),
      ),
    );
  }
}
