import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ozel_ders/Components/CourseCard.dart';
import 'package:ozel_ders/Components/Footer.dart';
import 'package:ozel_ders/FirebaseController.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
  List<Map<String, dynamic>> categories = [];


  @override
  void initState() {
    super.initState();
    initMenu();
    initData();
  }

  Future<void> initMenu() async {
    isLoggedIn = await AuthService().isUserSignedIn();
    if (isLoggedIn) {
      print(widget.uid);
      print(AuthService().userUID());
      if (widget.uid == AuthService().userUID()) {
        isSelf = true;
        print(isSelf);
      }
    }
    setState(() {});
  }

  Future<void> initData() async {
    userInfo = await FirestoreService().getTeacherByUID(widget.uid);

    if (userInfo.isNotEmpty) {
      isTeacher = true;
    } else {
      userInfo = await FirestoreService().getStudentByUID(widget.uid);
      isTeacher = false;
    }

    categories = await FirestoreService().getCategories();
    print(categories);
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

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: LoadingAnimationWidget.twistingDots(
                leftDotColor: Color(0xFF009899),
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

        // Close the loading dialog
        Navigator.of(context).pop();
      } catch (e) {
        // Close the loading dialog
        Navigator.of(context).pop();

        print('Error uploading profile picture: $e');
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
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Açıklamayı Değiştir',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextField(
                controller: descController,
                maxLines: 5,
                decoration: InputDecoration(hintText: 'Yeni Açıklama'),
              ),
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
              ),
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
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('İsmi Değiştir',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Yeni İsim'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirestoreService().changeUserName(
                      widget.uid, nameController.text, isTeacher);
                  setState(() {
                    userInfo['name'] = nameController.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Kaydet'),
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
        final category = categories.firstWhere((category) => category['uid'] == selectedCategory);
        subCategories = List<Map<String, dynamic>>.from(category['subCategories']);
      } else {
        subCategories = [];
      }
      selectedSubCategory = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Yeni Kurs Oluştur', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(hintText: 'Kurs Adı'),
                    ),
                    TextField(
                      controller: descController,
                      maxLines: 5,
                      decoration: InputDecoration(hintText: 'Kurs Açıklaması'),
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      hint: Text('Kategori Seç'),
                      onChanged: (String? newValue) {
                        setModalState(() {
                          selectedCategory = newValue;
                          updateSubCategories();
                        });
                      },
                      items: categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category['uid'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                    ),
                    if (selectedCategory != null)
                      DropdownButton<String>(
                        value: selectedSubCategory,
                        hint: Text('Alt Kategori Seç'),
                        onChanged: (String? newValue) {
                          setModalState(() {
                            selectedSubCategory = newValue;
                          });
                        },
                        items: subCategories.map<DropdownMenuItem<String>>((subCategory) {
                          return DropdownMenuItem<String>(
                            value: subCategory['uid'],
                            child: Text(subCategory['name']),
                          );
                        }).toList(),
                      ),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: 'Saatlik Ücret'),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async
                      {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: true,
                        );

                        if (result != null) {
                          if (result.files.length > 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('En fazla 4 fotoğraf seçebilirsiniz')),
                            );
                          } else {
                            setModalState(() {
                              photos = result.files;
                            });
                          }
                        }
                      },
                      child: Text('Fotoğrafları Seç (${photos.length})'),
                    ),
                    if (photos.isNotEmpty)
                      Column(
                        children: [
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
                        ],
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty &&
                            descController.text.isNotEmpty &&
                            selectedCategory != null &&
                            selectedSubCategory != null &&
                            priceController.text.isNotEmpty &&
                            photos.isNotEmpty) {
                          final photoUrls = await Future.wait(photos.map((photo) async {
                            final storageRef = FirebaseStorage.instance
                                .ref()
                                .child('course_photos')
                                .child(widget.uid)
                                .child(photo.name);
                            final uploadTask = storageRef.putFile(File(photo.path!));
                            final snapshot = await uploadTask.whenComplete(() => null);
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

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Kurs başarıyla oluşturuldu')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lütfen tüm alanları doldurun ve en az bir fotoğraf seçin')),
                          );
                        }
                      },
                      child: Text('Oluştur'),
                    ),
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
      appBar: AppBar(
        backgroundColor: Color(0xFF009899),
        title: Image.asset('assets/header.png',
            height: MediaQuery
                .of(context)
                .size
                .width < 600 ? 250 : 300),
        centerTitle: MediaQuery
            .of(context)
            .size
            .width < 600 ? true : false,
        actions: MediaQuery
            .of(context)
            .size
            .width >= 600
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
              context.go('/courses'); // CoursesPage'e yönlendirme
            },
            child: Text('Kurslar',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          isLoggedIn
              ? TextButton(
            onPressed: () {}, //
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
      drawer: MediaQuery
          .of(context)
          .size
          .width < 600
          ? DrawerMenu(isLoggedIn: isLoggedIn)
          : null,
      body: isLoading
          ? Center(
          child: LoadingAnimationWidget.dotsTriangle(
              color: Color(0xFF009899), size: 200))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(2.0),
              color: Color(0xFF009899),
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
                  SizedBox(height: 16),
                  !isSelf
                      ? Text(
                    userInfo['name'] ?? '',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                          tooltip: "İsmi Düzenle",
                          onPressed: () {
                            _showChangeNameDialog(context);
                          },
                          icon: Icon(
                            Icons.edit_note,
                            color: Colors.white,
                          ))
                    ],
                  ),
                  Text(
                    !isTeacher ? 'Eğitimci' : 'Öğrenci',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
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
                  .width >= 600
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side
                  Expanded(
                    flex: 4,
                    child: Card(
                      color: Color(0xFF40E0D0),
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
                                color: Color(0xFF663366),
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
                                            mainAxisAlignment: MainAxisAlignment.center,
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
                                              SizedBox(width: 10,),
                                              IconButton(
                                                  onPressed: ()
                                                  {
                                                    _showCreateCourseDialog(context);
                                                  },
                                                  icon: Icon(Icons.add_circle, color: Colors.white,),
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
                  SizedBox(height: 16),
                  Card(
                    color: Color(0xFF40E0D0),
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
                    color: Color(0xFF663366),
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
                          SizedBox(width: 10,),
                          IconButton(
                            onPressed: ()
                            {
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
