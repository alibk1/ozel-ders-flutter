import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TeacherCard extends StatelessWidget {
  final Map<String, dynamic> teacherData;
  final List<Map<String, dynamic>> teacherCourses;

  const TeacherCard({
    required this.teacherData,
    required this.teacherCourses,
    Key? key,
  }) : super(key: key);

  // Kursların ortalama puanını hesapla
  double _calculateAverageRating() {
    if (teacherCourses.isEmpty) return 0.0;

    double totalRating = 0.0;
    int totalComments = 0;

    for (var course in teacherCourses) {
      if (course['comments'] != null && course['comments'].isNotEmpty) {
        for (var comment in course['comments']) {
          totalRating += comment['rating'] ?? 0.0;
          totalComments++;
        }
      }
    }

    return totalComments > 0 ? totalRating / totalComments : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;
    double averageRating = _calculateAverageRating();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Öğretmen detay sayfasına yönlendirme
          // context.go('/teacher/${teacherData["UID"]}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profil Resmi
              CircleAvatar(
                radius: isMobile ? 40 : 60,
                backgroundImage: NetworkImage(teacherData['profilePictureUrl']),
              ),
              SizedBox(height: 16),

              // Öğretmen Adı
              Text(
                teacherData['name'],
                style: TextStyle(
                  fontSize: isMobile ? 18 : 24,
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
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),

              // Ortalama Puan
              RatingBar.builder(
                initialRating: averageRating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: isMobile ? 24 : 32,
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
                  fontSize: isMobile ? 14 : 16,
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