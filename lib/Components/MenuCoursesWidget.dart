import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ozel_ders/Components/CourseCard.dart';

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
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;
      double horizontalPadding = width < 800 ? width * 0.05 : width * 0.1;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve "Tümünü Gör" butonu
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
            else
            // Responsive grid: her kartın maksimum genişliği 300px
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemCount: widget.courses.length,
                itemBuilder: (context, index) {
                  final course = widget.courses[index];
                  final teacher = widget.teachers.firstWhere(
                        (teacher) => teacher["uid"] == course["author"],
                    orElse: () => {},
                  );
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: Duration(milliseconds: 500),
                    columnCount: (width / 300).floor(),
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: CourseCard(
                          course: course,
                          author: teacher,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      );
    });
  }
}
