import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ekran boyutunu almak için MediaQuery kullanıyoruz
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      color: Color(0xFF222831),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: isMobile
      // Mobil Görünüm
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo ve Slogan
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/vitament1.png',
                height: 40,
              ),
              SizedBox(width: 4),
              Text(
                'Education Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          // Navigasyon Linkleri
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              _FooterLink(text: 'Ana Sayfa', route: '/'),
              _FooterLink(text: 'Kategoriler', route: '/categories'),
              _FooterLink(text: 'Kurslar', route: '/courses'),
              //_FooterLink(text: 'Hakkımızda', route: '/about'),
              //_FooterLink(text: 'İletişim', route: '/contact'),
            ],
          ),
          SizedBox(height: 6),
          // Sosyal Medya İkonları
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(
                icon: Icons.facebook,
                url: 'https://www.facebook.com/vitament',
              ),
              _SocialIcon(
                icon: Ionicons.logo_twitter,
                url: 'https://www.twitter.com/vitament',
              ),
              _SocialIcon(
                icon: Ionicons.logo_instagram,
                url: 'https://www.instagram.com/vitament',
              ),
              _SocialIcon(
                icon: Ionicons.logo_linkedin,
                url: 'https://www.linkedin.com/company/vitament',
              ),
            ],
          ),
          SizedBox(height: 6),
          // İletişim Bilgileri
          Text(
            'E-posta: info@vitament.net',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          SizedBox(height: 4),
          Text(
            'Telefon: +90 123 456 7890',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          SizedBox(height: 6),
          // Telif Hakkı Bilgisi
          Text(
            '© 2024 Vitament Education Services. Tüm Hakları Saklıdır.',
            style: TextStyle(color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      )
      // Masaüstü Görünüm
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Birinci Sütun: Sosyal Medya İkonları
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '  Bizi Takip Edin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _SocialIcon(
                          icon: Icons.facebook,
                          url: 'https://www.facebook.com/vitament',
                        ),
                        _SocialIcon(
                          icon: Ionicons.logo_twitter,
                          url: 'https://www.twitter.com/vitament',
                        ),
                        _SocialIcon(
                          icon: Ionicons.logo_instagram,
                          url: 'https://www.instagram.com/vitament',
                        ),
                        _SocialIcon(
                          icon: Ionicons.logo_linkedin,
                          url: 'https://www.linkedin.com/company/vitament',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // İkinci Sütun: Logo ve İletişim Bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/vitament1.png',
                          height: 60,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Education Services',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'E-posta: info@vitament.net',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Telefon: +90 123 456 7890',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              // Üçüncü Sütun: Navigasyon Linkleri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Hızlı Erişim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _FooterLink(text: 'Ana Sayfa', route: '/'),
                        _FooterLink(text: 'Kategoriler', route: '/categories'),
                        _FooterLink(text: 'Kurslar', route: '/courses'),
                        //_FooterLink(text: 'Hakkımızda', route: '/about'),
                        //_FooterLink(text: 'İletişim', route: '/contact'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Telif Hakkı Bilgisi
          Text(
            '© 2024 Vitament Education Services. Tüm Hakları Saklıdır.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final String route;

  const _FooterLink({required this.text, required this.route});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // go_router kullanıyorsanız, context.go(route) kullanabilirsiniz
        context.go(route);
      },
      child: Text(
        text,
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  const _SocialIcon({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70),
      iconSize: 24,
      onPressed: () async {
        // URL'yi açmak için url_launcher paketini kullanıyoruz
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          // URL açılamıyorsa bir hata mesajı gösterebilirsiniz
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('URL açılamıyor')),
          );
        }
      },
    );
  }
}
