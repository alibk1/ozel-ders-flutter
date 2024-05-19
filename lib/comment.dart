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
