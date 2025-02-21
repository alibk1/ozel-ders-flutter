import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:zefyrka/zefyrka.dart';

class AdminPanel2 extends StatefulWidget {
  @override
  _AdminPanel2State createState() => _AdminPanel2State();
}

class _AdminPanel2State extends State<AdminPanel2> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final FirestoreService firestoreService = FirestoreService();

  // Veriler için değişkenler
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> blogs = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> videos = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Tüm verileri yükleme
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Firebase'den verileri al
      List<Map<String, dynamic>> loadedCourses = await firestoreService.getAllCourses();
      List<Map<String, dynamic>> loadedBlogs = await firestoreService.getAllBlogs();
      List<Map<String, dynamic>> loadedCategories = await firestoreService.getCategories();
      List<Map<String, dynamic>> loadedTeachers = await firestoreService.getAllTeachers();
      List<Map<String, dynamic>> loadedStudents = await firestoreService.getAllStudents();
      List<Map<String, dynamic>> loadedVideos = await firestoreService.getAllVideos();

      // Status'e göre sıralama
      loadedCourses.sort((a, b) => (a['status'] as int).compareTo(b['status'] as int));
      loadedBlogs.sort((a, b) => (a['status'] as int).compareTo(b['status'] as int));

      setState(() {
        courses = loadedCourses;
        blogs = loadedBlogs;
        categories = loadedCategories;
        students = loadedStudents;
        teachers = loadedTeachers;
        videos = loadedVideos;
        isLoading = false;
      });
    } catch (e) {
      print('Veri yüklenirken hata oluştu: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getStatusString(int status)
  {
    if(status == -1)
    {
      return "Reddedildi";
    }
    else if(status == 0)
    {
      return "Henüz Onaylanmadı";
    }
    return "Onaylandı";
  }

  String getAuthorName(String authorUID)
  {
    return teachers.firstWhere((t) => t["UID"] == authorUID)["name"] ?? "";
  }


  Widget _customEmbedBuilder(BuildContext context, EmbedNode node) {
    final String? imageUrl = node.value.data['source'];
    if (node.value.type == 'image' && imageUrl != null) {
      if (imageUrl.startsWith('data:image')) {
        final base64Data = imageUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Image.memory(bytes, fit: BoxFit.cover),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Image.network(imageUrl, fit: BoxFit.cover),
        );
      }
    }
    throw UnimplementedError(
        'Embeddable type "${node.value.type}" is not supported by the custom embed builder.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Paneli 2'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Danışmanlıklar'),
            Tab(text: 'Bloglar'),
            Tab(text: 'Kategoriler'),
            Tab(text: 'Videolar'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildCoursesTab(),
          _buildBlogsTab(),
          _buildCategoriesTab(),
          _buildVideosTab(),
        ],
      ),
    );
  }

  // 1. Terapiler Sekmesi
  Widget _buildCoursesTab() {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        var course = courses[index];
        return ListTile(
          title: Text(course['name']),
          subtitle: Text('Eğitimci: ${getAuthorName(course['author'])}'),
          trailing: Text('Durum: ${course['status']}'),
          onTap: () {
            _showCourseDetails(context, course);
          },
        );
      },
    );
  }

  void _showCourseDetails(BuildContext context, Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(course['name']),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Açıklama: ${course['desc']}'),
                SizedBox(height: 8),
                Text('Kategori: ${course['category']}'),
                SizedBox(height: 8),
                Text('Alt Kategori: ${course['subCategory']}'),
                SizedBox(height: 8),
                Text('Saatlik Ücret: ${course['hourlyPrice']} ₺'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                firestoreService.acceptCourse(course['UID']);
                _loadData(); // Verileri yeniden yükle
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${course['name']} kabul edildi!')),
                );
              },
              child: Text('Kabul Et'),
            ),
            TextButton(
              onPressed: () {
                _showDenyCourseDialog(context, course['UID']);
              },
              child: Text('Reddet'),
            ),
          ],
        );
      },
    );
  }

  void _showDenyCourseDialog(BuildContext context, String courseId) {
    TextEditingController denyReasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reddetme Sebebi'),
          content: TextField(
            controller: denyReasonController,
            decoration: InputDecoration(hintText: 'Sebep yazınız'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                firestoreService.denyCourse(courseId, denyReasonController.text);
                _loadData(); // Verileri yeniden yükle
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kurs reddedildi!')),
                );
              },
              child: Text('Gönder'),
            ),
          ],
        );
      },
    );
  }

  // 2. Bloglar Sekmesi
  Widget _buildBlogsTab() {
    return ListView.builder(
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        var blog = blogs[index];
        return ListTile(
          title: Text(blog['title']),
          subtitle: Text('Yazar: ${getAuthorName(blog['creatorUID'])}'),
          trailing: Text('Durum: ${blog['status']}'),
          onTap: () {
            _showBlogDetails(context, blog);
          },
        );
      },
    );
  }

  void _showBlogDetails(BuildContext context, Map<String, dynamic> blog) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(blog['title']),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.shade300),
                  ),
                  padding: EdgeInsets.all(12.0),
                  child: ZefyrEditor(
                    controller: ZefyrController(
                      NotusDocument.fromJson(
                        jsonDecode(blog['content']),
                      ),
                    ),
                    readOnly: true,
                    padding: EdgeInsets.zero,
                    embedBuilder: _customEmbedBuilder,
                    showCursor: false,
                  ),
                ),                SizedBox(height: 8),
                Text('Durum: ${blog['status']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                firestoreService.acceptBlog(blog['UID']);
                _loadData(); // Verileri yeniden yükle
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${blog['title']} kabul edildi!')),
                );
              },
              child: Text('Kabul Et'),
            ),
            TextButton(
              onPressed: () {
                _showDenyBlogDialog(context, blog['UID']);
              },
              child: Text('Reddet'),
            ),
          ],
        );
      },
    );
  }

  void _showDenyBlogDialog(BuildContext context, String blogId) {
    TextEditingController denyReasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reddetme Sebebi'),
          content: TextField(
            controller: denyReasonController,
            decoration: InputDecoration(hintText: 'Sebep yazınız'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                firestoreService.denyBlog(blogId, denyReasonController.text);
                _loadData(); // Verileri yeniden yükle
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Blog reddedildi!')),
                );
              },
              child: Text('Gönder'),
            ),
          ],
        );
      },
    );
  }

  // 3. Kategoriler Sekmesi
  Widget _buildCategoriesTab() {
    return Scaffold(
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          var category = categories[index];
          return ListTile(
            title: Text(category['name']),
            subtitle: Text('${category['subCategories'].length} Alt Kategoriler'),
            onTap: () {
              _showCategoryEditor(context, category);
            },
            trailing: IconButton(onPressed: (){

            }, icon: Icon(Icons.delete)),
          );
        },
      ),
      floatingActionButton: BuildCategoryButton()
    );
  }
  void _deleteCategory(){}


  void _showCategoryEditor(BuildContext context, Map<String, dynamic> category) {
    TextEditingController categoryNameController = TextEditingController(text: category['name']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${category['name']} Kategorisi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryNameController,
                decoration: InputDecoration(labelText: 'Kategori Adı'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  firestoreService.editCategory(category['UID'], categoryNameController.text);
                  _loadData(); // Verileri yeniden yükle
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kategori Güncellendi!')),
                  );
                },
                child: Text('Kaydet'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideosTab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: ()
                {
                  _showAddVideoDialog();
                },
                icon: Icon(Icons.add, color: Colors.green,)
            ),
          ],
        ),
       Expanded(
          child: ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              var course = videos[index];
              return ListTile(
                title: Text(course['videoTitle']),
                subtitle: Text('URL: ${course['videoUrl']}'),
                trailing: IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.delete, color: Colors.red,)
                ),
                onTap: () {
                  _showEditVideoDialog(videos[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddVideoDialog() {
    TextEditingController videoUrlController = TextEditingController();
    TextEditingController titleController = TextEditingController();
    Uint8List? localImageBytes; // Web için dosya byte'ları
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Yeni Video Ekle'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Video URL alanı
                      TextFormField(
                        controller: videoUrlController,
                        decoration: InputDecoration(labelText: 'Video URL'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Video URL gereklidir'
                            : null,
                      ),
                      // Başlık alanı
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Başlık'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Başlık gereklidir'
                            : null,
                      ),
                      SizedBox(height: 12),
                      // Resim seçimi ve önizleme
                      localImageBytes != null
                          ? Image.memory(localImageBytes!, height: 150, fit: BoxFit.cover)
                          : Container(
                        height: 150,
                        color: Colors.grey.shade300,
                        child: Center(child: Text('Resim Seçilmedi')),
                      ),
                      TextButton(
                        onPressed: () async {
                          Uint8List? pickedBytes = await selectImage();
                          if (pickedBytes != null) {
                            setStateDialog(() {
                              localImageBytes = pickedBytes;
                            });
                          }
                        },
                        child: Text('Resim Seç'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && localImageBytes != null) {
                      // Web ortamında resmi yüklemek için FirestoreService'in
                      // web'e uygun uploadThumbnailWeb fonksiyonunu kullanıyoruz.
                      String thumbnailUrl = await firestoreService.uploadThumbnailWeb(localImageBytes!);
                      await firestoreService.createYoutubeVideo(
                        "admin",
                        videoUrlController.text.trim(),
                        thumbnailUrl,
                        titleController.text.trim(),
                      );
                      _loadData(); // Verileri güncelle
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Video eklendi!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tüm alanlar zorunludur.')),
                      );
                    }
                  },
                  child: Text('Kaydet'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('İptal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditVideoDialog(Map<String, dynamic> video) {
    TextEditingController titleController = TextEditingController(text: video['videoTitle']);
    // Mevcut resim URL'si (Firebase Storage'daki)
    String currentThumbnailUrl = video['videoThumbnailUrl'];
    Uint8List? newLocalImageBytes; // Düzenleme sırasında seçilecek yeni resim byte'ları
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Videoyu Düzenle'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Başlık alanı
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Başlık'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Başlık gereklidir'
                            : null,
                      ),
                      SizedBox(height: 12),
                      // Resim alanı: Eğer yeni resim seçilmişse onun önizlemesi,
                      // aksi halde mevcut resim gösterilir.
                      newLocalImageBytes != null
                          ? Image.memory(newLocalImageBytes!, height: 150, fit: BoxFit.cover)
                          : Image.network(currentThumbnailUrl, height: 150, fit: BoxFit.cover),
                      TextButton(
                        onPressed: () async {
                          Uint8List? pickedBytes = await selectImage();
                          if (pickedBytes != null) {
                            setStateDialog(() {
                              newLocalImageBytes = pickedBytes;
                            });
                          }
                        },
                        child: Text('Resim Değiştir'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && (newLocalImageBytes != null || currentThumbnailUrl.isNotEmpty)) {
                      String updatedThumbnailUrl = currentThumbnailUrl;
                      // Yeni resim seçilmişse eski resmi silip yenisini yükle
                      if (newLocalImageBytes != null) {
                        await firestoreService.deleteThumbnail(currentThumbnailUrl);
                        updatedThumbnailUrl = await firestoreService.uploadThumbnailWeb(newLocalImageBytes!);
                      }
                      String videoUID = video['UID'];
                      await firestoreService.updateYoutubeVideo(
                        videoUID,
                        updatedThumbnailUrl,
                        titleController.text.trim(),
                      );
                      _loadData(); // Verileri güncelle
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Video güncellendi!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Başlık ve resim zorunludur.')),
                      );
                    }
                  },
                  child: Text('Kaydet'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('İptal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Web için: selectImage fonksiyonu yalnızca dosya byte’larını döndürür.
  Future<Uint8List?> selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      return result.files.single.bytes; // Web ortamında path kullanılmaz
    }
    return null;
  }
}

class BuildCategoryButton extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final List<String> _subCategories = [];
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage(BuildContext context) async {
    FileUploadInputElement uploadInput = FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        final reader = FileReader();
        reader.readAsDataUrl(files[0]);
        reader.onLoadEnd.listen((event) {
          _image = files[0];
          (context as Element).markNeedsBuild();
        });
      }
    });
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child('category_images/$fileName');
      await storageRef.putBlob(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Image upload error: $e");
      return null;
    }
  }

  Future<void> _createCategory(BuildContext context) async {
    if (_nameController.text.isEmpty || _image == null) return;
    _isLoading = true;
    (context as Element).markNeedsBuild();

    String? imageUrl = await _uploadImage(_image!);
    if (imageUrl == null) {
      _isLoading = false;
      (context as Element).markNeedsBuild();
      return;
    }

    DocumentReference categoryRef = await FirebaseFirestore.instance.collection('categories1').add({
      'name': _nameController.text,
      'imageUrl': imageUrl,
    });

    for (String subCategoryName in _subCategories) {
      await categoryRef.collection('subCategories').add({'name': subCategoryName});
    }

    _isLoading = false;
    (context as Element).markNeedsBuild();
    Navigator.of(context).pop();
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Kategori Ekle"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "Kategori Adı"),
                  ),
                  SizedBox(height: 10),
                  _image != null
                      ? Text("Fotoğraf seçildi")
                      : ElevatedButton(
                    onPressed: () => _pickImage(context),
                    child: Text("Fotoğraf Seç"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subCategoryController,
                          decoration: InputDecoration(labelText: "Alt Kategori Ekle"),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: () {
                          if (_subCategoryController.text.isNotEmpty) {
                            setState(() {
                              _subCategories.add(_subCategoryController.text);
                              _subCategoryController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 5,
                    children: _subCategories
                        .map(
                          (sub) => Chip(
                        label: Text(sub),
                        onDeleted: () {
                          setState(() {
                            _subCategories.remove(sub);
                          });
                        },
                      ),
                    )
                        .toList(),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("İptal"),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _createCategory(context),
                  child: _isLoading ? CircularProgressIndicator() : Text("Ekle"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddCategoryDialog(context),
      child: Icon(Icons.add),
    );
  }
}



