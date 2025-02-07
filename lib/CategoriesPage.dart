import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:ozel_ders/services/PaymentService.dart';

import 'Components/Drawer.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirestoreService _firestore = FirestoreService();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> subCategories = [];
  String selectedCategory = "";
  String selectedCategoryImage = "";
  bool isLoading = true;
  bool showSubCategories = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async
  {
    isLoggedIn = await AuthService().isUserSignedIn();

    getCategories();
    setState(() {});
  }

  Future<void> getCategories() async {
    categories = await _firestore.getCategories();
    setState(() {
      isLoading = false;
      showSubCategories = false;
    });
  }


  void onCategoryTap(Map<String, dynamic> category) async {
    // Alt kategorileri Firestore'dan alıyoruz (getSubCategories metodunu burada çağırın)
    // Bu örnekte getSubCategories metodunun geriye List<Map<String, dynamic>> döndüğünü varsayıyorum
    selectedCategory = category['uid'];
    selectedCategoryImage = category["imageUrl"];
    subCategories = category['subCategories'];
    setState(() {
      showSubCategories = true;
    });
  }

  void onCategoryBackTap() {
    selectedCategory = "";
    setState(() {
      showSubCategories = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF222831),
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
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
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
            child: Text('Ana Sayfa', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories'); // CategoriesPage'e yönlendirme
            },
            child: Text('Kategoriler', style: TextStyle(
                color: Color(0xFF76ABAE), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/courses'); // CategoriesPage'e yönlendirme
            },
            child: Text('Terapiler', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
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
                style: TextStyle(
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
          ? Center(child: Column(
        children: [
          HeaderSection(),
          LoadingAnimationWidget.dotsTriangle(
              color: Color(0xFF222831), size: 200),
        ],
      )
      )
          : SafeArea(
            child: Center(
              child: Column(
                children: [
                  HeaderSection(),
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
          ),
      backgroundColor: Color(0xFFEEEEEE),
    );
  }


  Widget buildCategoriesGrid() {
    return GridView.builder(
      key: ValueKey('categoriesGrid'),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery
            .of(context)
            .size
            .width >= 800 ? 4 : 2,
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
              color: Color(0xFF222831),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: Image.network(category["imageUrl"], // Buraya arkaplan resmini ekle
                        fit: BoxFit.cover,
                        colorBlendMode: BlendMode.darken,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            category['name'],
                            style: TextStyle(fontSize: MediaQuery
                                .of(context)
                                .size
                                .width < 800 ? 20 : 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            ),
          ),
        );
      },
    );
  }

  Widget buildSubCategoriesGrid() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: onCategoryBackTap, child: Icon(Icons.arrow_circle_left_outlined, color: Color(0xFF222831),size: 50,)),
          ],
        ),
        SizedBox(height: 10,),
        Expanded(
          child: GridView.builder(
            key: ValueKey('subCategoriesGrid'),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery
                  .of(context)
                  .size
                  .width >= 800 ? 4 : 2,
              crossAxisSpacing: 50,
              mainAxisSpacing: 50,
              childAspectRatio: 1.5,
            ),
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final subCategory = subCategories[index];
              return GestureDetector(
                onTap: () {
                  context.go(
                      '/courses/' + selectedCategory + '/' + subCategory["uid"]);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF222831),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            child: Image.network(selectedCategoryImage, // Buraya arkaplan resmini ekle
                              fit: BoxFit.cover,
                              colorBlendMode: BlendMode.overlay,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  subCategory['name'],
                                  style: TextStyle(fontSize: MediaQuery
                                      .of(context)
                                      .size
                                      .width < 800 ? 15 : 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class HeaderSection extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF222831),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 55,),
            Text("Kategoriler", style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20),),
          ],
        ),
      ),
    );
  }
}
