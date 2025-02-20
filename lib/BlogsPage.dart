import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/BlogCard.dart';
import 'package:ozel_ders/Components/Drawer.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

final Color _primaryColor = Color(0xFFA7D8DB);
final Color _backgroundColor = Color(0xFFEEEEEE);
final Color _darkColor = Color(0xFF3C72C2);

class BlogsPage extends StatefulWidget {
  @override
  _BlogsPageState createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isAppBarExpanded = true;

  FirestoreService _firestore = FirestoreService();
  List<Map<String, dynamic>> blogsHolder = [];
  List<Map<String, dynamic>> blogs = [];
  bool isLoading = true;
  bool isLoggedIn = false;

  String searchText = '';
  String sortBy = 'date_desc';
  int currentPage = 1;
  final int blogsPerPage = 10;

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

    if (searchText.isNotEmpty) {
      filteredBlogs = filteredBlogs.where((blog) {
        return blog['title']
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase());
      }).toList();
    }

    if (sortBy == 'date_desc') {
      filteredBlogs.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
    } else if (sortBy == 'date_asc') {
      filteredBlogs.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
    } else if (sortBy == 'title_asc') {
      filteredBlogs.sort((a, b) => a['title'].toString().compareTo(b['title'].toString()));
    } else if (sortBy == 'title_desc') {
      filteredBlogs.sort((a, b) => b['title'].toString().compareTo(a['title'].toString()));
    }

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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                decoration: BoxDecoration(
                  color: _darkColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [Color(0xFF3C72C2), Color(0xFF3C72C2)], // Gradyan renkleri
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                        color: _backgroundColor,
                      ),
                    ),
                    Divider(color: _backgroundColor),
                    SizedBox(height: 16),
                    RadioListTile<String>(
                      activeColor: _primaryColor,
                      title: Text('Tarihe Göre Azalan', style: TextStyle(color: _backgroundColor)),
                      value: 'date_desc',
                      groupValue: sortBy,
                      onChanged: (String? value) {
                        setModalState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      activeColor: _primaryColor,
                      title: Text('Tarihe Göre Artan', style: TextStyle(color: _backgroundColor)),
                      value: 'date_asc',
                      groupValue: sortBy,
                      onChanged: (String? value) {
                        setModalState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      activeColor: _primaryColor,
                      title: Text('Başlığa Göre A-Z', style: TextStyle(color: _backgroundColor)),
                      value: 'title_asc',
                      groupValue: sortBy,
                      onChanged: (String? value) {
                        setModalState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      activeColor: _primaryColor,
                      title: Text('Başlığa Göre Z-A', style: TextStyle(color: _backgroundColor)),
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
                      child: Text('Uygula',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                      ,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
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
      labelStyle: TextStyle(color: _primaryColor),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _darkColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Blog",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // İsteğe bağlı: kısa açıklama ekleyebilirsiniz
          SizedBox(height: 10),
          Text(
            "Bilgilendirici İçerikler Burada...",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      drawer: isMobile ? DrawerMenu(isLoggedIn: isLoggedIn) : null,
      body: Stack(
        children: [
          _buildMainContent(isMobile),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_backgroundColor, _primaryColor.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(isMobile),
            SliverToBoxAdapter(child: _buildHeaderSection()),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : screenWidth * 0.2, // Masaüstünde sağdan ve soldan boşluk
                vertical: 20,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Arama ve Filtreleme Butonları
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        TextField(
                          decoration: _inputDecoration('Ara'),
                          onChanged: (value) {
                            searchText = value;
                            filterBlogs();
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ActionButton(
                              icon: Icons.filter_list,
                              label: 'Filtrele',
                              onPressed: () {},
                            ),
                            _ActionButton(
                              icon: Icons.sort,
                              label: 'Sırala',
                              onPressed: () => _showSortModal(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Blog Listesi
                  ...blogs.map((blog) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: BlogCard(blog: blog),
                    );
                  }).toList(),
                  // Sayfalama Kontrolleri
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
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
                          onPressed: (currentPage * blogsPerPage) < blogsHolder.length
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
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isMobile) {
    return SliverAppBar(
      backgroundColor: Color(0xFFEEEEEE),
      title: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _isAppBarExpanded
            ? Image.asset(
          'assets/AYBUKOM1.png',
          height: isMobile ? 50 : 70,
          key: ValueKey('expanded-logo'),
        ).animate().fadeIn(duration: 500.ms)
            : Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/AYBUKOM1.png',
            height: isMobile ? 40 : 50,
            key: ValueKey('collapsed-logo'),
          ),
        ),
      ),
      centerTitle: isMobile || _isAppBarExpanded,
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final isExpanded = constraints.maxHeight > kToolbarHeight;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_isAppBarExpanded != isExpanded) {
              setState(() {
                _isAppBarExpanded = isExpanded;
              });
            }
          });
          return FlexibleSpaceBar(
            background: GlassmorphicContainer(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 0,
              blur: 30,
              border: 0,
              linearGradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [Colors.white24, Colors.white12],
              ),
            ),
          );
        },
      ),
      actions: isMobile ? null : [_buildDesktopMenu()],
      leading: isMobile
          ? IconButton(
        icon: Icon(Icons.menu, color: _darkColor),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      )
          : null,
    );
  }

  Widget _buildDesktopMenu() {
    return Row(
      children: [
        _HeaderButton(title: 'Ana Sayfa', route: '/'),
        _HeaderButton(title: 'Danışmanlıklar', route: '/courses'),
        _HeaderButton(title: 'İçerikler', route: '/contents'),
        if (isLoggedIn)
          _HeaderButton(
            title: 'Randevularım',
            route: '/appointments/${AuthService().userUID()}',
          ),
        _HeaderButton(
          title: isLoggedIn ? 'Profilim' : 'Giriş Yap',
          route: isLoggedIn ? '/profile/${AuthService().userUID()}' : '/login',
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: SpinKitFadingCircle(
          color: _primaryColor,
          size: 50,
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final String title;
  final String route;

  const _HeaderButton({required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go(route),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFF0344A3),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: _primaryColor,
            width: 2,
          ),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
