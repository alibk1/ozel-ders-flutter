import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/FirebaseController.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirestoreService _firestore = FirestoreService();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> subCategories = [];
  bool isLoading = true;
  bool showSubCategories = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  Future<void> getCategories() async {
    // Kategorileri Firestore'dan alıyoruz (getCategories metodunu burada çağırın)
    // Bu örnekte getCategories metodunun geriye List<Map<String, dynamic>> döndüğünü varsayıyorum
    categories = await _firestore.getCategories();
    setState(() {
      isLoading = false;
      showSubCategories = false;
    });
  }


  void onCategoryTap(Map<String, dynamic> category) async {
    // Alt kategorileri Firestore'dan alıyoruz (getSubCategories metodunu burada çağırın)
    // Bu örnekte getSubCategories metodunun geriye List<Map<String, dynamic>> döndüğünü varsayıyorum
    subCategories = category['subCategories'];
    setState(() {
      showSubCategories = true;
    });
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
            onPressed: ()
            {
              context.go('/'); // CategoriesPage'e yönlendirme
            },             child: Text('Ana Sayfa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: ()
            {
              context.go('/categories'); // CategoriesPage'e yönlendirme
            },
            child: Text('Kategoriler', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: ()
            {
              context.go('/courses'); // CategoriesPage'e yönlendirme
            },
            child: Text('Kurslar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {}, //
            child: Text('Randevularım', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: isLoggedIn ? () {} : () {}, // TODO: Giriş Yap / Kaydol veya Profilim sayfasına git
            child: Text(isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              title: Text(isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol'),
              onTap: isLoggedIn
                  ? () {}
                  : () {}, // TODO: Giriş Yap / Kaydol veya Profilim sayfasına git
            ),
          ],
        ),
      )
          : null, body: isLoading
        ? Center(child: CircularProgressIndicator())
        : Center(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 750),
                child: showSubCategories
                    ? buildSubCategoriesGrid()
                    : buildCategoriesGrid(),
              ),
            ),
          ),
          FooterSection(),
        ],
      ),
    ),
    );
  }

  Widget buildCategoriesGrid() {
    return GridView.builder(
      key: ValueKey('categoriesGrid'),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 1,
        crossAxisSpacing: 50,
        mainAxisSpacing: 50,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () => onCategoryTap(category),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF009899),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    category['name'],
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSubCategoriesGrid() {
    return GridView.builder(
      key: ValueKey('subCategoriesGrid'),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 1,
        crossAxisSpacing: 50,
        mainAxisSpacing: 50,
        childAspectRatio: 1.5,
      ),
      itemCount: subCategories.length,
      itemBuilder: (context, index) {
        final subCategory = subCategories[index];
        return GestureDetector(
          onTap: () {
            // TODO: Alt kategoriye tıklanınca yapılacaklar
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF009899),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    subCategory['name'],
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
