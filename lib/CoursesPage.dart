import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
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
    selectedCategory = widget.category.isEmpty ? 'Seçilmedi' : widget.category;
    selectedSubCategory =
    widget.subCategory.isEmpty ? 'Seçilmedi' : widget.subCategory;
    initData();
  }

  Future<void> initData() async {
    isLoggedIn = await AuthService().isUserSignedIn();
    await loadInitialData();
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
      List<Map<String, dynamic>> filteredCourses = courses.where((course) {
        return (selectedCategory == 'Seçilmedi' ||
            course['category'] == selectedCategory) &&
            (selectedSubCategory == 'Seçilmedi' ||
                course['subCategory'] == selectedSubCategory) &&
            (course['hourlyPrice'] >= minPrice &&
                course['hourlyPrice'] <= maxPrice);
      }).toList();

      if (sortBy == 'price_asc') {
        filteredCourses.sort((a, b) => a['hourlyPrice'].compareTo(b['hourlyPrice']));
      } else if (sortBy == 'price_desc') {
        filteredCourses.sort((a, b) => b['hourlyPrice'].compareTo(a['hourlyPrice']));
      }

      courses = filteredCourses;
      isLoading = false;
    });
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Tam ekran yapmak için
      backgroundColor: Colors.transparent, // Arkaplanı saydam yapıyoruz
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8, // Yüksekliğini ayarlıyoruz
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              // Ekran boyutunu almak için MediaQuery kullanıyoruz
              final screenWidth = MediaQuery.of(context).size.width;
              final isMobile = screenWidth < 800;

              return Container(
                decoration: BoxDecoration(
                  color: Color(0xFF222831), // Arkaplan rengini ayarlıyoruz
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Filtreleme',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEEEEEE), // Metin rengini ayarlıyoruz
                        ),
                      ),
                      Divider(color: Color(0xFFEEEEEE)),
                      SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Kategori Seç',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEEEEEE),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        dropdownColor:
                        Color(0xFF393E46), // Dropdown arkaplan rengini ayarlıyoruz
                        value:
                        selectedCategory != 'Seçilmedi' ? selectedCategory : null,
                        decoration: _inputDecoration('Kategori Seç'),
                        hint: Text('Kategori Seç',
                            style: TextStyle(color: Color(0xFFEEEEEE))),
                        iconEnabledColor: Color(0xFFEEEEEE),
                        onChanged: (String? newValue) {
                          setModalState(() {
                            selectedCategory = newValue ?? 'Seçilmedi';
                            selectedSubCategory = 'Seçilmedi';
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: 'Seçilmedi',
                            child: Text('Seçilmedi',
                                style: TextStyle(color: Color(0xFFEEEEEE))),
                          ),
                          ...categories.map<DropdownMenuItem<String>>((category) {
                            return DropdownMenuItem<String>(
                              value: category['uid'],
                              child: Text(category['name'],
                                  style: TextStyle(color: Color(0xFFEEEEEE))),
                            );
                          }).toList(),
                        ],
                      ),
                      if (selectedCategory != 'Seçilmedi') ...[
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Alt Kategori Seç',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEEEEEE),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          dropdownColor: Color(0xFF393E46),
                          value: selectedSubCategory != 'Seçilmedi'
                              ? selectedSubCategory
                              : null,
                          decoration: _inputDecoration('Alt Kategori Seç'),
                          hint: Text('Alt Kategori Seç',
                              style: TextStyle(color: Color(0xFFEEEEEE))),
                          iconEnabledColor: Color(0xFFEEEEEE),
                          onChanged: (String? newValue) {
                            setModalState(() {
                              selectedSubCategory = newValue ?? 'Seçilmedi';
                            });
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: 'Seçilmedi',
                              child: Text('Seçilmedi',
                                  style: TextStyle(color: Color(0xFFEEEEEE))),
                            ),
                            ...categories
                                .firstWhere(
                                    (category) => category['uid'] == selectedCategory)[
                            'subCategories']
                                .map<DropdownMenuItem<String>>((subCategory) {
                              return DropdownMenuItem<String>(
                                value: subCategory['uid'],
                                child: Text(subCategory['name'],
                                    style: TextStyle(color: Color(0xFFEEEEEE))),
                              );
                            }).toList(),
                          ],
                        ),
                      ],
                      SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Fiyat Aralığı',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEEEEEE),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      RangeSlider(
                        activeColor: Color(0xFF76ABAE),
                        inactiveColor: Color(0xFF393E46),
                        values: RangeValues(minPrice, maxPrice),
                        min: 0,
                        max: 1000,
                        divisions: 100,
                        labels: RangeLabels(
                          '${minPrice.round()} TL',
                          '${maxPrice.round()} TL',
                        ),
                        onChanged: (RangeValues values) {
                          setModalState(() {
                            minPrice = values.start;
                            maxPrice = values.end;
                          });
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          filterCourses();
                          Navigator.pop(context);
                        },
                        child: Text('Uygula'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF76ABAE),
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Tam ekran yapmak için
      backgroundColor: Colors.transparent, // Arkaplanı saydam yapıyoruz
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.5, // Yüksekliğini ayarlıyoruz
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                decoration: BoxDecoration(
                  color: Color(0xFF222831), // Arkaplan rengini ayarlıyoruz
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sıralama',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEEEEEE), // Metin rengini ayarlıyoruz
                      ),
                    ),
                    Divider(color: Color(0xFFEEEEEE)),
                    SizedBox(height: 16),
                    RadioListTile<String>(
                      activeColor: Color(0xFF76ABAE),
                      title: Text('Varsayılan',
                          style: TextStyle(color: Color(0xFFEEEEEE))),
                      value: 'none',
                      groupValue: sortBy,
                      onChanged: (String? value) {
                        setModalState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      activeColor: Color(0xFF76ABAE),
                      title: Text('Fiyata Göre Artan',
                          style: TextStyle(color: Color(0xFFEEEEEE))),
                      value: 'price_asc',
                      groupValue: sortBy,
                      onChanged: (String? value) {
                        setModalState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      activeColor: Color(0xFF76ABAE),
                      title: Text('Fiyata Göre Azalan',
                          style: TextStyle(color: Color(0xFFEEEEEE))),
                      value: 'price_desc',
                      groupValue: sortBy,
                      onChanged: (String? value) {
                        setModalState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        filterCourses();
                        Navigator.pop(context);
                      },
                      child: Text('Uygula'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF76ABAE),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFFEEEEEE)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF76ABAE)),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF222831),
        title: Image.asset(
          'assets/vitament1.png',
          height: isMobile ? 60 : 80,
        ),
        centerTitle: isMobile,
        leading: isMobile
            ? IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        )
            : null,
        actions: !isMobile
            ? [
          TextButton(
            onPressed: () {
              context.go('/');
            },
            child: Text('Ana Sayfa',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories');
            },
            child: Text('Kategoriler',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/courses');
            },
            child: Text('Kurslar',
                style: TextStyle(
                    color: Color(0xFF76ABAE),
                    fontWeight: FontWeight.bold)),
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
          isLoggedIn
              ? TextButton(
            onPressed: () {
              context.go('/appointments/' + AuthService().userUID());
            },
            child: Text('Randevularım',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          )
              : SizedBox.shrink(),
          TextButton(
            onPressed: isLoggedIn
                ? () {
              context.go('/profile/' + AuthService().userUID());
            }
                : () {
              context.go('/login');
            },
            child: Text(isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]
            : null,
      ),
      drawer: isMobile ? DrawerMenu(isLoggedIn: isLoggedIn) : null,
      body: isLoading
          ? Center(
          child: LoadingAnimationWidget.dotsTriangle(
              color: Color(0xFF222831), size: 200))
          : Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/therapy-main.jpg",
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF222831),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Color(0xFF04151F),
                              width: 2,
                            ),
                          ),
                        ),
                        onPressed: () {
                          _showFilterModal(context);
                        },
                        icon: Icon(Icons.filter_list),
                        label: Text(
                          'Filtrele',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF222831),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Color(0xFF04151F),
                              width: 2,
                            ),
                          ),
                        ),
                        onPressed: () {
                          _showSortModal(context);
                        },
                        icon: Icon(Icons.sort),
                        label: Text(
                          'Sırala',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                      MediaQuery.of(context).size.width >= 800 ? 4 : 2,
                      crossAxisSpacing: isMobile ? 2 : 16,
                      mainAxisSpacing: isMobile ? 2 : 16,
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
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFEEEEEE),
    );
  }
}
