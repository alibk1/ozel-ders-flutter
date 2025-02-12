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
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> teachers;

  const TopCoursesWidget({
    required this.onSeeAllPressed,
    required this.courses,
    required this.teachers,
    Key? key,
  }) : super(key: key);

  @override
  _TopCoursesWidgetState createState() => _TopCoursesWidgetState();
}

class _TopCoursesWidgetState extends State<TopCoursesWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
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
                'En İyi Danışmanlıklar',
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
                    color: Color(0xFF3C72C2),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (widget.courses.isEmpty)
            Center(child: Text('Gösterilecek kurs bulunamadı'))
          else if (isMobile)
            _buildMobileCourseList(widget.courses)
          else
            _buildDesktopCourseGrid(widget.courses),
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
                  author: widget.teachers.firstWhere(
                        (teacher) => teacher["uid"] == topCourses[index]["author"],
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
                    author: widget.teachers.firstWhere(
                          (teacher) => teacher["uid"] == topCourses[index]["author"],
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
