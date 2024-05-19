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

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    categories = await _firestore.getCategories();
    courses = await _firestore.getAllCourses();
    teachers = await _firestore.getAllTeachers();
    filterCourses();
  }

  void filterCourses() {
    if (widget.category.isEmpty && widget.subCategory.isEmpty) {
      // Tüm kursları göster
      setState(() {
        isLoading = false;
      });
    } else {
      // Kategorilere göre filtreleme yap
      List<Map<String, dynamic>> filteredCourses = [];
      for (var course in courses) {
        if ((course['category'] == widget.category || widget.category.isEmpty) &&
            (course['subCategory'] == widget.subCategory || widget.subCategory.isEmpty)) {
          filteredCourses.add(course);
        }
      }
      setState(() {
        courses = filteredCourses;
        isLoading = false;
      });
    }
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
                    // TODO: Filtreleme butonu tıklama işlemi
                  },
                  child: Text('Filtreleme'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Sıralama butonu tıklama işlemi
                  },
                  child: Text('Sıralama'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return CourseCard(
                  course: course,
                  authorName: teachers.firstWhere((element) => element["UID"] == course["author"])["name"],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}