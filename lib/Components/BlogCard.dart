import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BlogCard extends StatefulWidget {
  final Map<String, dynamic> blog;

  const BlogCard({required this.blog, Key? key}) : super(key: key);

  @override
  _BlogCardState createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  bool isHovered = false;

  // İçerikten ilk resmi ve metin özetini çıkar
  String? _getFirstImageUrl() {
    String contentJson = widget.blog['content'] ?? '[]';
    List<dynamic> contentList = jsonDecode(contentJson);

    for (var element in contentList) {
      if (element.containsKey('insert')) {
        var insert = element['insert'];
        if (insert is Map && insert.containsKey('source')) {
          return insert['source'];
        }
      }
    }
    return null;
  }

  // Metin özetini çıkar
  String _getTextSnippet() {
    String contentJson = widget.blog['content'] ?? '[]';
    List<dynamic> contentList = jsonDecode(contentJson);
    String textSnippet = '';

    for (var element in contentList) {
      if (element.containsKey('insert') && element['insert'] is String) {
        textSnippet += element['insert'];
        if (textSnippet.length > 100) {
          textSnippet = textSnippet.substring(0, 100) + '...';
          break;
        }
      }
    }
    return textSnippet;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final firstImageUrl = _getFirstImageUrl();
    final textSnippet = _getTextSnippet();
    final commentCount = widget.blog['comments']?.length ?? 0;

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
            context.go('/blog/${widget.blog["uid"]}');
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resim
              ClipRRect(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: _buildImageWidget(firstImageUrl),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık
                      Text(
                        widget.blog['title'] ?? 'Başlık Yok',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Yazar Bilgisi
                      Text(
                        'Yazar: Elif Korkmaz', // Geçici olarak sabit yazar ismi
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Metin Özeti
                      if (textSnippet.isNotEmpty)
                        Text(
                          textSnippet,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Color(0xFF666666),
                          ),
                        ),
                      SizedBox(height: 16),
                      // Yorum Sayısı
                      Row(
                        children: [
                          Icon(
                            Icons.comment,
                            color: Color(0xFF666666),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '$commentCount Yorum',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String? imageUrl) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final imageSize = isMobile ? 120.0 : 200.0;

    if (imageUrl == null) {
      return Image.asset(
        'assets/blogpost.png',
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
      );
    }

    if (imageUrl.startsWith('data:image')) {
      // Base64 kodlu resim
      final base64Data = imageUrl.split(',')[1];
      final bytes = base64Decode(base64Data);
      return Image.memory(
        bytes,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
      );
    } else {
      // Network resmi
      return Image.network(
        imageUrl,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
      );
    }
  }
}