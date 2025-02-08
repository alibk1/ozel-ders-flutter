import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/CourseCard.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class TopCoursesWidget extends StatefulWidget {
  final Function onSeeAllPressed;

  const TopCoursesWidget({
    required this.onSeeAllPressed,
    Key? key,
  }) : super(key: key);

  @override
  _TopCoursesWidgetState createState() => _TopCoursesWidgetState();
}

class _TopCoursesWidgetState extends State<TopCoursesWidget> {
  final FirestoreService _firestore = FirestoreService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _teachers = [];
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
        _firestore.getAllCourses(),
        _firestore.getAllTeachers(),
        _firestore.getAllAppointments(),
        _firestore.getAllBlogs(),
      ]);

      setState(() {
        _courses = results[0] ?? [];
        _teachers = results[1] ?? [];
        _appointments = results[2] ?? [];
        _blogs = results[3] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Veri çekme hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getSortedCourses() {
    if (_isLoading || _courses.isEmpty) return [];

    List<Map<String, dynamic>> sortedCourses = List.from(_courses);
    sortedCourses.sort((a, b) {
      double scoreA = _calculateCourseScore(a);
      double scoreB = _calculateCourseScore(b);
      return scoreB.compareTo(scoreA);
    });

    return sortedCourses.take(5).toList();
  }

  double _calculateCourseScore(Map<String, dynamic> course) {
    String authorUID = course['author'] ?? '';

    int teacherCourseCount = _courses
        .where((c) => c['author'] == authorUID)
        .length;
    double courseCountScore = teacherCourseCount * 3;

    double ratingSum = (course['comments'] as List?)?.fold(
        0.0, (sum, comment) => sum! + (comment['rate'] ?? 0.0)) ??
        0.0;
    int appointmentCount = _appointments
        .where((app) => app['author'] == authorUID)
        .length;
    int blogCount = _blogs
        .where((blog) => blog['creatorUID'] == authorUID)
        .length;

    return courseCountScore + ratingSum + appointmentCount + (blogCount * 2);
  }
  Future<void> _updatePopularity(courseUid,int updatePopularity) async {
    final db = FirebaseFirestore.instance;

    final docRef = db.collection("courses").doc(courseUid);
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

    final topCourses = _getSortedCourses();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 170, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'En İyi Terapiler',
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
          if (topCourses.isEmpty)
            Center(child: Text('Gösterilecek kurs bulunamadı'))
          else if (isMobile)
            _buildMobileCourseList(topCourses)
          else
            _buildDesktopCourseGrid(topCourses),
        ],
      ),
    );
  }

  Widget _buildDesktopCourseGrid(List<Map<String, dynamic>> topCourses) {
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Scroll'u devre dışı bırak
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 5 sütun
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemCount: topCourses.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: Duration(milliseconds: 500),
            columnCount: 5,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: CourseCard(
                  course: topCourses[index],
                  author: _teachers.firstWhere(
                        (teacher) => teacher["UID"] == topCourses[index]["author"],
                    orElse: () => {},
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileCourseList(List<Map<String, dynamic>> topCourses) {
    return SizedBox(
      height: 320, // Sabit yükseklik
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topCourses.length,
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
                  child: CourseCard(
                    course: topCourses[index],
                    author: _teachers.firstWhere(
                          (teacher) => teacher["UID"] == topCourses[index]["author"],
                      orElse: () => {},
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
