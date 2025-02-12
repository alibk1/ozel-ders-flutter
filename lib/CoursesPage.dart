import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/HomePage.dart';
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
  final Color _primaryColor = Color(0xFFA7D8DB);
  final Color _backgroundColor = Color(0xFFEEEEEE);
  final Color _darkColor = Color(0xFF3C72C2);
  bool _isAppBarExpanded = true;

  FirestoreService _firestore = FirestoreService();
  List<Map<String, dynamic>> coursesHolder = [];
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> blogs = [];
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  bool isLoggedIn = false;
  bool canGetEveryCourse = true;

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
    blogs = await _firestore.getAllBlogs();
    appointments = await _firestore.getAllAppointments();
    if (isLoggedIn) {
      String uid = await AuthService().userUID();
      bool isTeacher = teachers.firstWhere((t) => t["UID"] == uid, orElse: () => {}).isNotEmpty;
      if (!isTeacher) {
        var userInfo = await _firestore.getStudentByUID(uid);
        bool hasPersonal = userInfo["hasPersonalCheck"];
        canGetEveryCourse = hasPersonal;
      }
    }
    filterCourses();
  }

  void filterCourses() {
    setState(() {
      courses = coursesHolder;
      if (!canGetEveryCourse) {
        selectedCategory = "ORo10XNqzYkLcQUl420k";
        selectedSubCategory = "i4rsttkgwvY5NhP1uJTh";
      }
      List<Map<String, dynamic>> filteredCourses = courses.where((course) {
        return (selectedCategory == 'Seçilmedi' && course["status"] == 1 ||
            course['category'] == selectedCategory) &&
            (selectedSubCategory == 'Seçilmedi' && course["status"] == 1 ||
                course['subCategory'] == selectedSubCategory) &&
            (course['hourlyPrice'] >= minPrice && course['hourlyPrice'] <= maxPrice && course["status"] == 1);
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
            "Danışmanlıklar",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // İsteğe bağlı: kısa açıklama ekleyebilirsiniz
          SizedBox(height: 10),
          Text(
            "İhtiyacınız olan her şey burada...",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                decoration: BoxDecoration(
                  color: _darkColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Gradyan renkleri
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                          color: _backgroundColor,
                        ),
                      ),
                      Divider(color: _backgroundColor),
                      SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Kategori Seç',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _backgroundColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        dropdownColor: Color(0xFF393E46),
                        value: selectedCategory != 'Seçilmedi' ? selectedCategory : null,
                        decoration: _inputDecoration('Kategori Seç'),
                        hint: Text('Kategori Seç', style: TextStyle(color: _backgroundColor)),
                        iconEnabledColor: _backgroundColor,
                        onChanged: (String? newValue) {
                          setModalState(() {
                            selectedCategory = newValue ?? 'Seçilmedi';
                            selectedSubCategory = 'Seçilmedi';
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: 'Seçilmedi',
                            child: Text('Seçilmedi', style: TextStyle(color: _backgroundColor)),
                          ),
                          ...categories.map<DropdownMenuItem<String>>((category) {
                            return DropdownMenuItem<String>(
                              value: category['uid'],
                              child: Text(category['name'], style: TextStyle(color: _backgroundColor)),
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
                              color: _backgroundColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          dropdownColor: Color(0xFF393E46),
                          value: selectedSubCategory != 'Seçilmedi' ? selectedSubCategory : null,
                          decoration: _inputDecoration('Alt Kategori Seç'),
                          hint: Text('Alt Kategori Seç', style: TextStyle(color: _backgroundColor)),
                          iconEnabledColor: _backgroundColor,
                          onChanged: (String? newValue) {
                            setModalState(() {
                              selectedSubCategory = newValue ?? 'Seçilmedi';
                            });
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: 'Seçilmedi',
                              child: Text('Seçilmedi', style: TextStyle(color: _backgroundColor)),
                            ),
                            ...categories.firstWhere((category) => category['uid'] == selectedCategory)['subCategories']
                                .map<DropdownMenuItem<String>>((subCategory) {
                              return DropdownMenuItem<String>(
                                value: subCategory['uid'],
                                child: Text(subCategory['name'], style: TextStyle(color: _backgroundColor)),
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
                            color: _backgroundColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      RangeSlider(
                        activeColor: _primaryColor,
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
                        child: Text('Uygula',
                          style: TextStyle(fontWeight: FontWeight.bold),

                        ),
                        style: ElevatedButton.styleFrom(

                          backgroundColor: _primaryColor,
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
                    colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Gradyan renkleri
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
                      title: Text('Varsayılan', style: TextStyle(color: _backgroundColor)),
                      value: 'none',
                      groupValue: sortBy,
                      onChanged: (String? value) {
                        setModalState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      activeColor: _primaryColor,
                      title: Text('Fiyata Göre Artan', style: TextStyle(color: _backgroundColor)),
                      value: 'price_asc',
                      groupValue: sortBy,
                      onChanged: (String? value) {
                        setModalState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      activeColor: _primaryColor,
                      title: Text('Fiyata Göre Azalan', style: TextStyle(color: _backgroundColor)),
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
                      child: Text('Uygula',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
      labelStyle: TextStyle(color: _backgroundColor),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _backgroundColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primaryColor),
        borderRadius: BorderRadius.circular(8),
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
                horizontal: isMobile ? 20 : screenWidth * 0.2, // Ekran genişliğinin 3/5'i
                vertical: 20,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Filtreleme ve Sıralama Butonları
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ActionButton(
                          icon: Icons.filter_list,
                          label: 'Filtrele',
                          onPressed: () => _showFilterModal(context),
                        ),
                        ActionButton(
                          icon: Icons.sort,
                          label: 'Sırala',
                          onPressed: () => _showSortModal(context),
                        ),
                      ],
                    ),
                  ),
                  // Kurs Listesi
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 2 : 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isMobile ? 0.65 : 0.65,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return CourseCard(
                        course: course,
                        author: teachers.firstWhere(
                              (element) => element["UID"] == course["author"],
                        ),
                      );
                    },
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
      backgroundColor: Colors.transparent,
      title: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _isAppBarExpanded
            ? Image.asset(
          'assets/vitament1.png',
          height: isMobile ? 50 : 70,
          key: ValueKey('expanded-logo'),
        ).animate().fadeIn(duration: 500.ms)
            : Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/vitament1.png',
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
        HeaderButton(title: 'Ana Sayfa', route: '/'),
        HeaderButton(title: 'Danışmanlıklar', route: '/courses'),
        HeaderButton(title: 'Blog', route: '/blogs'),
        if (isLoggedIn)
          HeaderButton(
            title: 'Randevularım',
            route: '/appointments/${AuthService().userUID()}',
          ),
        HeaderButton(
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

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3C72C2),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 5,
      )
    ).animate().fadeIn(duration: 300.ms).scale();
  }
}
