import 'dart:convert';

import 'package:flutter/material.dart';
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

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

      // Status'e göre sıralama
      loadedCourses.sort((a, b) => (a['status'] as int).compareTo(b['status'] as int));
      loadedBlogs.sort((a, b) => (a['status'] as int).compareTo(b['status'] as int));

      setState(() {
        courses = loadedCourses;
        blogs = loadedBlogs;
        categories = loadedCategories;
        students = loadedStudents;
        teachers = loadedTeachers;
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
            Tab(text: 'Terapiler'),
            Tab(text: 'Bloglar'),
            Tab(text: 'Kategoriler'),
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
                firestoreService.acceptBlog(blog['uid']);
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
                _showDenyBlogDialog(context, blog['uid']);
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
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        var category = categories[index];
        return ListTile(
          title: Text(category['name']),
          subtitle: Text('${category['subCategories'].length} Alt Kategoriler'),
          onTap: () {
            _showCategoryEditor(context, category);
          },
        );
      },
    );
  }

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
                  firestoreService.editCategory(category['uid'], categoryNameController.text);
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
}