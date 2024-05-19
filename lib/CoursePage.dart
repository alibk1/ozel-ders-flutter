import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/FirebaseController.dart';
import 'package:ozel_ders/services/BBB.dart';

class CoursePage extends StatefulWidget {
  final Map<String, dynamic> course;
  final Map<String, dynamic> teacher;

  CoursePage({required this.course, required this.teacher});

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  bool isDescExpanded = true;
  bool isTeacherExpanded = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _showDateTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = DateTime.now().add(Duration(days: 1));
        TimeOfDay selectedTime = TimeOfDay(hour: 9, minute: 0);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              height: 400,
              width: MediaQuery.of(context).size.width / 4 * 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Tarih Seç',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
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
                  SizedBox(height: 16),
                  Text(
                    'Saat Seç',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
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
                        }
                        else
                        {
                          setModalState(() {
                            pickedTime = TimeOfDay(hour: pickedTime!.hour, minute: 0);
                            selectedTime = pickedTime!;
                          });
                        }
                      }
                    },
                    child: Text('Saat Seç (${selectedTime.format(context)})'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      //TODO: RANDEVU OLUŞTURMA KODLARI
                      Navigator.pop(context);
                    },
                    child: Text('Randevu Al'),
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
        backgroundColor: Color(0xFF009899),
        title: Image.asset('assets/header.png', height: MediaQuery
            .of(context)
            .size
            .width < 600 ? 300 : 400),
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
            onPressed: () {}, // TODO: Ana Sayfa'ya git
            child: Text('Ana Sayfa', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories'); // CategoriesPage'e yönlendirme
            }, // TODO: Kategoriler sayfasına git
            child: Text('Kategoriler', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {}, // TODO: Kurslar sayfasına git
            child: Text('Kurslar', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {}, // TODO: Randevularım sayfasına git
            child: Text('Randevularım', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {},
            // TODO: Giriş Yap / Kaydol veya Profilim sayfasına git
            child: Text('Giriş Yap / Kaydol', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]
            : null,
      ),
      drawer: MediaQuery
          .of(context)
          .size
          .width < 600
          ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF009899),
              ),
              child: Image.asset('assets/header.png', height: 200),
            ),
            ListTile(
              title: Text('Ana Sayfa'),
              onTap: () {}, // TODO: Ana Sayfa'ya git
            ),
            ListTile(
              title: Text('Kategoriler'),
              onTap: () {}, // TODO: Kategoriler sayfasına git
            ),
            ListTile(
              title: Text('Kurslar'),
              onTap: () {}, // TODO: Kurslar sayfasına git
            ),
            ListTile(
              title: Text('Randevularım'),
              onTap: () {}, // TODO: Randevularım sayfasına git
            ),
            ListTile(
              title: Text('Giriş Yap / Kaydol'),
              onTap: () {}, // TODO: Giriş Yap / Kaydol veya Profilim sayfasına git
            ),
          ],
        ),
      )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(2.0),
              color: Color(0xFF009899),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16),
                  Text(
                    widget.course['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
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
                    items: widget.course['photos'].map<Widget>((photoUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Image.network(
                            photoUrl,
                            fit: BoxFit.fill,
                            scale: 0.6,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MediaQuery
                  .of(context)
                  .size
                  .width >= 600
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side
                  Expanded(
                    flex: 4,
                    child: Card(
                      color: Color(0xFF40E0D0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Kurs Açıklaması',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Divider(thickness: 2, color: Colors.white,),
                            SizedBox(height: 8),
                            Text(widget.course['desc'],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
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
                                  backgroundColor: Color(0xFF009899),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // İstediğiniz kenar yuvarlama miktarını belirleyebilirsiniz
                                    // Diğer shape özelliklerini de belirleyebilirsiniz
                                  ),
                                ),
                                onPressed: () {
                                  _showDateTimePicker(context);
                                },
                                child: Text('\n Bu Kursu Satın Al - ${widget
                                    .course['hourlyPrice']} TL \n',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: Color(0xFF663366),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: [
                                      CircleAvatar(
                                        foregroundColor: Colors.white,
                                        radius: 60,
                                        backgroundImage: NetworkImage(widget
                                            .teacher['profilePictureUrl']),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        widget.teacher['name'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(widget.teacher['fieldOfStudy'],
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white
                                        ),
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
                      backgroundColor: Color(0xFF009899),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10.0), // İstediğiniz kenar yuvarlama miktarını belirleyebilirsiniz
                        // Diğer shape özelliklerini de belirleyebilirsiniz
                      ),
                    ),
                    onPressed: () {
                      _showDateTimePicker(context);
                    },
                    child: Text('Bu Kursu Satın Al - ${widget
                        .course['hourlyPrice']} TL',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16),),
                  ),
                  SizedBox(height: 16),
                  Card(
                    color: Color(0xFF40E0D0),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        'Kurs Açıklaması',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold, color: Colors.white
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(widget.course['desc'], style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    color: Color(0xFF663366),
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      title: Text(
                        'Öğretmen Bilgileri',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(
                                    widget.teacher['profilePictureUrl']),
                              ),
                              SizedBox(height: 16),
                              Text(
                                widget.teacher['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(widget.teacher['fieldOfStudy'],style: TextStyle(color: Colors.white),),
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
