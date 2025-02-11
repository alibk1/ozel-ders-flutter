import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ozel_ders/Components/CourseCard.dart';
import 'package:ozel_ders/Components/TeacherCard.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'AppointmentsPage.dart';
import 'Components/Drawer.dart';
import 'Components/NotificationIconButton.dart';

class TeamProfilePage extends StatefulWidget {
  final String uid;

  TeamProfilePage({required this.uid});

  @override
  _TeamProfilePageState createState() => _TeamProfilePageState();
}

class _TeamProfilePageState extends State<TeamProfilePage> {
  bool isLoading = true;
  Map<String, dynamic> teamInfo = {};
  final Color _backgroundColor = const Color(0xFFEEEEEE);
  final Color _darkColor = const Color(0xFF3C72C2);
  final Color _headerTextColor = const Color(0xFF222831);
  final Color _bodyTextColor = const Color(0xFF393E46);
  final Color _primaryColor = const Color(0xFFA7D8DB);
  List<Map<String, dynamic>> notifications = [];

  bool isTeacher = false;
  Map<String, dynamic> userInfo = {};
  String teamUidIfCurrent = "";
  String teamNameIfCurrent = "";
  bool isLoggedIn = false;
  bool isSelf = false;
  bool isCurrentTeam = false;
  bool _isAppBarExpanded = true;

  List<Map<String, dynamic>> categories = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    initMenu();
    initData();
  }

  Future<void> initMenu() async {
    isLoggedIn = await AuthService().isUserSignedIn();
    if (isLoggedIn) {
      if (widget.uid == AuthService().userUID()) {
        isSelf = true;
      }
    }
    setState(() {});
  }

  Future<void> initData() async {
    teamInfo = await FirestoreService().getTeamByUID(widget.uid);
    print(teamInfo);
    categories = await FirestoreService().getCategories();

  // TODO :  BURAYI TAMAMLA EKSİK BURASI
    var teamCheck = await FirestoreService().getTeamByUID(widget.uid);
    print(teamCheck);
    if (teamCheck.isNotEmpty) {
      String uid = teamCheck["uid"];
      context.go("/team/$uid");
    }
    userInfo = await FirestoreService().getTeamByUID(widget.uid);
    if (userInfo.isNotEmpty) {
      isTeacher = true;
      notifications = await FirestoreService().getNotificationsForTeam(widget.uid);
    } else {
      userInfo = await FirestoreService().getTeamByUID(widget.uid);
      notifications = await FirestoreService().getNotificationsForTeam(widget.uid);
      isTeacher = false;
    }
    setState(() {
      isLoading = false;
    });


  }
/*
  old
  Future<void> _showChangePhotoDialog(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      // Yükleniyor animasyonu
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: LoadingAnimationWidget.twistingDots(
                leftDotColor: Color(0xFF222831),
                rightDotColor: Color(0xFF663366),
                size: 100),
          );
        },
      );

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_photos')
            .child(widget.uid)
            .child(fileName);

        final uploadTask = storageRef.putData(fileBytes);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await FirestoreService().changeTeamPhoto(widget.uid, downloadUrl);
        setState(() {
          teamInfo['profilePictureUrl'] = downloadUrl;
        });

        // Yükleniyor animasyonunu kapat
        Navigator.of(context).pop();
      } catch (e) {
        // Yükleniyor animasyonunu kapat
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil fotoğrafı yüklenirken hata oluştu')),
        );
      }
    }
  }

  Future<void> _showChangeDescDialog(BuildContext context) async {
    TextEditingController descController =
    TextEditingController(text: teamInfo['desc']);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Arka planı saydam yapıyoruz
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF222831), // Arka plan rengini ayarlıyoruz
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Wrap(
            children: [
              Text('Açıklamayı Değiştir',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 5,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Yeni Açıklama',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF393E46),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await FirestoreService()
                      .changeTeamDesc(widget.uid, descController.text);
                  setState(() {
                    teamInfo['desc'] = descController.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF76ABAE),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showChangeNameDialog(BuildContext context) async {
    TextEditingController nameController =
    TextEditingController(text: teamInfo['name']);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Arka planı saydam yapıyoruz
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF222831), // Arka plan rengini ayarlıyoruz
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Wrap(
            children: [
              Text('İsmi Değiştir',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Yeni İsim',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF393E46),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await FirestoreService()
                      .changeTeamName(widget.uid, nameController.text);
                  setState(() {
                    teamInfo['name'] = nameController.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF76ABAE),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLogOutDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Arka planı saydam yapıyoruz
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF222831), // Arka plan rengini ayarlıyoruz
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              Text('Çıkış Yapmak İstiyor Musunuz?',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  bool a = await AuthService().signOut();
                  if (a)
                    context.go("/login");
                  else
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Çıkış Yapılırken Hata Oluştu')),
                    );
                },
                child: Text('Evet, Çıkış Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _showCreateCourseDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    List<PlatformFile> photos = [];
    List<Map<String, dynamic>> subCategories = [];
    String? selectedCategory;
    String? selectedSubCategory;

    void updateSubCategories() {
      if (selectedCategory != null) {
        final category = categories.firstWhere(
                (category) => category['uid'] == selectedCategory);
        subCategories =
        List<Map<String, dynamic>>.from(category['subCategories']);
      } else {
        subCategories = [];
      }
      selectedSubCategory = null;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Arka planı saydam yapıyoruz
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Color(0xFF222831), // Arka plan rengini ayarlıyoruz
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Yeni Kurs Oluştur',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Kurs Adı',
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF393E46),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      maxLines: 5,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Kurs Açıklaması',
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF393E46),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      dropdownColor: Color(0xFF393E46),
                      value: selectedCategory,
                      hint: Text('Kategori Seç',
                          style: TextStyle(color: Colors.white70)),
                      iconEnabledColor: Colors.white70,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF393E46),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setModalState(() {
                          selectedCategory = newValue;
                          updateSubCategories();
                        });
                      },
                      items: categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category['uid'],
                          child: Text(category['name'],
                              style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 8),
                    if (selectedCategory != null)
                      DropdownButtonFormField<String>(
                        dropdownColor: Color(0xFF393E46),
                        value: selectedSubCategory,
                        hint: Text('Alt Kategori Seç',
                            style: TextStyle(color: Colors.white70)),
                        iconEnabledColor: Colors.white70,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF393E46),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (String? newValue) {
                          setModalState(() {
                            selectedSubCategory = newValue;
                          });
                        },
                        items: subCategories
                            .map<DropdownMenuItem<String>>((subCategory) {
                          return DropdownMenuItem<String>(
                            value: subCategory['uid'],
                            child: Text(subCategory['name'],
                                style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Saatlik Ücret',
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF393E46),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: true,
                        );

                        if (result != null) {
                          if (result.files.length > 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                  Text('En fazla 4 fotoğraf seçebilirsiniz')),
                            );
                          } else {
                            setModalState(() {
                              photos = result.files;
                            });
                          }
                        }
                      },
                      child: Text('Fotoğrafları Seç (${photos.length})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF76ABAE),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 8),
                    if (photos.isNotEmpty)
                      CarouselSlider(
                        options: CarouselOptions(
                          aspectRatio: 2.0,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                          scrollDirection: Axis.horizontal,
                        ),
                        items: photos.map((file) {
                          return Stack(
                            key: UniqueKey(),
                            children: [
                              Image.memory(
                                file.bytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              Positioned(
                                top: 8.0,
                                right: 8.0,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setModalState(() {
                                      photos.remove(file);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          if (nameController.text.isNotEmpty &&
                              descController.text.isNotEmpty &&
                              selectedCategory != null &&
                              selectedSubCategory != null &&
                              priceController.text.isNotEmpty &&
                              photos.isNotEmpty) {
                            // Yükleniyor animasyonu
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Center(
                                  child: LoadingAnimationWidget.twistingDots(
                                      leftDotColor: Color(0xFF222831),
                                      rightDotColor: Color(0xFF663366),
                                      size: 100),
                                );
                              },
                            );

                            final photoUrls = await Future.wait(
                                photos.map((photo) async {
                                  final storageRef = FirebaseStorage.instance
                                      .ref()
                                      .child('course_photos')
                                      .child(widget.uid)
                                      .child(photo.name);
                                  final uploadTask = storageRef.putData(photo.bytes!);
                                  final snapshot =
                                  await uploadTask.whenComplete(() => null);
                                  return await snapshot.ref.getDownloadURL();
                                }).toList());

                            await FirestoreService().createCourse(
                              nameController.text,
                              descController.text,
                              widget.uid,
                              selectedCategory!,
                              selectedSubCategory!,
                              double.parse(priceController.text),
                              photoUrls,
                            );

                            Navigator.pop(context); // Yükleniyor animasyonunu kapat
                            Navigator.pop(context); // Modal'ı kapat
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Kurs başarıyla oluşturuldu')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Lütfen tüm alanları doldurun ve en az bir fotoğraf seçin')),
                            );
                          }
                        } catch (e) {
                          Navigator.pop(context); // Yükleniyor animasyonunu kapat
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Kurs oluşturulurken bir hata oluştu')),
                          );
                        }
                      },
                      child: Text('Oluştur'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF76ABAE),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  */
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      // AppBar’da HomePage ve CoursesPage’deki gibi sade, şeffaf arka plan ve logo animasyonu
      drawer: isMobile ? DrawerMenu(isLoggedIn: isLoggedIn) : null,
      body: isLoading
          ? Center(
        child: LoadingAnimationWidget.dotsTriangle(
            color: _darkColor, size: 200),
      )
          : SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(isMobile),
            SliverToBoxAdapter(
              child: isMobile
                  ? _buildMobileProfile()
                  : _buildDesktopProfile(),
            ),
          ],
        ),
      ),
    );

  }
  SliverAppBar _buildSliverAppBar(bool isMobile) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      pinned: true,
      expandedHeight: 120,
      centerTitle: isMobile || _isAppBarExpanded,
      leading: isMobile
          ? IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState!.openDrawer(),
      )
          : null,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isAppBarExpanded
            ? Image.asset(
          'assets/vitament1.png',
          height: isMobile ? 50 : 70,
          key: const ValueKey('expanded-logo'),
        ).animate().fadeIn(duration: 500.ms)
            : Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/vitament1.png',
            height: isMobile ? 40 : 50,
            key: const ValueKey('collapsed-logo'),
          ),
        ),
      ),
      actions: isMobile ? null : [_buildDesktopMenuActions()],
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
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _backgroundColor,
                    _primaryColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildDesktopMenuActions() {
    return Row(
      children: [
        const HeaderButton(title: 'Ana Sayfa', route: '/'),
        const HeaderButton(title: 'Danışmanlıklar', route: '/courses'),
        const HeaderButton(title: 'Blog', route: '/blogs'),
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

  // ************************ Mobil Versiyon ************************

  Widget _buildMobileProfile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 16),
          _buildAboutSection(isExpanded: true),
          const SizedBox(height: 16),
          /*_buildCoursesSection(isExpanded: true),      bu olmayacak herhalde ama başka bişey olacak appointments olabilir
          const SizedBox(height: 16),
          _buildBlogsSection(isExpanded: true),
          const SizedBox(height: 16),*/
        ],
      ),
    );
  }
  Widget _buildDesktopProfile() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SOL SÜTUN: Profil Header + Hakkında
              Expanded( // 🔹 Expanded ile sol alan sabit
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 16),
                    _buildAboutSection(isExpanded: true),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // SAĞ SÜTUN: Danışmanlıklar (Kurslar) + Bloglar
              Expanded( // 🔹 Expanded ile sağ alan sabit
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //_buildCoursesSection(isExpanded: false),
                    SizedBox(height: 16),
                    _buildTeachersSection(isExpanded: false),
                    //TeacherCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  /*
  Widget _buildCoursesSection({required bool isExpanded}) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // 🔹 İçeriği hizala
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isTeacher ? 'Verdiği Danışmanlıklar' : 'Aldığı Danışmanlıklar',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _headerTextColor),
            ),
            if (isSelf || (isCurrentTeam && teamUidIfCurrent == userInfo["reference"]))
              IconButton(
                onPressed: () => _showCreateCourseDialog(context),
                icon: const Icon(Icons.add_circle, color: Colors.black),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Container( // 🔹 Genişliği zorunlu tutuyoruz
          width: double.infinity,
          child: CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 1.2,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              scrollDirection: Axis.horizontal, // 🔹 Dikeyden yataya çevirdik
            ),
            items: (userInfo['courses'] as List<dynamic>?)
                ?.map<Widget>((courseId) {
              return FutureBuilder<Map<String, dynamic>>(
                future: FirestoreService().getCourseByUID(courseId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Hata: ${snapshot.error}',
                        style: GoogleFonts.poppins(color: _bodyTextColor)));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text('Veri yok',
                        style: GoogleFonts.poppins(color: _bodyTextColor)));
                  } else {
                    final courseData = snapshot.data!;
                    return FutureBuilder<Map<String, dynamic>>(
                      future: FirestoreService().getTeacherByUID(courseData["author"]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Hata: ${snapshot.error}',
                              style: GoogleFonts.poppins(color: _bodyTextColor)));
                        } else if (!snapshot.hasData) {
                          return Center(child: Text('Veri yok',
                              style: GoogleFonts.poppins(color: _bodyTextColor)));
                        } else {
                          final authorData = snapshot.data!;
                          return Container(
                            width: double.infinity, // 🔹 Genişliği zorla
                            child: CourseCard(course: courseData, author: authorData),
                          );
                        }
                      },
                    );
                  }
                },
              );
            }).toList() ?? [],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);

    return isExpanded
        ? Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    )
        : content;
  }
*/
  // **************** Bloglar Bölümü ****************
/*
  Widget _buildBlogsSection({required bool isExpanded}) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // 🔹 İçeriği hizala
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Yazdığı Bloglar',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _headerTextColor),
            ),
            if (isSelf)
              IconButton(
                onPressed: () {
                  context.go("/blog-create/${userInfo["uid"]}");
                },
                icon: const Icon(Icons.add_circle, color: Colors.black),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Container( // 🔹 Genişliği zorunlu tutuyoruz
          width: double.infinity,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: isTeacher
                ? FirestoreService().getTeacherBlogs(widget.uid)
                : Future.value([]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return Text('Hata: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: _bodyTextColor));
              } else {
                final blogs = snapshot.data ?? [];
                if (blogs.isEmpty) {
                  return Text('Henüz blog yok.',
                      style: GoogleFonts.poppins(color: _bodyTextColor));
                } else {
                  return CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: 1.3,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                    ),
                    items: blogs.map((blog) {
                      return Container( // 🔹 Genişliği zorla
                        width: double.infinity,
                        child: Stack(
                          children: [
                            BlogCard(blog: blog),
                            if (isSelf)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.build_circle,
                                      color: Colors.black, size: 35),
                                  onPressed: () {
                                    context.go("/blog-update/${userInfo["uid"]}/${blog["uid"]}");
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              }
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);

    return isExpanded
        ? Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    )
        : content;
  }
*/

  /*
  bunun olmasına gerek yok
  void showAppointmentsBottomSheet(BuildContext context,) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // 08:00'den 20:00'ye kadar 50 dakikalık süreler oluştur
            final List<Map<String, String>> timeSlots = [];
            for (int hour = 8; hour < 20; hour++) {
              String startTime = '${hour.toString().padLeft(2, '0')}:00';
              String endTime = '${hour.toString().padLeft(2, '0')}:50';
              timeSlots.add({'start': startTime, 'end': endTime});
            }

            final List<DateTime> teacherAppDates = [];
            List<DateTime> availableHours = [];
            for(Timestamp a in userInfo["availableHours"])
            {
              availableHours.add(a.toDate());
            }
            for (var app in appointments) {
              Timestamp date = app["date"];
              DateTime dateTime = date.toDate().toUtc();
              print(dateTime);
              teacherAppDates.add(dateTime);
            }

            final Map<DateTime, List<Map<String, dynamic>>> eventsMap = {};
            for (var appointment in appointments) {
              final dateTime = (appointment['date'] as Timestamp).toDate();
              final dayOnly = DateTime(
                  dateTime.year, dateTime.month, dateTime.day);

              if (!eventsMap.containsKey(dayOnly)) {
                eventsMap[dayOnly] = [];
              }
              eventsMap[dayOnly]!.add(appointment);
            }

            DateTime _focusedDay = DateTime.now();
            DateTime? _selectedDay;
            bool selectedAvailable = false;
            // Seçilen saat
            DateTime? _selectedTime;

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState2) {
                return Padding(
                  padding: MediaQuery
                      .of(context)
                      .viewInsets,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Başlık
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: const Text(
                            'Randevu Takvimi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: ElevatedButton(
                            onPressed: () async
                            {
                              DateTime firstSelectedDate = DateTime.now().add(Duration(days: 1));
                              DateTime secondSelectedDate = DateTime.now().add(Duration(days: 2));
                              List<TimeOfDay> times = [];
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.noHeader,
                                animType: AnimType.bottomSlide,
                                title: 'Yeni Randevu Talebi',
                                desc: "",
                                // Body kısmında StatefulBuilder kullanarak dinamik içerik oluşturuyoruz
                                body: StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setModalState) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 10),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF76ABAE),
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(double.infinity, 50),
                                          ),
                                          onPressed: () async {
                                            final DateTime? picked = await showDatePicker(
                                              context: context,
                                              initialDate: secondSelectedDate,
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime.now().add(const Duration(days: 365)),
                                              locale: const Locale('tr', 'TR'), // Türkçe için
                                              builder: (context, child) => Theme(
                                                data: _customDatePickerTheme(), // Özel tema
                                                child: child!,
                                              ),
                                            );
                                            if (picked != null) {
                                              setModalState(() {
                                                firstSelectedDate = DateTime(picked.year, picked.month, picked.day, 8);
                                              });
                                            }
                                          },
                                          child: Text(
                                            'Başlangıç Tarihi Seç (${DateFormat('dd/MM/yyyy').format(firstSelectedDate)})',
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF76ABAE),
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(double.infinity, 50),
                                          ),
                                          onPressed: () async {
                                            final DateTime? picked = await showDatePicker(
                                              context: context,
                                              initialDate: secondSelectedDate,
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime.now().add(const Duration(days: 365)),
                                              locale: const Locale('tr', 'TR'), // Türkçe için
                                              builder: (context, child) => Theme(
                                                data: _customDatePickerTheme(), // Özel tema
                                                child: child!,
                                              ),
                                            );
                                            if (picked != null) {
                                              setModalState(() {
                                                secondSelectedDate = DateTime(picked.year, picked.month, picked.day, 8);
                                              });
                                            }
                                          },
                                          child: Text(
                                            'Bitiş Tarihi Seç (${DateFormat('dd/MM/yyyy').format(secondSelectedDate)})',
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          alignment: WrapAlignment.center,
                                          children: timeSlots.map((slot) {
                                            // Başlangıç saati
                                            final int slotStart =
                                            int.parse(slot["start"]!.split(":")[0]);

                                            final bool isSelected = times.contains(TimeOfDay(hour: slotStart, minute: 0));

                                            return GestureDetector(
                                              onTap: () {
                                                setModalState(() {
                                                  if(isSelected)
                                                  {
                                                    times.remove(TimeOfDay(hour: slotStart, minute: 0));
                                                  }
                                                  else{
                                                    times.add(TimeOfDay(hour: slotStart, minute: 0));
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 80,
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? const Color(
                                                      0xFF76ABAE)
                                                      : const Color(0xFF393E46),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: isSelected
                                                      ? Border.all(
                                                      color: Colors.white, width: 2)
                                                      : null,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${slot['start']} - ${slot['end']}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),

                                      ],
                                    );
                                  },
                                ),
                                btnOkText: "Seç",
                                btnCancelText: "İptal",
                                btnOkOnPress: () async {
                                  LoadingIndicator(context).showLoading();
                                  if(firstSelectedDate == secondSelectedDate)
                                  {
                                    for(TimeOfDay time in times)
                                    {
                                      DateTime newDate = DateTime(firstSelectedDate.year, firstSelectedDate.month, firstSelectedDate.day, time.hour, time.minute);
                                      await FirestoreService().updateTeacherAvailableHours(widget.uid, newDate);
                                    }
                                    setState2((){});
                                  }
                                  else if(firstSelectedDate.isBefore(secondSelectedDate))
                                  {
                                    DateTime first = firstSelectedDate;
                                    while(true){
                                      for(TimeOfDay time in times)
                                      {
                                        print("Girdi");
                                        DateTime newDate = DateTime(first.year, first.month, first.day, time.hour, time.minute);
                                        await FirestoreService().updateTeacherAvailableHours(widget.uid, newDate);
                                      }
                                      if(first == secondSelectedDate){
                                        break;
                                      }
                                      first = first.add(Duration(days: 1));
                                    }
                                    setState2((){});
                                  }
                                  else if(firstSelectedDate.isAfter(secondSelectedDate))
                                  {
                                    AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.error,
                                        animType: AnimType.bottomSlide,
                                        body: const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            'Hatalı veya Eksik Bilgi (Tarihleri Kontrol Ediniz)',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        dismissOnTouchOutside: false,
                                        dismissOnBackKeyPress: false,
                                        btnOkText: "Tamam",
                                        btnOkOnPress: () {}
                                    ).show();
                                  }
                                  await initData();
                                  print(firstSelectedDate);
                                  print(secondSelectedDate);
                                  Navigator.pop(context);

                                },
                                btnCancelOnPress: () {},
                              ).show();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF222831),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                                side: const BorderSide(color: Color(0xFFEEEEEE), width: 2),
                              ),
                            ),
                            child: const Text('Çoklu Müsaitlik Ayarlama', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        TableCalendar(
                          locale: 'tr_TR',
                          focusedDay: _focusedDay,
                          firstDay: DateTime.now().add(Duration(days: -1)),
                          lastDay: DateTime.utc(2030, 12, 31),
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          eventLoader: (day) {
                            final dayOnly = DateTime(
                                day.year, day.month, day.day);
                            return eventsMap[dayOnly] ?? [];
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState2(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                              _selectedTime = null;
                            });
                          },
                          calendarStyle: const CalendarStyle(
                            markerDecoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        if (_selectedDay != null) ...[
                          const SizedBox(height: 16),

                          // Seçilen Gün
                          Text(
                            'Seçilen Gün: '
                                '${_selectedDay!.day}.${_selectedDay!
                                .month}.${_selectedDay!.year}',
                            style: const TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 8),

                          // Saat Seçimi
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            alignment: WrapAlignment.center,
                            children: timeSlots.map((slot) {
                              // Başlangıç saati
                              final int slotStart =
                              int.parse(slot["start"]!.split(":")[0]);

                              // Seçili güne bu saati ekliyoruz
                              final DateTime slotDateTime = DateTime(
                                _selectedDay!.year,
                                _selectedDay!.month,
                                _selectedDay!.day,
                                slotStart,
                                0,
                              );

                              bool canReserve = true;
                              for (DateTime date in teacherAppDates) {
                                if (date.year == slotDateTime.toUtc().year &&
                                    date.month == slotDateTime.toUtc().month &&
                                    date.day == slotDateTime.toUtc().day &&
                                    date.hour == slotDateTime.toUtc().hour) {
                                  canReserve = false; // Bu saat dolu
                                  break;
                                }
                              }

                              bool hasAvailable = false;
                              for (DateTime date in availableHours) {
                                if (date.year == slotDateTime.year &&
                                    date.month == slotDateTime.month &&
                                    date.day == slotDateTime.day &&
                                    date.hour == slotDateTime.hour) {
                                  hasAvailable = true; // Bu saat dolu
                                  break;
                                }
                              }

                              // Seçilen saat mi?
                              final bool isSelected = _selectedTime != null &&
                                  _selectedTime!.year == slotDateTime.year &&
                                  _selectedTime!.month == slotDateTime.month &&
                                  _selectedTime!.day == slotDateTime.day &&
                                  _selectedTime!.hour == slotDateTime.hour;

                              return GestureDetector(
                                onTap: () {
                                  setState2(() {
                                    _selectedTime = slotDateTime;
                                    selectedAvailable = hasAvailable;
                                  });
                                },
                                child: Container(
                                  width: 80,
                                  // 4 slotun yan yana gelmesi için
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(
                                        0xFF76ABAE) // Seçilen slot rengi
                                        : !hasAvailable
                                        ? Colors.red // Boş slot
                                        : canReserve ? Colors.green : const Color(0xFF393E46), // Dolu slot
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? Border.all(
                                        color: Colors.white, width: 2)
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${slot['start']} - ${slot['end']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              // Henüz saat seçilmediyse (null) => buton da pasif kalsın
                              if (_selectedTime == null) {
                                return ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF76ABAE),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(120, 50),
                                  ),
                                  child: const Text("Saat Seçiniz"),
                                );
                              }

                              final existingAppointment = appointments
                                  .firstWhere((app) {
                                final dt = (app['date'] as Timestamp).toDate();
                                return dt.year == _selectedTime!.year &&
                                    dt.month == _selectedTime!.month &&
                                    dt.day == _selectedTime!.day &&
                                    dt.hour == _selectedTime!.hour;
                              }, orElse: () => {});
                              if (existingAppointment.isNotEmpty) {
                                return Container(
                                  height: 400,
                                  child: AppointmentCard(
                                    appointmentUID: existingAppointment["UID"],
                                    isTeacher: false,
                                  ),
                                );
                              } else {
                                return selectedAvailable ? ElevatedButton(
                                  onPressed: () async {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.noHeader,
                                      animType: AnimType.bottomSlide,
                                      title: 'Randevuya Ayırdığın Saati Sil',
                                      desc: 'Randevuya Ayırdığınız Saati Silmek İstiyor Musunuz?',
                                      body: StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setModalState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: 10),
                                              Text(
                                                'Randevuya Ayırdığınız Saati Silmek İstiyor Musunuz?',
                                                style: TextStyle(
                                                    fontSize: 16),
                                              ), SizedBox(height: 10),
                                            ],
                                          );
                                        },
                                      ),
                                      btnOkText: "Evet",
                                      btnCancelText: "Hayır",
                                      btnOkOnPress: () async {
                                        await FirestoreService()
                                            .removeTeacherAvailableHour(
                                            widget.uid,
                                            DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, _selectedTime!.hour, _selectedTime!.minute));
                                        userInfo = await FirestoreService().getTeacherByUID(widget.uid);
                                        setState((){});
                                        setState2((){});
                                      },
                                      btnCancelOnPress: () {},
                                    ).show();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF76ABAE),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(120, 50),
                                  ),
                                  child: const Text(
                                    "Randevuya Ayırdığın Saati İptal Et",
                                    style: TextStyle(color: Colors.red),),
                                ) :
                                ElevatedButton(
                                  onPressed: () async {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.noHeader,
                                      animType: AnimType.bottomSlide,
                                      title: 'Saati Randevuya Ayır',
                                      desc: 'Bu Saati Randevuya Ayırmak İstiyor Musunuz?',
                                      // Body kısmında StatefulBuilder kullanarak dinamik içerik oluşturuyoruz
                                      body: StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setModalState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: 10),
                                              Text(
                                                'Bu Saati Randevuya Ayırmak İstiyor Musunuz?',
                                                style: TextStyle(fontSize: 16),
                                              ), SizedBox(height: 10),
                                            ],
                                          );
                                        },
                                      ),
                                      // Dialog'un altındaki butonlar
                                      btnOkText: "Evet",
                                      btnCancelText: "Hayır",
                                      btnOkOnPress: () async {
                                        await FirestoreService()
                                            .updateTeacherAvailableHours(
                                            widget.uid,
                                            DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, _selectedTime!.hour, _selectedTime!.minute));
                                        userInfo = await FirestoreService().getTeacherByUID(widget.uid);
                                        setState((){});
                                        setState2((){});
                                      },
                                      btnCancelOnPress: () {},
                                    ).show();

                                    debugPrint("Yeni randevu ekleme işlemi");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF76ABAE),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(120, 50),
                                  ),
                                  child: const Text("Bu Saati Randevuya Ayır"),
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
*/
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [_primaryColor.withOpacity(0.6), _darkColor, _primaryColor.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: userInfo['profilePictureUrl'] != null
                ? NetworkImage(userInfo['profilePictureUrl'])
                : const AssetImage('assets/default_profile.png')
            as ImageProvider,
          ).animate().fadeIn(duration: 500.ms),
          if (isSelf)
            TextButton(
              onPressed: () => _showChangePhotoDialog(context),
              child: Text(
                "Profil Fotoğrafını Değiştir",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontStyle: FontStyle.italic),
              ),
            ),
          const SizedBox(height: 5),
          // İsim ve düzenleme / çıkış seçenekleri:
          isSelf
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: "İsmi Düzenle",
                onPressed: () => _showChangeNameDialog(context),
                icon: const Icon(Icons.edit_note, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Text(
                userInfo['name'] ?? '',
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _headerTextColor),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(width: 15),
              IconButton(
                tooltip: "Çıkış Yap",
                onPressed: () => _showLogOutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.red),
              ),
            ],
          )
              : (!isSelf && !isCurrentTeam
              ? Text(
            userInfo['name'] ?? '',
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _headerTextColor),
          ).animate().fadeIn(duration: 500.ms)
              : Column(
            children: [
              Text(
                userInfo['name'] ?? '',
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _headerTextColor),
              ).animate().fadeIn(duration: 500.ms),
              TextButton(
                onPressed: () => _showOurEmployeeDialog(context),
                child: Text(
                  "Bu Kişi Benim Ekibimden",
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.white),
                ),
              )
            ],
          )),
          const SizedBox(height: 10),
          if (isSelf)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NotificationIconButtonWithBadge(
                  userType: isTeacher ? UserType.teacher : UserType.student,
                  userUID: widget.uid,
                ),
                if (isTeacher)
                  IconButton(
                    onPressed: () => {},// showAppointmentsBottomSheet(context), düzelt düzelt düzelt
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                  ),
                const SizedBox(width: 4),
                Text(
                  isTeacher ? 'Eğitim Takımı' : 'Öğrenci',
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTeachersSection({required bool isExpanded}) {
    isTeacher=true;
    print("_buildTeachersSection");
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // 🔹 İçeriği hizala
      children: [
        Center(
          child: Text(
            'Kadro',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _headerTextColor),
          ),
        ),
        const SizedBox(height: 16),
        Container( // 🔹 Genişliği zorunlu tutuyoruz
          width: double.infinity,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: FirestoreService().getSelectedTeachers(widget.uid),
            builder: (context, snapshot) {
              print("future");
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()));
              }
              else if (snapshot.hasError) {
                return Text('Hata: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: _bodyTextColor));
              } else {
                final teachers = snapshot.data ?? [];
                print("teachers");
                print(teachers);

                if (teachers.isEmpty) {
                  return Text('Henüz eğitmen yok.',
                      style: GoogleFonts.poppins(color: _bodyTextColor));
                } else {
                  return CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: 1.3,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                    ),
                    items: teachers.map((teacher) {
                      Map<String, dynamic> teacherData = teacher['teacherData'];
                      print("teacherData");

                      print(teacherData);

                      List<Map<String, dynamic>>courses = teacher['courses'];
                      print("courses");

                      print(courses);
                      return Container( // 🔹 Genişliği zorla
                        width: double.infinity,
                        child: Stack(
                          children: [
                            TeacherCard(teacherData: teacherData, teacherCourses: courses),
                            if (isSelf)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.build_circle,
                                      color: Colors.black, size: 35),
                                  onPressed: () {
                                    //context.go("/blog-update/${userInfo["uid"]}/${blog["uid"]}");
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              }
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);

    return isExpanded
        ? Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    )
        : content;
  }

  // **************** Hakkında (About) Bölümü ****************

  Widget _buildAboutSection({required bool isExpanded}) {
    Widget content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        userInfo['desc'] ?? '',
        style: GoogleFonts.poppins(fontSize: 15, color: _bodyTextColor),
      ),
    );
    return isExpanded
        ? Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          'Hakkında',
          style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _headerTextColor),
        ),
        trailing: isSelf
            ? IconButton(
          tooltip: "Hakkında'yı Düzenle",
          onPressed: () => _showChangeDescDialog(context),
          icon: const Icon(Icons.edit_note, color: Colors.black),
        )
            : null,
        children: [content],
      ),
    )
        : Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: content,
    );
  }

  // **************** Diyalog ve Yardımcı Metotlar ****************
  Future<void> _showChangePhotoDialog(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: LoadingAnimationWidget.twistingDots(
                leftDotColor: _darkColor,
                rightDotColor: Colors.deepPurple,
                size: 100),
          );
        },
      );
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_photos')
            .child(widget.uid)
            .child(fileName);
        final uploadTask = storageRef.putData(fileBytes);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();
        await FirestoreService().changeUserPhoto(widget.uid, downloadUrl, isTeacher);
        setState(() {
          userInfo['profilePictureUrl'] = downloadUrl;
        });
        Navigator.of(context).pop();
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotoğrafı yüklenirken hata oluştu')),
        );
      }
    }
  }

  Future<void> _showChangeDescDialog(BuildContext context) async {
    TextEditingController descController = TextEditingController(text: userInfo['desc']);
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Açıklamayı Değiştir',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _headerTextColor)),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 5,
                style: GoogleFonts.poppins(color: _bodyTextColor),
                decoration: InputDecoration(
                  hintText: 'Yeni Açıklama',
                  hintStyle: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await FirestoreService().changeUserDesc(widget.uid, descController.text, isTeacher);
                  setState(() {
                    userInfo['desc'] = descController.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Kaydet', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showChangeNameDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController(text: userInfo['name']);
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('İsmi Değiştir',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _headerTextColor)),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                style: GoogleFonts.poppins(color: _bodyTextColor),
                decoration: InputDecoration(
                  hintText: 'Yeni İsim',
                  hintStyle: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await FirestoreService().changeUserName(widget.uid, nameController.text, isTeacher);
                  setState(() {
                    userInfo['name'] = nameController.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Kaydet', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLogOutDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              Text('Çıkış Yapmak İstiyor Musunuz?',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _headerTextColor)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  bool a = await AuthService().signOut();
                  if (a)
                    context.go("/login");
                  else
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Çıkış Yapılırken Hata Oluştu')),
                    );
                },
                child: Text('Evet, Çıkış Yap', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showOurEmployeeDialog(BuildContext context) async {
    String type = isTeacher ? "Eğitimci" : "Öğrenci";
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              Text('Bu $type Sizin Ekibinizden Mi?',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _headerTextColor)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (isTeacher) {
                    await FirestoreService().sendRFromTeamToTeacher(widget.uid, teamUidIfCurrent, teamNameIfCurrent);
                  } else {
                    await FirestoreService().sendRFromTeamToStudent(widget.uid, teamUidIfCurrent, teamNameIfCurrent);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Katılma isteği gönderildi')),
                  );
                },
                child: Text('Evet, Katılma İsteği Gönder', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCreateCourseDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    List<PlatformFile> photos = [];
    List<Map<String, dynamic>> subCategories = [];
    String? selectedCategory;
    String? selectedSubCategory;

    void updateSubCategories() {
      if (selectedCategory != null) {
        final category = categories.firstWhere((cat) => cat['uid'] == selectedCategory);
        subCategories = List<Map<String, dynamic>>.from(category['subCategories']);
      } else {
        subCategories = [];
      }
      selectedSubCategory = null;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Yeni Kurs Oluştur',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _headerTextColor)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.poppins(color: _bodyTextColor),
                      decoration: InputDecoration(
                        hintText: 'Kurs Adı',
                        hintStyle: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      maxLines: 5,
                      style: GoogleFonts.poppins(color: _bodyTextColor),
                      decoration: InputDecoration(
                        hintText: 'Kurs Açıklaması',
                        hintStyle: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      value: selectedCategory,
                      hint: Text('Kategori Seç', style: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7))),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setModalState(() {
                          selectedCategory = newValue;
                          updateSubCategories();
                        });
                      },
                      items: categories.map<DropdownMenuItem<String>>((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['uid'],
                          child: Text(cat['name'], style: GoogleFonts.poppins(color: _bodyTextColor)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    if (selectedCategory != null)
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: selectedSubCategory,
                        hint: Text('Alt Kategori Seç', style: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7))),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (String? newValue) {
                          setModalState(() {
                            selectedSubCategory = newValue;
                          });
                        },
                        items: subCategories.map<DropdownMenuItem<String>>((subCat) {
                          return DropdownMenuItem<String>(
                            value: subCat['uid'],
                            child: Text(subCat['name'], style: GoogleFonts.poppins(color: _bodyTextColor)),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(color: _bodyTextColor),
                      decoration: InputDecoration(
                        hintText: 'Saatlik Ücret',
                        hintStyle: GoogleFonts.poppins(color: _bodyTextColor.withOpacity(0.7)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: true,
                        );
                        if (result != null) {
                          if (result.files.length > 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('En fazla 4 fotoğraf seçebilirsiniz')),
                            );
                          } else {
                            setModalState(() {
                              photos = result.files;
                            });
                          }
                        }
                      },
                      child: Text('Fotoğrafları Seç (${photos.length})', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (photos.isNotEmpty)
                      CarouselSlider(
                        options: CarouselOptions(
                          aspectRatio: 2.0,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                          scrollDirection: Axis.horizontal,
                        ),
                        items: photos.map((file) {
                          return Stack(
                            key: UniqueKey(),
                            children: [
                              Image.memory(
                                file.bytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              Positioned(
                                top: 8.0,
                                right: 8.0,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setModalState(() {
                                      photos.remove(file);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          if (nameController.text.isNotEmpty &&
                              descController.text.isNotEmpty &&
                              selectedCategory != null &&
                              selectedSubCategory != null &&
                              priceController.text.isNotEmpty &&
                              photos.isNotEmpty) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Center(
                                  child: LoadingAnimationWidget.twistingDots(
                                      leftDotColor: _darkColor,
                                      rightDotColor: Colors.deepPurple,
                                      size: 100),
                                );
                              },
                            );
                            final photoUrls = await Future.wait(
                              photos.map((photo) async {
                                final storageRef = FirebaseStorage.instance
                                    .ref()
                                    .child('course_photos')
                                    .child(widget.uid)
                                    .child(photo.name);
                                final uploadTask = storageRef.putData(photo.bytes!);
                                final snapshot = await uploadTask.whenComplete(() => null);
                                return await snapshot.ref.getDownloadURL();
                              }).toList(),
                            );
                            await FirestoreService().createCourse(
                              nameController.text,
                              descController.text,
                              widget.uid,
                              selectedCategory!,
                              selectedSubCategory!,
                              double.parse(priceController.text),
                              photoUrls,
                            );
                            Navigator.pop(context); // Yükleniyor animasyonunu kapat
                            Navigator.pop(context); // Modal'ı kapat
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kurs Onaya Gönderildi')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lütfen tüm alanları doldurun ve en az bir fotoğraf seçin')),
                            );
                          }
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kurs oluşturulurken bir hata oluştu')),
                          );
                        }
                      },
                      child: Text('Oluştur', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
/*
return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF222831),
        title: Image.asset('assets/vitament1.png',
            height: MediaQuery
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
            child: const Text('Ana Sayfa',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
          TextButton(
            onPressed: () {
              context.go('/courses');
            },
            child: const Text('Danışmanlıklar',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)
            ),
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
            onPressed: ()
            {
              context.go('/appointments/${AuthService().userUID()}');

            },
            child: const Text('Randevularım', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ) : const SizedBox.shrink(),
          TextButton(
            onPressed: isLoggedIn
                ? () {
              context.go('/profile/' + AuthService().userUID());
            }
                : () {
              context.go('/login');
            },
            child: Text(isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol',
                style: const TextStyle(
                    color: Color(0xFF76ABAE), fontWeight: FontWeight.bold)
            ),
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
          ? Center(
          child: LoadingAnimationWidget.dotsTriangle(
              color: const Color(0xFF222831), size: 200))
          : SingleChildScrollView(
        child: Column( // gövde üst kısmı profil foto vs
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(2.0),
              color: const Color(0xFF222831),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: teamInfo['profilePictureUrl'] != null
                        ? NetworkImage(teamInfo['profilePictureUrl'])
                        : const AssetImage('assets/default_profile.png')
                    as ImageProvider,
                    onBackgroundImageError: (exception, stackTrace) {
                      print('Resim yüklenirken hata oluştu: $exception');
                    },
                  ),
                  if (isSelf) const SizedBox(height: 4),
                  if (isSelf) TextButton(
                      onPressed: () {
                        _showChangePhotoDialog(context);
                      },
                      child: const Text("Profil Fotoğrafını Değiştir",
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),)
                  ),
                  const SizedBox(height: 16),
                  !isSelf
                      ? Text(
                    teamInfo['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          tooltip: "İsmi Düzenle",
                          onPressed: () {
                            _showChangeNameDialog(context);
                          },
                          icon: const Icon(
                            Icons.edit_note,
                            color: Colors.white,
                          )
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        teamInfo['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      IconButton(
                          tooltip: "Çıkış Yap",
                          onPressed: () {
                            _showLogOutDialog(context);
                          },
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.red,
                          )
                      ),
                    ],
                  ),
                  const Text(
                    'Eğitim Merkezi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10,),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MediaQuery
                  .of(context)
                  .size
                  .width >= 800
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side
                  Expanded(
                    flex: 4,
                    child: Card(
                      color: const Color(0xFF222831),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Hakkında',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                if (isSelf)
                                  const SizedBox(
                                    width: 20,
                                  ),
                                if (isSelf)
                                  IconButton(
                                      tooltip: "Hakkında'yı Düzenle",
                                      onPressed: () {
                                        _showChangeDescDialog(
                                            context);
                                      },
                                      icon: const Icon(Icons.edit_note,
                                          color: Colors.white))
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(
                                thickness: 2, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              teamInfo['desc'] ?? '',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right side
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: const Color(0xFF50727B),
                                child: Padding(
                                  padding:
                                  const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Eğitmenleri',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.white),
                                              ),
                                              if(isSelf) const SizedBox(width: 10,),
                                              if(isSelf) IconButton(
                                                onPressed: ()
                                                {
                                                  _showCreateCourseDialog(context);
                                                },
                                                icon: const Icon(Icons.add_circle, color: Colors.white,),
                                              ),
                                            ],
                                          ),
                                          CarouselSlider(
                                            options: CarouselOptions(
                                              aspectRatio: 5 / 5,
                                              enlargeCenterPage: true,
                                              enableInfiniteScroll: false,
                                              scrollDirection: Axis.vertical,
                                            ),
                                            items: teamInfo['courses']?.map<
                                                Widget>((courseId) {
                                              return FutureBuilder<
                                                  Map<String, dynamic>>(
                                                future: FirestoreService()
                                                    .getCourseByUID(courseId),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<Map<
                                                        String,
                                                        dynamic>> snapshot) {
                                                  if (snapshot
                                                      .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                        child: CircularProgressIndicator());
                                                  } else
                                                  if (snapshot.hasError) {
                                                    return Center(child: Text(
                                                        'Hata: ${snapshot
                                                            .error}'));
                                                  } else if (!snapshot
                                                      .hasData) {
                                                    return const Center(child: Text(
                                                        'Veri yok'));
                                                  } else {
                                                    final courseData = snapshot
                                                        .data!;
                                                    return FutureBuilder<
                                                        Map<String, dynamic>>(
                                                      future: FirestoreService()
                                                          .getTeacherByUID(
                                                          courseData["author"]),
                                                      builder: (
                                                          BuildContext context,
                                                          AsyncSnapshot<Map<
                                                              String,
                                                              dynamic>> snapshot) {
                                                        if (snapshot
                                                            .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                              child: CircularProgressIndicator());
                                                        } else
                                                        if (snapshot.hasError) {
                                                          return Center(
                                                              child: Text(
                                                                  'Hata: ${snapshot
                                                                      .error}'));
                                                        } else
                                                        if (!snapshot.hasData) {
                                                          return const Center(
                                                              child: Text(
                                                                  'Veri yok'));
                                                        } else {
                                                          final authorData = snapshot
                                                              .data!;
                                                          return CourseCard(
                                                              course: courseData,
                                                              author: authorData);
                                                        }
                                                      },
                                                    );
                                                  }
                                                },
                                              );
                                            }).toList() ?? [],
                                          ),
                                        ],
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
                  const SizedBox(height: 16),
                  Card(
                    color: const Color(0xFF222831),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: !isSelf
                          ? const Text(
                        'Hakkında',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )
                          : Row(
                        children: [
                          const Text('Hakkında',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(
                            width: 20,
                          ),
                          IconButton(
                              tooltip: "Hakkında'yı Düzenle",
                              onPressed: () {
                                _showChangeDescDialog(context);
                              },
                              icon: const Icon(
                                Icons.edit_note,
                                color: Colors.white,
                              ))
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            teamInfo['desc'] ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: const Color(0xFF50727B),
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      title: Row(
                        children: [
                          const Text(
                            'Eğitmenleri',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .bold,
                                color:
                                Colors.white),
                          ),
                          const SizedBox(width: 10,),
                          IconButton(
                            onPressed: ()
                            {
                              _showCreateCourseDialog(context);
                            },
                            icon: const Icon(Icons.add_circle, color: Colors.white,),
                          ),
                        ],
                      ),
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            aspectRatio: 1,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            scrollDirection: Axis.vertical,
                          ),
                          items: teamInfo['courses']?.map<Widget>((courseId) {
                            return FutureBuilder<Map<String, dynamic>>(
                              future: FirestoreService().getCourseByUID(
                                  courseId),
                              builder: (BuildContext context, AsyncSnapshot<
                                  Map<String, dynamic>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Hata: ${snapshot.error}'));
                                } else if (!snapshot.hasData) {
                                  return const Center(child: Text('Veri yok'));
                                } else {
                                  final courseData = snapshot.data!;
                                  return FutureBuilder<Map<String, dynamic>>(
                                    future: FirestoreService().getTeacherByUID(
                                        courseData["author"]),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<
                                            Map<String, dynamic>> snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text(
                                            'Hata: ${snapshot.error}'));
                                      } else if (!snapshot.hasData) {
                                        return const Center(child: Text('Veri yok'));
                                      } else {
                                        final authorData = snapshot.data!;
                                        return CourseCard(course: courseData,
                                            author: authorData);
                                      }
                                    },
                                  );
                                }
                              },
                            );
                          }).toList() ?? [],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ), // fotolu kısım
      ),
      backgroundColor: const Color(0xFFEEEEEE),
    );
*  */



///TODO : BU SAYFAYI DÜZENLE
