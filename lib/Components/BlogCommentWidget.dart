import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/FirebaseController.dart';

class BlogCommentWidget extends StatefulWidget {
  final String blogUID;
  final double paddingInset;

  BlogCommentWidget({required this.blogUID, required this.paddingInset});

  @override
  _BlogCommentWidgetState createState() => _BlogCommentWidgetState();
}

class _BlogCommentWidgetState extends State<BlogCommentWidget> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool isLoggedIn = false;
  String currentUserUID = '';

  // HomePage'dan alınan renk şeması
  final Color _primaryColor = Color(0xFFA7D8DB);
  final Color _backgroundColor = Color(0xFFEEEEEE);
  final Color _darkColor = Color(0xFF3C72C2);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    isLoggedIn = await AuthService().isUserSignedIn();
    if (isLoggedIn) {
      currentUserUID = AuthService().userUID();
    }
    _loadComments();
  }

  void _loadComments() async {
    final commentsRef = _firestore
        .collection('blogs')
        .doc(widget.blogUID)
        .collection('comments');

    final snapshot = await commentsRef.orderBy('commentedAt').get();

    List<Map<String, dynamic>> comments = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();
      data['commentedAt'] = data['commentedAt'] ?? Timestamp.now();
      String commenterUID = data['commenterUID'];

      // Yorumu yapan kullanıcının bilgilerini al
      Map<String, dynamic> userInfo = await FirestoreService().getTeacherByUID(commenterUID);
      if (userInfo.isEmpty) {
        userInfo = await FirestoreService().getStudentByUID(commenterUID);
      }

      data['userName'] = userInfo['name'] ?? 'Anonim';
      data['profilePictureUrl'] = userInfo['profilePictureUrl'] ?? '';

      comments.add(data);
    }

    setState(() {
      _comments = comments;
      _isLoading = false;
    });
  }

  void _sendComment() async {
    final String comment = _controller.text.trim();
    if (comment.isNotEmpty) {
      if (isLoggedIn) {
        String uid = currentUserUID;

        try {
          await _firestore
              .collection('blogs')
              .doc(widget.blogUID)
              .collection('comments')
              .add({
            'commenterUID': uid,
            'comment': comment,
            'commentedAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yorumunuz gönderildi!')),
          );

          // Metin alanını sıfırla
          _controller.clear();
          setState(() {
            _isLoading = true;
          });

          // Yorumları yeniden yükle
          _loadComments();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Yorum gönderilirken bir hata oluştu: $e')),
          );
        }
      } else {
        // Kullanıcı oturum açmamışsa uygun bir mesaj göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorum yapmak için lütfen oturum açın.')),
        );
      }
    } else {
      // Yorum boşsa kullanıcıyı uyar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir yorum yazın.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(widget.paddingInset),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Yorumlar bölümü
              _isLoading
                  ? Center(
                child: SpinKitFadingCircle(
                  color: _primaryColor,
                  size: 50.0,
                ),
              )
                  : _comments.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return GlassmorphicContainer(
                        width: double.infinity,
                        height: 120,
                        borderRadius: 20,
                        blur: 20,
                        alignment: Alignment.bottomCenter,
                        border: 2,
                        linearGradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderGradient: LinearGradient(
                          colors: [Colors.white24, Colors.white12],
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage:
                              comment['profilePictureUrl'] != ''
                                  ? NetworkImage(
                                  comment['profilePictureUrl'])
                                  : null,
                              backgroundColor: _primaryColor,
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
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment['userName'] ?? 'Anonim',
                                    style: TextStyle(
                                        color: _darkColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    comment['comment'] ?? '',
                                    style: TextStyle(
                                        color: _darkColor.withOpacity(0.7)),
                                  ),
                                  const SizedBox(height: 4.0),
                                  if (comment['commentedAt'] != null)
                                    Text(
                                      DateFormat('dd MMM yyyy, HH:mm')
                                          .format(comment['commentedAt']
                                          .toDate()),
                                      style: const TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
                  : const Text(
                'Henüz yorum yok.',
                style: TextStyle(
                    color: Color(0xFF393E46),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              GlassmorphicContainer(
                width: double.infinity,
                height: 200,
                borderRadius: 20,
                blur: 20,
                alignment: Alignment.bottomCenter,
                border: 2,
                linearGradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderGradient: LinearGradient(
                  colors: [Colors.white24, Colors.white12],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: _controller,
                      style: TextStyle(color: _darkColor),
                      decoration: InputDecoration(
                        labelText: 'Yorumunuzu yazın',
                        labelStyle: TextStyle(color: _darkColor.withOpacity(0.7)),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: _darkColor.withOpacity(0.7), width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: _primaryColor, width: 1.0),
                        ),
                      ),
                      maxLines: screenWidth < 800 ? 2 : 3,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _sendComment,
                      child: const Text('Gönder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
            ],
          ),
        ),
      ),
    );
  }
}
