import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/AppointmentsPage.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubeCard extends StatefulWidget {
  final Map<String, dynamic> videoData;

  const YoutubeCard({
    required this.videoData,
    Key? key,
  }) : super(key: key);

  @override
  _YoutubeCardState createState() => _YoutubeCardState();
}

class _YoutubeCardState extends State<YoutubeCard> {
  bool isHovered = false;

  /// Youtube linkini yeni sekmede açmak için yardımcı fonksiyon.
  Future<void> _launchYoutubeUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    final String videoUrl = widget.videoData['videoUrl'] ?? '';
    final String videoThumbnailUrl = widget.videoData['videoThumbnailUrl'] ?? '';
    final String videoTitle = widget.videoData['videoTitle'] ?? '';

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
            // Video URL'sinin son kısmını alarak GoRoute ile video ekranına yönlendiriyoruz.
            String urlCont = videoUrl.split("/").last;
            FirestoreService().updateYoutubeVideoViews(widget.videoData["uid"], widget.videoData["views"]);
            context.go('/video/$urlCont');
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Video Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    videoThumbnailUrl,
                    width: isMobile ? 200 : 320,
                    height: isMobile ? 112.5 : 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                // Başlık ve Youtube ikon button (yan yana)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Video başlığı
                    Expanded(
                      child: Text(
                        videoTitle,
                        style: TextStyle(
                          fontSize: isMobile ? 9 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Youtube logosuna benzeyen IconButton
                    IconButton(
                      icon: Icon(
                        Icons.ondemand_video,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        await _launchYoutubeUrl(videoUrl);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class YoutubeVideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const YoutubeVideoPlayerScreen({required this.videoUrl, Key? key}) : super(key: key);

  @override
  _YoutubeVideoPlayerScreenState createState() => _YoutubeVideoPlayerScreenState();
}

class _YoutubeVideoPlayerScreenState extends State<YoutubeVideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    String videoUrl = "https://youtu.be/" + widget.videoUrl;
    final videoId = YoutubePlayerController.convertUrlToId(videoUrl)!;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar olmadan, direkt video ekranı.
      body: YoutubePlayer(controller: _controller, aspectRatio: 16/9,)
    );
  }
}


