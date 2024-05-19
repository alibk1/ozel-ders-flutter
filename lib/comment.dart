import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentRatingWidget extends StatefulWidget {
  final String courseId; // Yorumun ve puanın ekleneceği kursun ID'si

  CommentRatingWidget({required this.courseId});

  @override
  _CommentRatingWidgetState createState() => _CommentRatingWidgetState();
}

class _CommentRatingWidgetState extends State<CommentRatingWidget> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _loadExistingComment();
  }

  void _loadExistingComment() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final commentRef = _firestore
          .collection('Courses')
          .doc(widget.courseId)
          .collection('Comments')
          .doc(user.uid);

      final commentSnapshot = await commentRef.get();
      if (commentSnapshot.exists) {
        setState(() {
          _controller.text = commentSnapshot['comment'] ?? '';
          _rating = commentSnapshot['rating'] ?? 0;
        });
      }
    }
  }

  void _sendCommentAndRating() async {
    final String comment = _controller.text;
    if (_rating > 0) {
      User? user = _auth.currentUser;

      if (user != null) {
        final courseRef = _firestore.collection('courses').doc(widget.courseId);
        final commentRef = courseRef.collection('Comments').doc(user.uid);

        try {
          // Firestore işlemi başlat
          await _firestore.runTransaction((transaction) async {
            final courseSnapshot = await transaction.get(courseRef);

            if (!courseSnapshot.exists) {
              throw Exception('Kurs bulunamadı');
            }

            final int totalRating = courseSnapshot.data()?['totalRating'] ?? 0;
            final int ratingCount = courseSnapshot.data()?['ratingCount'] ?? 0;

            final int oldRating = (await commentRef.get()).data()?['rating'] ?? 0;
            final newTotalRating = totalRating - oldRating + _rating;

            // Kurs belgesini güncelle
            transaction.update(courseRef, {
              'totalRating': newTotalRating,
              'ratingCount': ratingCount,
            });

            // Kullanıcının yorumunu ve puanını Comments koleksiyonuna ekle veya güncelle
            transaction.set(commentRef, {
              'userId': user.uid,
              'userName': user.displayName ?? 'Anonim',
              'comment': comment.isNotEmpty ? comment : null,
              'rating': _rating,
              'timestamp': FieldValue.serverTimestamp(),
            });
          });

          // Kullanıcıya başarılı olduğunu gösteren bir mesaj göster
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yorumunuz ve puanınız gönderildi!')),
          );

          // Metin alanını ve puanı sıfırla
          _controller.clear();
          setState(() {
            _rating = 0;
          });
        } catch (e, stacktrace) {
          // Hata durumunda kullanıcıya mesaj göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Yorum ve puan gönderilirken bir hata oluştu: $e')),
          );
          print('Hata: $e');
          print('Stacktrace: $stacktrace');
        }
      } else {
        // Kullanıcı oturum açmamışsa uygun bir mesaj göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorum ve puan vermek için lütfen oturum açın.')),
        );
      }
    } else {
      // Puan verilmediği durumda kullanıcıyı uyar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir puan verin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Maksimum genişlik ayarı
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Yorumunuzu yazın',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: screenWidth < 600 ? 2 : 3, // Küçük ekranlarda max satır sayısını azalt
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Puan verin',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          _rating > index ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: screenWidth < 600 ? 28.0 : 32.0, // Küçük ekranlarda yıldız boyutunu azalt
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _sendCommentAndRating,
                    child: const Text('Gönder'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: TextStyle(
                        fontSize: screenWidth < 600 ? 16.0 : 18.0, // Küçük ekranlarda yazı boyutunu azalt
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
