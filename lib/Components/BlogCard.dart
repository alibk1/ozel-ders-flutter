import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BlogCard extends StatelessWidget {
  final Map<String, dynamic> blog;

  const BlogCard({required this.blog});

  @override
  Widget build(BuildContext context) {
    // content alanını alıyoruz
    String contentJson = blog['content'] ?? '[]';
    List<dynamic> contentList = jsonDecode(contentJson);

    // İlk resmi ve metin özetini bulmak için değişkenler
    String? firstImageUrl;
    String textSnippet = '';

    // İçeriği tarayarak ilk resmi ve metni alıyoruz
    for (var element in contentList) {
      if (element.containsKey('insert')) {
        var insert = element['insert'];
        if (insert is Map && insert.containsKey('source') && firstImageUrl == null) {
          // İlk resmi bulduk
          firstImageUrl = insert['source'];
        } else if (insert is String) {
          // Metin ekliyoruz
          textSnippet += insert;
          if (textSnippet.length > 100) {
            // İlk 100 karakteri aldıktan sonra döngüden çıkıyoruz
            textSnippet = textSnippet.substring(0, 100) + '...';
            break;
          }
        }
      }
    }

    // Eğer resim yoksa, varsayılan resmi kullanıyoruz
    Widget imageWidget;
    if (firstImageUrl != null) {
      if (firstImageUrl.startsWith('data:image')) {
        // Base64 kodlu resmi Image.memory ile gösteriyoruz
        final base64Data = firstImageUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        imageWidget = Image.memory(
          bytes,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else {
        // Network resmini Image.network ile gösteriyoruz
        imageWidget = Image.network(
          firstImageUrl,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
    } else {
      // Varsayılan resmi gösteriyoruz
      imageWidget = Image.asset(
        'assets/blogpost.png',
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    // Ekran genişliğine göre kart yüksekliğini ayarlıyoruz
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Card(
      color: Color(0xFF393E46),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // Blog detay sayfasına yönlendirme
          context.go('/blog/${blog['uid']}');
        },
        child: Container(
          height: isMobile ? 250 : 150, // Kart yüksekliğini ayarladık
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resim
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: imageWidget,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  blog['title'] ?? 'Başlık Yok',
                  style: TextStyle(
                    color: Color(0xFFEEEEEE),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (textSnippet.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    textSnippet,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFEEEEEE),
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
