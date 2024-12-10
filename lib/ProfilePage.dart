import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ozel_ders/Components/CourseCard.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/Components/NotificationIconButton.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'Components/BlogCard.dart';
import 'Components/Drawer.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  ProfilePage({required this.uid});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isTeacher = false;
  bool isLoading = true;
  Map<String, dynamic> userInfo = {};
  bool isLoggedIn = false;
  bool isSelf = false;
  bool isCurrentTeam = false;
  String teamUidIfCurrent = "";
  String teamNameIfCurrent = "";
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> notifications = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      setState(() {
        isTeacher = false;
        isLoading = true;
        userInfo = {};
        isLoggedIn = false;
        isSelf = false;
        isCurrentTeam = false;
        categories = [];
      });
      initMenu();
      initData();
    }
  }

  @override
  void initState() {
    super.initState();
    initMenu();
    initData();
  }

  Future<void> initMenu() async {
    isLoggedIn = await AuthService().isUserSignedIn();
    if (isLoggedIn) {
      String currentUID = AuthService().userUID();
      var teamCheck = await FirestoreService().getTeamByUID(currentUID);
      if (teamCheck.isNotEmpty) {
        isCurrentTeam = true;
        teamUidIfCurrent = teamCheck["uid"];
        teamNameIfCurrent = teamCheck["name"];
      }
      if (widget.uid == AuthService().userUID()) {
        isSelf = true;
      }
    }
    setState(() {});
  }

  Future<void> initData() async {
    var teamCheck = await FirestoreService().getTeamByUID(widget.uid);
    if (teamCheck.isNotEmpty) {
      String uid = teamCheck["uid"];
      context.go("/team/$uid");
    }
    userInfo = await FirestoreService().getTeacherByUID(widget.uid);

    if (userInfo.isNotEmpty) {
      isTeacher = true;
      notifications = await FirestoreService().getNotificationsForTeacher(widget.uid);
    } else {
      userInfo = await FirestoreService().getStudentByUID(widget.uid);
      notifications = await FirestoreService().getNotificationsForStudent(widget.uid);
      isTeacher = false;
    }
    print(notifications);
    categories = await FirestoreService().getCategories();
    setState(() {
      isLoading = false;
    });
  }


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

        await FirestoreService()
            .changeUserPhoto(widget.uid, downloadUrl, isTeacher);
        setState(() {
          userInfo['profilePictureUrl'] = downloadUrl;
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
    TextEditingController(text: userInfo['desc']);
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
                  await FirestoreService().changeUserDesc(
                      widget.uid, descController.text, isTeacher);
                  setState(() {
                    userInfo['desc'] = descController.text;
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
    TextEditingController(text: userInfo['name']);
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
                      .changeUserName(widget.uid, nameController.text, isTeacher);
                  setState(() {
                    userInfo['name'] = nameController.text;
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

  Future<void> _showOurEmployeeDialog(BuildContext context) async {
    String type = isTeacher ? "Eğitimci" : "Öğrenci";
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
              Text('Bu $type Sizin Ekibinizden Mi?',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (isTeacher) {
                    await FirestoreService().sendRFromTeamToTeacher(
                        widget.uid, teamUidIfCurrent, teamNameIfCurrent);
                  } else {
                    await FirestoreService().sendRFromTeamToStudent(
                        widget.uid, teamUidIfCurrent, teamNameIfCurrent);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Katılma isteği gönderildi')),
                  );
                },
                child: Text('Evet, Katılma İsteği Gönder'),
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
                                  content: Text(
                                      'En fazla 4 fotoğraf seçebilirsiniz')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF222831),
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
            child: Text('Ana Sayfa',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories'); // CategoriesPage'e yönlendirme
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
            onPressed: isLoggedIn
                ? () {
              print("anan");
              context.go('/profile/' + AuthService().userUID());
            }
                : () {
              context.go('/login');
            },
            child: Text(isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol',
                style: TextStyle(
                    color: isSelf ? Color(0xFF76ABAE) : Colors.white,
                    fontWeight: FontWeight.bold)),
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
              color: Color(0xFF222831), size: 200))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(2.0),
              color: Color(0xFF222831),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userInfo['profilePictureUrl'] != null
                        ? NetworkImage(userInfo['profilePictureUrl'])
                        : AssetImage('assets/default_profile.png')
                    as ImageProvider,
                  ),
                  if (isSelf) SizedBox(height: 4),
                  if (isSelf) TextButton(
                      onPressed: () {
                        _showChangePhotoDialog(context);
                      },
                      child: Text("Profil Fotoğrafını Değiştir",
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),)
                  ),
                  SizedBox(height: 5),
                  !isSelf
                      ? !isCurrentTeam ? Text(
                    userInfo['name'] ?? '',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ) : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userInfo['name'] ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _showOurEmployeeDialog(context);
                        },
                        child: Text(
                          "Bu Kişi Benim Ekibimden",
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          tooltip: "İsmi Düzenle",
                          onPressed: () {
                            _showChangeNameDialog(context);
                          },
                          icon: Icon(
                            Icons.edit_note,
                            color: Colors.white,
                          )
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        userInfo['name'] ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      IconButton(
                          tooltip: "Çıkış Yap",
                          onPressed: () {
                            _showLogOutDialog(context);
                          },
                          icon: Icon(
                            Icons.logout,
                            color: Colors.red,
                          )
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelf) SizedBox(height: 4),
                      if (isSelf) NotificationIconButtonWithBadge(
                          userType: isTeacher ? UserType.teacher : UserType
                              .student,
                          userUID: widget.uid),
                      Text(
                        isTeacher ? 'Eğitimci' : 'Öğrenci',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
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
                      color: Color(0xFF222831),
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
                                Text(
                                  'Hakkında',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                if (isSelf)
                                  SizedBox(
                                    width: 20,
                                  ),
                                if (isSelf)
                                  IconButton(
                                      tooltip: "Hakkında'yı Düzenle",
                                      onPressed: () {
                                        _showChangeDescDialog(
                                            context);
                                      },
                                      icon: Icon(Icons.edit_note,
                                          color: Colors.white))
                              ],
                            ),
                            SizedBox(height: 8),
                            Divider(
                                thickness: 2, color: Colors.white),
                            SizedBox(height: 8),
                            Text(
                              userInfo['desc'] ?? '',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Right side
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: Color(0xFF50727B),
                                child: Padding(
                                  padding:
                                  const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          !isTeacher ? Text(
                                            'Aldığı Kurslar',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                color:
                                                Colors.white),
                                          )
                                              : Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                'Verdiği Kurslar',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color:
                                                    Colors.white),
                                              ),
                                              if(isSelf) SizedBox(width: 10,),
                                              if(isSelf) IconButton(
                                                onPressed: () {
                                                  _showCreateCourseDialog(
                                                      context);
                                                },
                                                icon: Icon(Icons.add_circle,
                                                  color: Colors.white,),
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
                                            items: userInfo['courses']?.map<
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
                                                    return Center(
                                                        child: CircularProgressIndicator());
                                                  } else
                                                  if (snapshot.hasError) {
                                                    return Center(child: Text(
                                                        'Hata: ${snapshot
                                                            .error}'));
                                                  } else if (!snapshot
                                                      .hasData) {
                                                    return Center(child: Text(
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
                                                          return Center(
                                                              child: CircularProgressIndicator());
                                                        } else
                                                        if (snapshot.hasError) {
                                                          return Center(
                                                              child: Text(
                                                                  'Hata: ${snapshot
                                                                      .error}'));
                                                        } else
                                                        if (!snapshot.hasData) {
                                                          return Center(
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
                            // Kursları gösteren bölümün hemen altına, geniş ekran için (flex:2 bölmesinin altına ya da yanına):
                          ],
                        ),
                        SizedBox(height: 16),
                        Card(
                          color: Color(0xFF50727B),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              // İçeriğe göre min boy
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Yazdığı Bloglar',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (isSelf) ...[
                                      SizedBox(width: 10),
                                      IconButton(
                                        onPressed: () {
                                          context.go("/blog-create/${userInfo["uid"]}");
                                        },
                                        icon: Icon(Icons.add_circle,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 16),
                                FutureBuilder<List<Map<String, dynamic>>>(
                                  future: isTeacher ? FirestoreService()
                                      .getTeacherBlogs(widget.uid) : Future
                                      .value([]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return SizedBox(height: 50,
                                          child: Center(
                                              child: CircularProgressIndicator()));
                                    } else if (snapshot.hasError) {
                                      return Text('Hata: ${snapshot.error}',
                                          style: TextStyle(
                                              color: Colors.white));
                                    } else {
                                      final blogs = snapshot.data ?? [];
                                      if (blogs.isEmpty) {
                                        return Text('Henüz blog yok.',
                                            style: TextStyle(
                                                color: Colors.white));
                                      } else {
                                        // CarouselSlider ile blogları yatayda kaydırıyoruz.
                                        return CarouselSlider(
                                          options: CarouselOptions(
                                            aspectRatio: 3,
                                            height: 300.0,
                                            enableInfiniteScroll: false,
                                            enlargeCenterPage: true,
                                            scrollDirection: Axis.horizontal,
                                          ),
                                          items: blogs.map((blog) {
                                            return Stack(
                                              children: [
                                                Container(
                                                    height: 300,
                                                    width: 500,
                                                    child: BlogCard(blog: blog)
                                                ),
                                                if (isSelf)
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: IconButton(
                                                      icon: Icon(Icons.build_circle,
                                                        color: Colors.black, size: 35,),
                                                      onPressed: () {
                                                        context.go("/blog-update/${userInfo["uid"]}/${blog["uid"]}");
                                                      },
                                                    ),
                                                  ),
                                              ],
                                            );
                                          }).toList(),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16),
                  Card(
                    color: Color(0xFF222831),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: !isSelf
                          ? Text(
                        'Hakkında',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )
                          : Row(
                        children: [
                          Text('Hakkında',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          SizedBox(
                            width: 20,
                          ),
                          IconButton(
                              tooltip: "Hakkında'yı Düzenle",
                              onPressed: () {
                                _showChangeDescDialog(context);
                              },
                              icon: Icon(
                                Icons.edit_note,
                                color: Colors.white,
                              ))
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            userInfo['desc'] ?? '',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    color: Color(0xFF50727B),
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      title: !isTeacher ? Text(
                        'Aldığı Kurslar',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight
                                .bold,
                            color:
                            Colors.white),
                      )
                          : Row(
                        children: [
                          Text(
                            'Verdiği Kurslar',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .bold,
                                color:
                                Colors.white),
                          ),
                          if(isSelf) SizedBox(width: 10,),
                          if(isSelf) IconButton(
                            onPressed: () {
                              _showCreateCourseDialog(context);
                            },
                            icon: Icon(Icons.add_circle, color: Colors.white,),
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
                          items: userInfo['courses']?.map<Widget>((courseId) {
                            return FutureBuilder<Map<String, dynamic>>(
                              future: FirestoreService().getCourseByUID(
                                  courseId),
                              builder: (BuildContext context, AsyncSnapshot<
                                  Map<String, dynamic>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Hata: ${snapshot.error}'));
                                } else if (!snapshot.hasData) {
                                  return Center(child: Text('Veri yok'));
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
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text(
                                            'Hata: ${snapshot.error}'));
                                      } else if (!snapshot.hasData) {
                                        return Center(child: Text('Veri yok'));
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
                  SizedBox(height: 16),
                  Card(
                    color: Color(0xFF50727B),
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      title: Row(
                        children: [
                          Text(
                            'Yazdığı Bloglar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (isSelf) SizedBox(width: 10),
                          if (isSelf) IconButton(
                            onPressed: () {
                              context.go("/blog-create/${userInfo["uid"]}");
                            },
                            icon: Icon(Icons.add_circle, color: Colors.white),
                          ),
                        ],
                      ),
                      children: [
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: isTeacher ? FirestoreService()
                              .getTeacherBlogs(widget.uid) : Future.value([]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(height: 50,
                                    child: Center(
                                        child: CircularProgressIndicator())),
                              );
                            } else if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Hata: ${snapshot.error}',
                                    style: TextStyle(color: Colors.white)),
                              );
                            } else {
                              final blogs = snapshot.data ?? [];
                              if (blogs.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Henüz blog yok.',
                                      style: TextStyle(color: Colors.white)),
                                );
                              } else {
                                // Dar ekranda da CarouselSlider kullanıyoruz
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                      height: 300.0,
                                      enableInfiniteScroll: false,
                                      enlargeCenterPage: true,
                                      scrollDirection: Axis.horizontal,
                                    ),
                                    items: blogs.map((blog) {
                                      return Stack(
                                        children: [
                                          BlogCard(blog: blog),
                                          if (isSelf)
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: IconButton(
                                                icon: Icon(Icons.build_circle,
                                                    color: Colors.black, size: 35,),
                                                onPressed: () {
                                                  context.go("/blog-update/${userInfo["uid"]}/${blog["uid"]}");
                                                },
                                              ),
                                            ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFEEEEEE),
    );
  }
}
