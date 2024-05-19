import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentWidget extends StatefulWidget {
  final String courseId; // Yorumun ekleneceği kursun ID'si

  CommentWidget({required this.courseId});

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendComment() async {
    final String comment = _controller.text;
    if (comment.isNotEmpty) {
      User? user = _auth.currentUser;

      if (user != null) {
        // Yorum verisini Firestore'a ekle
        await _firestore.collection('courses').doc(widget.courseId).collection('Comments').add({
          'userId': user.uid,
          'userName': user.displayName ?? 'Anonim',
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
          'email': user.email,
        });

        _controller.clear(); // Yorum gönderildikten sonra metin alanını temizle
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorum Başarıyla Gönderildi.')),
        );
      } else {
        // Kullanıcı oturum açmamışsa uygun bir mesaj göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorum göndermek için lütfen oturum açın.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Yorumunuzu yazın',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: _sendComment,
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }
}

class RatingWidget extends StatefulWidget {
  final String courseId; // Puanın ekleneceği kursun ID'si

  RatingWidget({required this.courseId});

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _rating = 0;

  void _sendRating() async {
    if (_rating > 0) {
      User? user = _auth.currentUser;

      if (user != null) {
        final courseRef = _firestore.collection('Courses').doc(widget.courseId);
        final ratingRef = courseRef.collection('Ratings').doc();

        try {
          // Firestore işlemi başlat
          await _firestore.runTransaction((transaction) async {
            final courseSnapshot = await transaction.get(courseRef);

            if (!courseSnapshot.exists) {
              throw Exception('Kurs bulunamadı');
            }

            final int totalRating = courseSnapshot.data()?['totalRating'] ?? 0;
            final int ratingCount = courseSnapshot.data()?['ratingCount'] ?? 0;

            final newTotalRating = totalRating + _rating;
            final newRatingCount = ratingCount + 1;

            // Kurs belgesini güncelle
            transaction.update(courseRef, {
              'totalRating': newTotalRating,
              'ratingCount': newRatingCount,
            });

            // Kullanıcının puanını Ratings koleksiyonuna ekle
            transaction.set(ratingRef, {
              'userId': user.uid,
              'userName': user.displayName ?? 'Anonim',
              'rating': _rating,
              'timestamp': FieldValue.serverTimestamp(),
            });
          });

          // Kullanıcıya başarılı olduğunu gösteren bir mesaj göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Puanınız gönderildi!')),
          );
        } catch (e, stacktrace) {
          // Hata durumunda kullanıcıya mesaj göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Puan gönderilirken bir hata oluştu.')),
          );
          print('Hata: $e');
          print('Stacktrace: $stacktrace');
        }
      } else {
        // Kullanıcı oturum açmamışsa uygun bir mesaj göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Puan vermek için lütfen oturum açın.')),
        );
      }
    } else {
      // Puan verilmediği durumda kullanıcıyı uyar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen bir puan seçin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                _rating > index ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _rating = index + 1;
                });
              },
            );
          }),
        ),
        SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: _sendRating,
          child: Text('Puanı Gönder'),
        ),
      ],
    );
  }
}
