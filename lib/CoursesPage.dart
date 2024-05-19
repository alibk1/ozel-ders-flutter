import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/FirebaseController.dart';
import 'Components/CourseCard.dart';

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
    selectedSubCategory = widget.subCategory.isEmpty ? 'Seçilmedi' : widget.subCategory;
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    categories = await _firestore.getCategories();
    courses = await _firestore.getAllCourses();
    teachers = await _firestore.getAllTeachers();
    filterCourses();
  }

  void filterCourses() {
    setState(() {
      print(selectedCategory);
      List<Map<String, dynamic>> filteredCourses = courses.where((course) {
        return (selectedCategory == 'Seçilmedi' || course['category'] == selectedCategory) &&
            (selectedSubCategory == 'Seçilmedi' || course['subCategory'] == selectedSubCategory) &&
            (course['hourlyPrice'] >= minPrice && course['hourlyPrice'] <= maxPrice);
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
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // DropDown listelerinde hata oluşmaması için kontrol ekliyoruz
            final validCategories = categories.map((category) => category['UID']).toList();
            validCategories.add('Seçilmedi');
            if (selectedCategory != null && !validCategories.contains(selectedCategory)) {
              selectedCategory = 'Seçilmedi';
            }

            final validSubCategories = selectedCategory != 'Seçilmedi'
                ? categories
                .firstWhere((category) => category['UID'] == selectedCategory)['subCategories']
                .map((subCategory) => subCategory['UID'])
                .toList()
                : [];
            validSubCategories.add('Seçilmedi');
            if (selectedSubCategory != null && !validSubCategories.contains(selectedSubCategory)) {
              selectedSubCategory = 'Seçilmedi';
            }

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
                      setModalState(() {
                        selectedCategory = newValue!;
                        selectedSubCategory = 'Seçilmedi'; // Alt kategoriyi sıfırla
                      });
                      setState(() {}); // Add this to update the UI
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
                        setModalState(() {
                          selectedSubCategory = newValue!;
                        });
                        setState(() {}); // Add this to update the UI
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: 'Seçilmedi',
                          child: Text('Seçilmedi'),
                        ),
                        ...categories
                            .firstWhere((category) => category['uid'] == selectedCategory)['subCategories']
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
                      setModalState(() {
                        minPrice = values.start;
                        maxPrice = values.end;
                      });
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
              height: 200,
              child: Column(
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
        backgroundColor: Color(0xFF009899),
        title: Image.asset('assets/header.png', height: MediaQuery.of(context).size.width < 600 ? 300 : 400),
        centerTitle: MediaQuery.of(context).size.width < 600 ? true : false,
        leading: MediaQuery.of(context).size.width < 600
            ? IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        )
            : null,
        actions: MediaQuery.of(context).size.width >= 600
            ? [
          TextButton(
            onPressed: () {}, // TODO: Ana Sayfa'ya git
            child: Text('Ana Sayfa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories'); // CategoriesPage'e yönlendirme
            }, // TODO: Kategoriler sayfasına git
            child: Text('Kategoriler', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {}, // TODO: Kurslar sayfasına git
            child: Text('Kurslar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {}, // TODO: Randevularım sayfasına git
            child: Text('Randevularım', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: isLoggedIn ? () {} : () {}, // TODO: Giriş Yap / Kaydol veya Profilim sayfasına git
            child: Text(isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]
            : null,
      ),
      drawer: MediaQuery.of(context).size.width < 600
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
              title: Text(isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol'),
              onTap: isLoggedIn ? () {} : () {}, // TODO: Giriş Yap / Kaydol veya Profilim sayfasına git
            ),
          ],
        ),
      )
          : null,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showFilterModal(context);
                  },
                  child: Text('Filtreleme'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showSortModal(context);
                  },
                  child: Text('Sıralama'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return CourseCard(
                  course: course,
                  author: teachers.firstWhere((element) => element["UID"] == course["author"]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
