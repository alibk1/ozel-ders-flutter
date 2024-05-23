import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/FirebaseController.dart';
import 'Components/CourseCard.dart';
import 'Components/Drawer.dart';

class CoursesPage extends StatefulWidget {
  final String category;
  final String subCategory;

  CoursesPage({required this.category, required this.subCategory});

  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirestoreService _firestore = FirestoreService();
  List<Map<String, dynamic>> coursesHolder = [];
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> teachers = [];
  bool isLoading = true;
  bool isLoggedIn = false;

  String? selectedCategory;
  String? selectedSubCategory;
  String sortBy = 'none';
  double minPrice = 0;
  double maxPrice = 1000;

  @override
  void initState() {
    super.initState();
    selectedCategory =
    widget.category.isEmpty || widget.category == '' ? 'Seçilmedi' : widget
        .category;
    selectedSubCategory =
    widget.subCategory.isEmpty || widget.category == '' ? 'Seçilmedi' : widget
        .subCategory;
    initData();
  }

  Future<void> initData() async
  {
    isLoggedIn = await AuthService().isUserSignedIn();
    loadInitialData();
    setState(() {});
  }

  Future<void> loadInitialData() async {
    categories = await _firestore.getCategories();
    courses = await _firestore.getAllCourses();
    coursesHolder = courses;
    teachers = await _firestore.getAllTeachers();
    filterCourses();
  }

  void filterCourses() {
    setState(() {
      courses = coursesHolder;
      print(selectedCategory);
      List<Map<String, dynamic>> filteredCourses = courses.where((course) {
        return (selectedCategory == 'Seçilmedi' ||
            course['category'] == selectedCategory) &&
            (selectedSubCategory == 'Seçilmedi' ||
                course['subCategory'] == selectedSubCategory) &&
            (course['hourlyPrice'] >= minPrice &&
                course['hourlyPrice'] <= maxPrice);
      }).toList();

      if (sortBy == 'price_asc') {
        filteredCourses.sort((a, b) =>
            a['hourlyPrice'].compareTo(b['hourlyPrice']));
      } else if (sortBy == 'price_desc') {
        filteredCourses.sort((a, b) =>
            b['hourlyPrice'].compareTo(a['hourlyPrice']));
      }

      courses = filteredCourses;
      isLoading = false;
    });
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              height: 400,
              child: Column(
                children: [
                  Text(
                    'Filtreleme',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedCategory,
                    hint: Text('Kategori Seç'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                        selectedSubCategory = 'Seçilmedi';
                      });
                      setModalState(() {}); // Dropdown güncelleme
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: 'Seçilmedi',
                        child: Text('Seçilmedi'),
                      ),
                      ...categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category['uid'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                    ],
                  ),
                  if (selectedCategory != 'Seçilmedi')
                    DropdownButton<String>(
                      value: selectedSubCategory,
                      hint: Text('Alt Kategori Seç'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubCategory = newValue!;
                        });
                        setModalState(() {}); // Dropdown güncelleme
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: 'Seçilmedi',
                          child: Text('Seçilmedi'),
                        ),
                        ...categories
                            .firstWhere((category) =>
                        category['uid'] == selectedCategory)['subCategories']
                            .map<DropdownMenuItem<String>>((subCategory) {
                          return DropdownMenuItem<String>(
                            value: subCategory['uid'],
                            child: Text(subCategory['name']),
                          );
                        }).toList(),
                      ],
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Fiyat Aralığı',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  RangeSlider(
                    values: RangeValues(minPrice, maxPrice),
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      '${minPrice.round()} TL',
                      '${maxPrice.round()} TL',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        minPrice = values.start;
                        maxPrice = values.end;
                      });
                      setModalState(() {}); // Slider güncelleme
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      filterCourses();
                      Navigator.pop(context);
                    },
                    child: Text('Uygula'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              height: 300,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Sıralama',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  RadioListTile<String>(
                    title: Text('Fiyata Göre Artan'),
                    value: 'price_asc',
                    groupValue: sortBy,
                    onChanged: (String? value) {
                      setModalState(() {
                        sortBy = value!;
                      });
                      setState(() {}); // Add this to update the UI
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Fiyata Göre Azalan'),
                    value: 'price_desc',
                    groupValue: sortBy,
                    onChanged: (String? value) {
                      setModalState(() {
                        sortBy = value!;
                      });
                      setState(() {}); // Add this to update the UI
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      filterCourses();
                      Navigator.pop(context);
                    },
                    child: Text('Uygula'),
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
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF183A37),
        title: Image.asset('assets/header.png', height: MediaQuery
            .of(context)
            .size
            .width < 600 ? 250 : 300),
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
            _scaffoldKey.currentState!.openDrawer();
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
            child: Text('Ana Sayfa', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories'); // CategoriesPage'e yönlendirme
            },
            child: Text('Kategoriler', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/courses'); // CategoriesPage'e yönlendirme
            },
            child: Text('Kurslar', style: TextStyle(
                color: Color(0xFFC44900), fontWeight: FontWeight.bold)),
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
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]
            : null,
      ),
      drawer: MediaQuery
          .of(context)
          .size
          .width < 600
          ? DrawerMenu(isLoggedIn: isLoggedIn)
          : null,
      body: isLoading
          ? Center(child: LoadingAnimationWidget.dotsTriangle(
          color: Color(0xFF183A37), size: 200))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5), // Yuvarlak köşe
                        topRight: Radius.circular(5), // Yuvarlak köşe
                        bottomLeft: Radius.circular(5), // Sivri köşe
                        bottomRight: Radius.circular(5),
                      ),
                      side: BorderSide(
                        width: 2,
                        color: Color(int.parse(
                            "#04151F".substring(1, 7), radix: 16) + 0xFF000000),
                      ),
                    ),
                    backgroundColor: Color(0xFF183A37),
                  ),
                  onPressed: () {
                    _showFilterModal(context);
                  },
                  child: Text(
                    'Filtreleme', style: TextStyle(color: Color(0xFFEFD6AC), fontSize: 20),),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5), // Yuvarlak köşe
                        topRight: Radius.circular(5), // Yuvarlak köşe
                        bottomLeft: Radius.circular(5), // Sivri köşe
                        bottomRight: Radius.circular(5),
                      ),
                      side: BorderSide(
                        width: 2,
                        color: Color(
                            int.parse("#04151F".substring(1, 7), radix: 16) +
                                0xFF000000),
                      ),
                    ),
                    backgroundColor: Color(0xFF183A37),
                  ),
                  onPressed: () {
                    _showSortModal(context);
                  },
                  child: Text('Sıralama', style: TextStyle(color: Color(0xFFEFD6AC), fontSize: 20),),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery
                    .of(context)
                    .size
                    .width >= 600 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return CourseCard(
                  course: course,
                  author: teachers.firstWhere((element) =>
                  element["UID"] == course["author"]),
                );
              },
            ),
          ),
          FooterSection()
        ],
      ),
      backgroundColor: Color(0xFFEFD6AC),
    );
  }
}

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Color(0xFF183A37),
      child: Center(
        child: Row(
          children: [
            Image.network('https://cdn-icons-png.flaticon.com/512/992/992257.png', height: 200),
            SizedBox(width: 20,),
            Text("Kategoriler", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),)
          ],
        ),
      ),
    );
  }
}
