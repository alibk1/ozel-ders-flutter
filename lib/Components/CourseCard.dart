import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

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

  List<DateTime> get2Closest() {
    // Firestore'dan gelen Timestamp listesini alıyoruz.
    List availables = widget.author["availableHours"] ?? [];
    if (availables.isEmpty) return [];

    // Timestamp'leri DateTime'a dönüştürüyoruz.
    List<DateTime> dates = availables.map<DateTime>((ts) => ts.toDate()).toList();

    // Eğer 1 veya 2 değer varsa, direkt döndür.
    if (dates.length <= 2) return dates;

    DateTime now = DateTime.now();
    // Tarihleri, now'a olan farklarının mutlak değerine göre sıralıyoruz.
    dates.sort((a, b) {
      int diffA = (a.difference(now).inMilliseconds).abs();
      int diffB = (b.difference(now).inMilliseconds).abs();
      return diffA.compareTo(diffB);
    });

    // En yakın iki tarihi döndür.
    return dates.take(2).toList();
  }

  String formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day.$month - $hour.$minute';
  }


  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;
    double averageRating = _calculateAverageRating();
    List<DateTime> closest2 = get2Closest();
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
            context.go('/course/${widget.course["UID"]}');
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
                    /*SizedBox(height: 3,),
                    Text(
                      'En Yakın Müsaitlik',
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 500.ms),
                    SizedBox(height: 3,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if(closest2.length > 0) Container(
                          padding: EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${formatDateTime(closest2[0])}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if(closest2.length > 1) Container(
                          padding: EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${formatDateTime(closest2[1])}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )

                     */
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