import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class TopTeachersWidget extends StatefulWidget {
  final Function onSeeAllPressed;

  const TopTeachersWidget({
    required this.onSeeAllPressed,
    Key? key,
  }) : super(key: key);

  @override
  _TopTeachersWidgetState createState() => _TopTeachersWidgetState();
}

class _TopTeachersWidgetState extends State<TopTeachersWidget> {
  final FirestoreService _firestore = FirestoreService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _blogs = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        _firestore.getAllTeachers(),
        _firestore.getAllCourses(),
        _firestore.getAllAppointments(),
        _firestore.getAllBlogs(),
      ]);

      setState(() {
        _teachers = results[0] ?? [];
        _courses = results[1] ?? [];
        _appointments = results[2] ?? [];
        _blogs = results[3] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Veri çekme hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getSortedTeachers() {
    if (_isLoading || _teachers.isEmpty) return [];

    List<Map<String, dynamic>> sortedTeachers = List.from(_teachers);
    sortedTeachers.sort((a, b) {
      double scoreA = _calculateTeacherScore(a);
      double scoreB = _calculateTeacherScore(b);
      return scoreB.compareTo(scoreA);
    });

    return sortedTeachers.take(5).toList();
  }

  double _calculateTeacherScore(Map<String, dynamic> teacher) {
    String teacherUID = teacher['UID'] ?? '';

    // Öğretmenin kurslarını bul
    List<Map<String, dynamic>> teacherCourses = _courses
        .where((course) => course['author'] == teacherUID)
        .toList();

    // Kursların yorumlarından toplam puanı hesapla
    double totalRating = teacherCourses.fold(0.0, (sum, course) {
      List<dynamic> comments = course['comments'] ?? [];
      double courseRating = comments.fold(0.0, (sum, comment) => sum + (comment['rating'] ?? 0.0));
      return sum + courseRating;
    });

    // Randevu sayısı
    int appointmentCount = _appointments
        .where((app) => app['author'] == teacherUID)
        .length;

    // Blog sayısı
    int blogCount = _blogs
        .where((blog) => blog['creatorUID'] == teacherUID)
        .length;

    // Toplam puan: Kurs puanları + randevu sayısı + blog sayısı * 2
    return totalRating + appointmentCount + (blogCount * 2);
  }
  Future<void> _updatePopularity(teacherUid,int updatePopularity) async {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection("teachers").doc(teacherUid);
    final courseSnapshot = await docRef.get();
    if (courseSnapshot.exists) {
      Map<String, dynamic> data = courseSnapshot.data()!;
      if (data['popularity'] != null) {
        print('Popularity: ${data['popularity']}');
        // Popularityi güncelle
        int currentPopularity = data['popularity'];
        int newPopularity = currentPopularity + updatePopularity;
        await docRef.update({'popularity': newPopularity});
        print('Popularity güncellendi: $newPopularity');
      } else {
        print('Popularity alanı bu dökümanda mevcut değil.');
      }
    }
    else {
      print('Document does not exist.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (_isLoading) {
      return Center(
        child: LoadingAnimationWidget.twistingDots(
          leftDotColor: Color(0xFF222831),
          rightDotColor: Color(0xFF663366),
          size: 100,
        ),
      );
    }

    final topTeachers = _getSortedTeachers();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 170, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'En İyi Öğretmenler',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222831),
                ),
              ),
              TextButton(
                onPressed: () => widget.onSeeAllPressed(),
                child: Text(
                  'Tümünü Gör',
                  style: TextStyle(
                    color: Color(0xFFEEEEEE),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (topTeachers.isEmpty)
            Center(child: Text('Gösterilecek öğretmen bulunamadı'))
          else if (isMobile)
            _buildMobileTeacherList(topTeachers)
          else
            _buildDesktopTeacherGrid(topTeachers),
        ],
      ),
    );
  }

  Widget _buildDesktopTeacherGrid(List<Map<String, dynamic>> topTeachers) {
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Scroll'u devre dışı bırak
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 5 sütun
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: topTeachers.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: Duration(milliseconds: 500),
            columnCount: 5,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildTeacherCard(topTeachers[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileTeacherList(List<Map<String, dynamic>> topTeachers) {
    return SizedBox(
      height: 280, // Sabit yükseklik
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topTeachers.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 500),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  width: 280,
                  margin: EdgeInsets.only(right: 16),
                  child: _buildTeacherCard(topTeachers[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    String teacherUID = teacher['UID'] ?? '';
    List<Map<String, dynamic>> teacherCourses = _courses
        .where((course) => course['author'] == teacherUID)
        .toList();

    double totalRating = teacherCourses.fold(0.0, (sum, course) {
      List<dynamic> comments = course['comments'] ?? [];
      double courseRating = comments.fold(0.0, (sum, comment) => sum + (comment['rating'] ?? 0.0));
      return sum + courseRating;
    });

    int totalComments = teacherCourses.fold<int>(0, (sum, course) {
      int commentCount = (course['comments'] as List?)?.length ?? 0;
      return sum + commentCount;
    });
    double averageRating = totalComments > 0 ? totalRating / totalComments : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Öğretmen detay sayfasına yönlendirme
          // context.go('/teacher/${teacher["UID"]}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profil Resmi
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(teacher['profilePictureUrl']),
              ),
              SizedBox(height: 16),

              // Öğretmen Adı
              Text(
                teacher['name'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),

              // Kurs Sayısı
              Text(
                '${teacherCourses.length} Kurs',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),
              RatingBar.builder(
                initialRating: averageRating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 24,
                itemBuilder: (context, _) => Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onRatingUpdate: (rating) {
                  // Rating güncelleme işlemi (isteğe bağlı)
                },
                ignoreGestures: true, // Kullanıcı rating değiştiremesin
              ),
              SizedBox(height: 8),

              // Ortalama Puan Metni
              Text(
                'Ortalama Puan: ${averageRating.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
