import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'BlogCard.dart';

class TopBlogsWidget extends StatelessWidget {
  final Function onSeeAllPressed;
  final List<Map<String, dynamic>> blogs;

  const TopBlogsWidget({
    required this.onSeeAllPressed,
    required this.blogs,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 170,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve "Tümünü Gör" butonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popüler Bloglar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222831),
                ),
              ),
              TextButton(
                onPressed: () => onSeeAllPressed(),
                child: Text(
                  'Tümünü Gör',
                  style: TextStyle(
                    color: Color(0xFF3C72C2),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // BlogCard'ları alt alta listele
          if (blogs.isEmpty)
            Center(child: Text('Gösterilecek blog bulunamadı'))
          else
            AnimationLimiter(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: blogs.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: BlogCard(blog: blogs[index]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
