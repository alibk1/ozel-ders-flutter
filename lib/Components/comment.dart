import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../FirebaseController.dart'; // FirestoreService'i kullanmak için

class CommentRatingWidget extends StatefulWidget {
  final String courseId;
  final double paddingInset;

  CommentRatingWidget({required this.courseId, required this.paddingInset});

  @override
  _CommentRatingWidgetState createState() => _CommentRatingWidgetState();
}

class _CommentRatingWidgetState extends State<CommentRatingWidget> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _rating = 0;
  List<Map<String, dynamic>> _comments = []; // Yorumları tutan liste
  bool _isLoading = true; // Yorumlar yüklenirken göstermek için

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  void _initializeDateFormatting() async {
    await initializeDateFormatting('tr_TR', null);
    _loadExistingComment();
    _loadComments();
  }

  void _loadExistingComment() async {
    String uid = AuthService().userUID();
    if (uid != "") {
      final commentRef = _firestore
          .collection('courses')
          .doc(widget.courseId)
          .collection('Comments')
          .doc(uid);

      final commentSnapshot = await commentRef.get();
      if (commentSnapshot.exists) {
        setState(() {
          _controller.text = commentSnapshot['comment'] ?? '';
          _rating = commentSnapshot['rating'] ?? 0;
        });
      }
    }
  }

  void _loadComments() async {
    final commentsRef = _firestore
        .collection('courses')
        .doc(widget.courseId)
        .collection('Comments');

    final snapshot = await commentsRef
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> comments = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();
      data['timestamp'] = data['timestamp'] ?? Timestamp.now();
      String userId = data['userId'];

      // Yorumu yapan kullanıcının bilgilerini al
      Map<String, dynamic> userInfo = await FirestoreService().getStudentByUID(userId);

      data['userName'] = userInfo['name'] ?? 'Anonim';
      data['profilePictureUrl'] = userInfo['profilePictureUrl'] ?? '';

      comments.add(data);
    }

    setState(() {
      _comments = comments;
      _isLoading = false;
    });
  }

  void _sendCommentAndRating() async {
    final String comment = _controller.text;
    if (_rating > 0) {
      String uid = AuthService().userUID();
      if (uid != "") {
        // Kullanıcının bu kursu aldığı randevuları al
        var userApps = await FirestoreService().getUserAppointments(uid, false);
        var relatedApps = userApps.where((app) => app["courseId"] == widget.courseId).toList();

        // Randevuların tarihlerini al ve sıralama yap
        relatedApps = relatedApps.where((app) => app['date'] != null).toList();
        relatedApps.sort((a, b) => a['date'].toDate().compareTo(b['appointmentDate'].toDate()));

        // Kullanıcının bu kurs için yaptığı yorumları al
        final commentsRef = _firestore.collection('courses').doc(widget.courseId).collection('Comments');
        var userCommentsSnapshot = await commentsRef.where('userId', isEqualTo: uid).orderBy('timestamp').get();

        List<Map<String, dynamic>> unCommentedAppointments;

        if (userCommentsSnapshot.docs.isNotEmpty) {
          var lastCommentTimestamp = userCommentsSnapshot.docs.last['timestamp'];
          unCommentedAppointments = relatedApps.where((app) => app['date'].toDate().isAfter(lastCommentTimestamp.toDate())).toList();
        } else {
          // Kullanıcı daha önce yorum yapmamışsa tüm randevularını al
          unCommentedAppointments = relatedApps;
        }

        if (unCommentedAppointments.isNotEmpty) {
          int unCommentedSessionsCount = unCommentedAppointments.length;

          try {
            // Firestore işlemi başlat
            await _firestore.runTransaction((transaction) async {
              final courseRef = _firestore.collection('courses').doc(widget.courseId);
              final courseSnapshot = await transaction.get(courseRef);

              if (!courseSnapshot.exists) {
                throw Exception('Kurs bulunamadı');
              }

              final int totalRating = courseSnapshot.data()?['totalRating'] ?? 0;
              final int ratingCount = courseSnapshot.data()?['ratingCount'] ?? 0;

              // Kursun totalRating ve ratingCount değerlerini güncelle
              final int newTotalRating = totalRating + _rating * unCommentedSessionsCount;
              final int newRatingCount = ratingCount + unCommentedSessionsCount;

              // Kurs belgesini güncelle
              transaction.update(courseRef, {
                'totalRating': newTotalRating,
                'ratingCount': newRatingCount,
              });

              // Yeni yorum ekle
              var newCommentRef = commentsRef.doc(); // Yeni bir belge ID'si oluştur
              transaction.set(newCommentRef, {
                'userId': uid,
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
              _isLoading = true;
            });

            // Yorumları yeniden yükle
            _loadComments();
          } catch (e, stacktrace) {
            // Hata durumunda kullanıcıya mesaj göster
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Yorum ve puan gönderilirken bir hata oluştu: $e')),
            );
            print('Hata: $e');
            print('Stacktrace: $stacktrace');
          }
        } else {
          // Kullanıcının yorum yapabileceği randevusu yok
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu kurs için daha fazla yorum yapamazsınız.')),
          );
        }
      } else {
        // Kullanıcı oturum açmamışsa uygun bir mesaj göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Yorum ve puan vermek için lütfen oturum açın.')),
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
      padding: EdgeInsets.all(widget.paddingInset),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Yorumlar bölümü
                _isLoading
                    ? Center(
                  child: CircularProgressIndicator(),
                )
                    : _comments.isNotEmpty
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yorumlar',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF393E46)),
                          textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return Card(
                          color: Color(0xFF393E46), // Arka plan rengi
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                              comment['profilePictureUrl'] != ''
                                  ? NetworkImage(
                                  comment['profilePictureUrl'])
                                  : null,
                              backgroundColor: Color(0xFF76ABAE),
                              child: comment['profilePictureUrl'] == ''
                                  ? Text(
                                comment['userName'] != null &&
                                    comment['userName']
                                        .length >
                                        0
                                    ? comment['userName'][0]
                                    : 'A',
                                style: TextStyle(
                                    color: Colors.white),
                              )
                                  : null,
                            ),
                            title: Text(
                              comment['userName'] ?? 'Anonim',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children:
                                  List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex <
                                          (comment['rating'] ??
                                              0)
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16.0,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  comment['comment'] ?? '',
                                  style: TextStyle(
                                      color: Colors.white70),
                                ),
                                const SizedBox(height: 4.0),
                                if (comment['timestamp'] != null)
                                  Text(
                                    DateFormat('dd MMM yyyy, HH:mm',
                                        'tr_TR')
                                        .format(comment['timestamp']
                                        .toDate()),
                                    style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )
                    : const Text(
                  'Henüz yorum yok.',
                  style: TextStyle(color: Color(0xFF393E46), fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                Card(
                  color: Color(0xFF393E46), // Arka plan rengini ayarladık
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
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Yorumunuzu yazın',
                            labelStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white70, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white, width: 1.0),
                            ),
                          ),
                          maxLines: screenWidth < 800 ? 2 : 3,
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Puan verin',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                _rating > index
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: screenWidth < 800 ? 28.0 : 32.0,
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
                            backgroundColor: Color(0xFF76ABAE),
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            textStyle: TextStyle(
                              fontSize: screenWidth < 800 ? 16.0 : 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
