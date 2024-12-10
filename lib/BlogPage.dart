import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/BlogCommentWidget.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:zefyrka/zefyrka.dart';
import 'Components/Drawer.dart';

class BlogPage extends StatefulWidget {
  final String blogUID;

  const BlogPage({required this.blogUID});

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  Map<String, dynamic>? blogData;
  Map<String, dynamic>? authorData;
  bool isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    loadBlogData();
  }

  Future<void> loadBlogData() async {
    try {
      FirestoreService firestoreService = FirestoreService();
      isLoggedIn = await AuthService().isUserSignedIn();
      blogData = await firestoreService.getBlog(widget.blogUID);
      authorData = await firestoreService.getTeacherByUID(blogData!['creatorUID']);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading blog data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _customEmbedBuilder(BuildContext context, EmbedNode node) {
    final String? imageUrl = node.value.data['source'];
    if (node.value.type == 'image' && imageUrl != null) {
      if (imageUrl.startsWith('data:image')) {
        final base64Data = imageUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Image.memory(bytes, fit: BoxFit.cover),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Image.network(imageUrl, fit: BoxFit.cover),
        );
      }
    }
    throw UnimplementedError(
        'Embeddable type "${node.value.type}" is not supported by the custom embed builder.');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF222831),
        title: Image.asset(
          'assets/vitament1.png',
          height: isMobile ? 60 : 80,
        ),
        centerTitle: isMobile,
        leading: isMobile
            ? IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        )
            : null,
        actions: !isMobile
            ? [
          TextButton(
            onPressed: () {
              context.go('/');
            },
            child: Text('Ana Sayfa',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/categories');
            },
            child: Text('Kategoriler',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/courses');
            },
            child: Text('Kurslar',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.go('/blogs');
            },
            child: Text('Blog',
                style: TextStyle(
                    color: Color(0xFF76ABAE),
                    fontWeight: FontWeight.bold)),
          ),
          isLoggedIn
              ? TextButton(
            onPressed: () {
              context.go('/appointments/' + AuthService().userUID());
            },
            child: Text('Randevularım',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          )
              : SizedBox.shrink(),
          TextButton(
            onPressed: isLoggedIn
                ? () {
              context.go('/profile/' + AuthService().userUID());
            }
                : () {
              context.go('/login');
            },
            child: Text(isLoggedIn ? 'Profilim' : 'Giriş Yap / Kaydol',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]
            : null,
      ),
      drawer: isMobile ? DrawerMenu(isLoggedIn: isLoggedIn) : null,
      body: isLoading
          ? Center(
        child: LoadingAnimationWidget.dotsTriangle(
            color: Color(0xFF222831), size: 200),
      )
          : blogData == null
          ? Center(
        child: Text('Blog bulunamadı.'),
      )
          : Stack(
        children: [
          // Arka plan resmi
          Positioned.fill(
            child: Image.asset(
              "assets/therapy-main.jpg",
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Container(
                    // İçeriği yarı saydam bir kutu içinde gösteriyoruz
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık
                        Text(
                          blogData!['title'] ?? 'Başlık Yok',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF393E46),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Yazar Bilgisi
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage: authorData != null &&
                                authorData!['profilePictureUrl'] !=
                                    null
                                ? NetworkImage(
                                authorData!['profilePictureUrl'])
                                : null,
                            backgroundColor: Color(0xFF76ABAE),
                            child: authorData != null &&
                                (authorData![
                                'profilePictureUrl'] ==
                                    null ||
                                    authorData![
                                    'profilePictureUrl'] ==
                                        '')
                                ? Text(
                              authorData!['name'] != null &&
                                  authorData!['name']
                                      .length >
                                      0
                                  ? authorData!['name'][0]
                                  : 'A',
                              style:
                              TextStyle(color: Colors.white),
                            )
                                : null,
                          ),
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                authorData != null
                                    ? authorData!['name'] ?? 'Anonim'
                                    : 'Anonim',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF393E46),
                                ),
                                textAlign: TextAlign.start,
                              ),
                              IconButton(onPressed: (){ context.go("/profile/${authorData!['uid']}"); }, icon: Icon(Ionicons.eye))
                            ],
                          ),
                          subtitle: Text(
                            'Yayınlanma Tarihi: ${blogData!['createdAt'] != null ? blogData!['createdAt'].toDate().toString().split(' ')[0] : ''}',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // İçerik
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade300),
                          ),
                          padding: EdgeInsets.all(12.0),
                          child: ZefyrEditor(
                            controller: ZefyrController(
                              NotusDocument.fromJson(
                                jsonDecode(blogData!['content']),
                              ),
                            ),
                            readOnly: true,
                            padding: EdgeInsets.zero,
                            embedBuilder: _customEmbedBuilder,
                            showCursor: false,
                          ),
                        ),
                        SizedBox(height: 24),
                        // Yorumlar
                        Text(
                          'Yorumlar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF393E46),
                          ),
                        ),
                        SizedBox(height: 16),
                        BlogCommentWidget(
                          blogUID: widget.blogUID,
                          paddingInset: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
