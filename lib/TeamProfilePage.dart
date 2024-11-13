import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ozel_ders/Components/CourseCard.dart';
import 'package:ozel_ders/FirebaseController.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'Components/Drawer.dart';

class TeamProfilePage extends StatefulWidget {
  final String uid;

  TeamProfilePage({required this.uid});

  @override
  _TeamProfilePageState createState() => _TeamProfilePageState();
}

class _TeamProfilePageState extends State<TeamProfilePage> {
  bool isLoading = true;
  Map<String, dynamic> teamInfo = {};
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
                leftDotColor: const Color(0xFF183A37),
                rightDotColor: const Color(0xFF663366),
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
            .changeTeamPhoto(widget.uid, downloadUrl);
        setState(() {
          teamInfo['profilePictureUrl'] = downloadUrl;
        });

        // Close the loading dialog
        Navigator.of(context).pop();
      } catch (e) {
        // Close the loading dialog
        Navigator.of(context).pop();

        print('Error uploading profile picture: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotoğrafı yüklenirken hata oluştu')),
        );
      }
    }
  }

  Future<void> _showChangeDescDialog(BuildContext context) async {
    TextEditingController descController =
    TextEditingController(text: teamInfo['desc']);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Açıklamayı Değiştir',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10,),
              TextField(
                controller: descController,
                maxLines: 5,
                decoration: const InputDecoration(hintText: 'Yeni Açıklama'),
              ),
              const SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () async {
                  await FirestoreService().changeTeamDesc(
                      widget.uid, descController.text);
                  setState(() {
                    teamInfo['desc'] = descController.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Kaydet'),
              ),
              const SizedBox(height: 10,),
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
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('İsmi Değiştir',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10,),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Yeni İsim'),
              ),
              const SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () async {
                  await FirestoreService().changeTeamName(
                      widget.uid, nameController.text);
                  setState(() {
                    teamInfo['name'] = nameController.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Kaydet'),
              ),
              const SizedBox(height: 10,),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLogOutDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Çıkış Yapmak İstiyor Musunuz?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: () async {
                  bool a = await AuthService().signOut();
                  if(a)
                    context.go("/login");
                  else
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Çıkış Yapılırken Hata Oluştu')),);
                },
                child: const Text('Evet, Çıkış Yap'),
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
                    const Text('Yeni Kurs Oluştur', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(hintText: 'Kurs Adı'),
                    ),
                    TextField(
                      controller: descController,
                      maxLines: 5,
                      decoration: const InputDecoration(hintText: 'Kurs Açıklaması'),
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      hint: const Text('Kategori Seç'),
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
                        hint: const Text('Alt Kategori Seç'),
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
                      decoration: const InputDecoration(hintText: 'Saatlik Ücret'),
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
                        ],
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          if (nameController.text.isNotEmpty &&
                              descController.text.isNotEmpty &&
                              selectedCategory != null &&
                              selectedSubCategory != null &&
                              priceController.text.isNotEmpty &&
                              photos.isNotEmpty) {
                            final photoUrls = await Future.wait(
                                photos.map((photo) async {
                                  final storageRef = FirebaseStorage.instance
                                      .ref()
                                      .child('course_photos')
                                      .child(widget.uid)
                                      .child(photo.name);
                                  final uploadTask = storageRef.putData(
                                      photo.bytes!);
                                  final snapshot = await uploadTask
                                      .whenComplete(() => null);
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
                              const SnackBar(
                                  content: Text('Kurs başarıyla oluşturuldu')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(
                                  'Lütfen tüm alanları doldurun ve en az bir fotoğraf seçin')),
                            );
                          }
                        }
                        catch(e)
                        {
                          print(e);
                        }
                      },
                      child: const Text('Oluştur'),
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
        backgroundColor: const Color(0xFF183A37),
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
            child: const Text('Ana Sayfa',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories');
            },
            child: const Text('Kategoriler',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
          TextButton(
            onPressed: () {
              context.go('/courses');
            },
            child: const Text('Kurslar',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)
            ),
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
                    color: Color(0xFFC44900), fontWeight: FontWeight.bold)
            ),
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
              color: const Color(0xFF183A37), size: 200))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(2.0),
              color: const Color(0xFF183A37),
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
                  .width >= 600
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side
                  Expanded(
                    flex: 4,
                    child: Card(
                      color: const Color(0xFF183A37),
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
                                color: const Color(0xFF432534),
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
                    color: const Color(0xFF183A37),
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
                    color: const Color(0xFF432534),
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
        ),
      ),
      backgroundColor: const Color(0xFFEFD6AC),
    );
  }
}


///TODO : BU SAYFAYI DÜZENLE