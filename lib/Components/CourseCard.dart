import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CourseCard extends StatefulWidget {
  final Map<String, dynamic> course;
  final Map<String, dynamic> author;

  const CourseCard({
    required this.course,
    required this.author,
    Key? key,
  }) : super(key: key);

  @override
  _CourseCardState createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool isHovered = false;

  // Rating ortalamasını hesapla
  double _calculateAverageRating() {
    if (widget.course['comments'] == null || widget.course['comments'].isEmpty) {
      return 0.0;
    }
    double totalRating = 0.0;
    for (var comment in widget.course['comments']) {
      totalRating += comment['rating'] ?? 0.0;
    }
    return totalRating.toDouble() / widget.course['comments'].length;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;
    double averageRating = _calculateAverageRating();

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, isHovered ? -5.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.go('/courses/${widget.course["UID"]}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  widget.course['photos'][0], // İlk fotoğrafı göster
                  fit: BoxFit.cover,
                  height: isMobile ? 150 : 200,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course['name'],
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.author["name"],
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${widget.course['hourlyPrice']} TL",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Rating Bar'ı göster
                        RatingBar.builder(
                          initialRating: averageRating,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 20,
                          itemBuilder: (context, _) => Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          onRatingUpdate: (rating) {
                            // Rating güncelleme işlemi (isteğe bağlı)
                          },
                          ignoreGestures: true, // Kullanıcı rating değiştiremesin
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}