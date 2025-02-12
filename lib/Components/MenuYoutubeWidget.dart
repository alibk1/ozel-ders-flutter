import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'YoutubeCard.dart';

class TopYoutubeVideosWidget extends StatefulWidget {
  final Function onSeeAllPressed;
  final List<Map<String, dynamic>> youtubeVideos;

  const TopYoutubeVideosWidget({
    required this.onSeeAllPressed,
    required this.youtubeVideos,
    Key? key,
  }) : super(key: key);

  @override
  _TopYoutubeVideosWidgetState createState() => _TopYoutubeVideosWidgetState();
}

class _TopYoutubeVideosWidgetState extends State<TopYoutubeVideosWidget> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 170,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve "Tümünü Gör" butonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popüler Videolar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222831),
                ),
              ),
              TextButton(
                onPressed: () => widget.onSeeAllPressed(),
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
          if (widget.youtubeVideos.isEmpty)
            Center(child: Text('Gösterilecek video bulunamadı'))
          else if (isMobile)
            _buildMobileVideoList(widget.youtubeVideos)
          else
            _buildDesktopVideoGrid(widget.youtubeVideos),
        ],
      ),
    );
  }

  /// Desktop için grid yapıda video kartlarını oluşturur.
  Widget _buildDesktopVideoGrid(List<Map<String, dynamic>> youtubeVideos) {
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Grid içi scroll kapalı
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 5 sütun
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: youtubeVideos.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: Duration(milliseconds: 500),
            columnCount: 5,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: YoutubeCard(videoData: youtubeVideos[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Mobilde yatay liste şeklinde video kartlarını oluşturur.
  Widget _buildMobileVideoList(List<Map<String, dynamic>> youtubeVideos) {
    return SizedBox(
      height: 280, // Sabit yükseklik
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: youtubeVideos.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 500),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  width: 280,
                  margin: EdgeInsets.only(right: 16),
                  child: YoutubeCard(videoData: youtubeVideos[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
