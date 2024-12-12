import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/BlogCard.dart'; // Blog kartı widget'ımız
import 'package:ozel_ders/Components/Drawer.dart';
import 'package:ozel_ders/services/FirebaseController.dart';

class BlogsPage extends StatefulWidget {
  @override
  _BlogsPageState createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirestoreService _firestore = FirestoreService();
  List<Map<String, dynamic>> blogsHolder = [];
  List<Map<String, dynamic>> blogs = [];
  bool isLoading = true;
  bool isLoggedIn = false;

  String searchText = '';
  String sortBy = 'date_desc'; // 'date_asc', 'title_asc', 'title_desc' olabilir

  int currentPage = 1;
  final int blogsPerPage = 20;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    isLoggedIn = await AuthService().isUserSignedIn();
    await loadInitialData();
    setState(() {});
  }

  Future<void> loadInitialData() async {
    blogsHolder = await _firestore.getAllBlogs20Times();
    filterBlogs();
  }

  void filterBlogs() {
    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> filteredBlogs = blogsHolder;

    // Arama uygulama
    if (searchText.isNotEmpty) {
      filteredBlogs = filteredBlogs.where((blog) {
        return blog['title']
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase());
      }).toList();
    }

    // Sıralama uygulama
    if (sortBy == 'date_desc') {
      filteredBlogs.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
    } else if (sortBy == 'date_asc') {
      filteredBlogs.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
    } else if (sortBy == 'title_asc') {
      filteredBlogs.sort(
              (a, b) => a['title'].toString().compareTo(b['title'].toString()));
    } else if (sortBy == 'title_desc') {
      filteredBlogs.sort(
              (a, b) => b['title'].toString().compareTo(a['title'].toString()));
    }

    // Sayfalama
    int startIndex = (currentPage - 1) * blogsPerPage;
    int endIndex = startIndex + blogsPerPage;
    if (startIndex >= filteredBlogs.length) {
      blogs = [];
    } else {
      if (endIndex > filteredBlogs.length) {
        endIndex = filteredBlogs.length;
      }
      blogs = filteredBlogs.sublist(startIndex, endIndex);
    }

    setState(() {
      isLoading = false;
    });
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
                      title: Text('Tarihe Göre Azalan',
                          style: TextStyle(color: Color(0xFFEEEEEE))),
                      value: 'date_desc',
                      groupValue: sortBy,
                      onChanged: (String? value) {
                        setModalState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      activeColor: Color(0xFF76ABAE),
                      title: Text('Tarihe Göre Artan',
                          style: TextStyle(color: Color(0xFFEEEEEE))),
                      value: 'date_asc',
                      groupValue: sortBy,
                      onChanged: (String? value) {
                        setModalState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      activeColor: Color(0xFF76ABAE),
                      title: Text('Başlığa Göre A-Z',
                          style: TextStyle(color: Color(0xFFEEEEEE))),
                      value: 'title_asc',
                      groupValue: sortBy,
                      onChanged: (String? value) {
                        setModalState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      activeColor: Color(0xFF76ABAE),
                      title: Text('Başlığa Göre Z-A',
                          style: TextStyle(color: Color(0xFFEEEEEE))),
                      value: 'title_desc',
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
                        filterBlogs();
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
      labelStyle: TextStyle(color: Color(0xFF76ABAE)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF76ABAE)),
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
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/blogs');
            },
            child: Text('Blog',
                style: TextStyle(
                    color: Color(0xFF76ABAE),
                    fontWeight: FontWeight.bold)),
          ),
          isLoggedIn
              ? TextButton(
            onPressed: () {
              context.go(
                  '/appointments/' + AuthService().userUID());
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
              context
                  .go('/profile/' + AuthService().userUID());
            }
                : () {
              context.go('/login');
            },
            child: Text(
                isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol',
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: _inputDecoration('Ara'),
                        onChanged: (value) {
                          searchText = value;
                          filterBlogs();
                        },
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
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
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                      MediaQuery.of(context).size.width >= 800
                          ? 4
                          : 2,
                      crossAxisSpacing: isMobile ? 2 : 16,
                      mainAxisSpacing: isMobile ? 2 : 16,
                      childAspectRatio: MediaQuery.of(context).size.width >= 800
                          ? 1.75
                          : 0.85 ,
                    ),
                    itemCount: blogs.length,
                    itemBuilder: (context, index) {
                      final blog = blogs[index];
                      return BlogCard(
                        blog: blog,
                      );
                    },
                  ),
                ),
                // Sayfalama kontrolleri
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: currentPage > 1
                          ? () {
                        setState(() {
                          currentPage--;
                          filterBlogs();
                        });
                      }
                          : null,
                    ),
                    Text('Sayfa $currentPage'),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: (currentPage * blogsPerPage) <
                          blogsHolder.length
                          ? () {
                        setState(() {
                          currentPage++;
                          filterBlogs();
                        });
                      }
                          : null,
                    ),
                  ],
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
