import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ozel_ders/Components/BlogCommentWidget.dart';
import 'package:ozel_ders/HomePage.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:zefyrka/zefyrka.dart';
import 'Components/Drawer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class BlogPage extends StatefulWidget {
  final String blogUID;

  const BlogPage({required this.blogUID});

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color _primaryColor = Color(0xFFA7D8DB);
  final Color _backgroundColor = Color(0xFFEEEEEE);
  final Color _darkColor = Color(0xFF3C72C2);
  bool _isAppBarExpanded = true;

  Map<String, dynamic>? blogData;
  Map<String, dynamic>? authorData;
  bool isLoading = true;
  bool isLoggedIn = false;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadBlogData();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
      backgroundColor: _backgroundColor,
      drawer: isMobile ? DrawerMenu(isLoggedIn: isLoggedIn) : null,
      body: Stack(
        children: [
          _buildMainContent(isMobile),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_backgroundColor, _primaryColor.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(isMobile),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : MediaQuery.of(context).size.width * 0.2,
                vertical: 20,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (blogData != null) _buildBlogContent(isMobile),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              blogData!['title'] ?? 'Başlık Yok',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.bold,
                color: _darkColor,
              ),
            ),
            SizedBox(height: 16),
            // Yazar Bilgisi
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: authorData != null && authorData!['profilePictureUrl'] != null
                    ? NetworkImage(authorData!['profilePictureUrl'])
                    : null,
                backgroundColor: _primaryColor,
                child: authorData != null && (authorData!['profilePictureUrl'] == null || authorData!['profilePictureUrl'] == '')
                    ? Text(
                  authorData!['name'] != null && authorData!['name'].length > 0
                      ? authorData!['name'][0]
                      : 'A',
                  style: TextStyle(color: Colors.white),
                )
                    : null,
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    authorData != null ? authorData!['name'] ?? 'Anonim' : 'Anonim',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: _darkColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.go("/profile/${authorData!['UID']}");
                    },
                    icon: Icon(Ionicons.eye, color: _primaryColor),
                  ),
                ],
              ),
              subtitle: Text(
                'Yayınlanma Tarihi: ${blogData!['createdAt'] != null ? blogData!['createdAt'].toDate().toString().split(' ')[0] : ''}',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 24),
            // İçerik
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.all(12),
              child: ZefyrEditor(
                controller: ZefyrController(
                  NotusDocument.fromJson(jsonDecode(blogData!['content'])),
                ),
                readOnly: true,
                padding: EdgeInsets.zero,
                embedBuilder: _customEmbedBuilder,
                showCursor: false,
              ),
            ),
            SizedBox(height: 32),
            // Yorumlar
            Text(
              'Yorumlar',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _darkColor,
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
    );
  }

  SliverAppBar _buildAppBar(bool isMobile) {
    return SliverAppBar(
      backgroundColor: Color(0xFFEEEEEE),
      title: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _isAppBarExpanded
            ? Image.asset(
          'assets/AYBUKOM1.png',
          height: isMobile ? 50 : 70,
          key: ValueKey('expanded-logo'),
        ).animate().fadeIn(duration: 500.ms)
            : Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/AYBUKOM1.png',
            height: isMobile ? 40 : 50,
            key: ValueKey('collapsed-logo'),
          ),
        ),
      ),
      centerTitle: isMobile || _isAppBarExpanded,
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final isExpanded = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_isAppBarExpanded != isExpanded) {
              setState(() {
                _isAppBarExpanded = isExpanded;
              });
            }
          });
          return FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          );
        },
      ),
      actions: isMobile ? null : [_buildDesktopMenu()],
      leading: isMobile
          ? IconButton(
        icon: Icon(Icons.menu, color: _darkColor),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      )
          : null,
    );
  }

  Widget _buildDesktopMenu() {
    return Row(
      children: [
        HeaderButton(title: 'Ana Sayfa', route: '/'),
        HeaderButton(title: 'Danışmanlıklar', route: '/courses'),
        HeaderButton(title: 'İçerikler', route: '/contents'),
        if (isLoggedIn)
          HeaderButton(
            title: 'Randevularım',
            route: '/appointments/${AuthService().userUID()}',
          ),
        HeaderButton(
          title: isLoggedIn ? 'Profilim' : 'Giriş Yap',
          route: isLoggedIn ? '/profile/${AuthService().userUID()}' : '/login',
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: SpinKitFadingCircle(
          color: _primaryColor,
          size: 50,
        ),
      ),
    );
  }
}

