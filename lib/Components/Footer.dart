import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterSection extends StatelessWidget {
  // Renk Teması
  final Color _primaryColor = Color(0xFFA7D8DB); // Ana renk
  final Color _darkColor = Color(0xFF3C72C2); // Koyu arka plan
  final Color _lightColor = Color(0xFFEEEEEE); // Açık metin rengi
  final Gradient _gradientBackground = LinearGradient(
    colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Gradyan renkler
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      decoration: BoxDecoration(
        gradient: _gradientBackground, // Gradyan arka plan
      ),
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: isMobile ? 20 : 80),
      child: Column(
        children: [
          // Üst Kısım: İçerik
          isMobile ? _buildMobileContent() : _buildDesktopContent(),
          SizedBox(height: 40),
          // Alt Kısım: Telif Hakkı
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: _lightColor.withOpacity(0.1), width: 1),
              ),
            ),
            child: Text(
              '© 2024 Vitament Education Services. Tüm Hakları Saklıdır.',
              style: TextStyle(
                color: _lightColor.withOpacity(0.7), // Açık metin rengi
                fontSize: isMobile ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContent() {
    return Column(
      children: [
        // Logo ve Slogan
        Column(
          children: [
            Image.asset(
              'assets/vitament1.png',
              height: 50,
            ),
            SizedBox(height: 8),
            Text(
              'Education Services',
              style: TextStyle(
                color: _lightColor, // Açık metin rengi
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        // Navigasyon Linkleri
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            _FooterLink(text: 'Ana Sayfa', route: '/', hoverColor: _lightColor.withOpacity(0.2)),
            _FooterLink(text: 'Kategoriler', route: '/categories', hoverColor: _lightColor.withOpacity(0.2)),
            _FooterLink(text: 'Terapiler', route: '/courses', hoverColor: _lightColor.withOpacity(0.2)),
          ],
        ),
        SizedBox(height: 20),
        // Sosyal Medya İkonları
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialIcon(
              icon: Icons.facebook,
              url: 'https://www.facebook.com/vitament',
              iconColor: _lightColor,
              hoverColor: _primaryColor,
            ),
            _SocialIcon(
              icon: Ionicons.logo_twitter,
              url: 'https://www.twitter.com/vitament',
              iconColor: _lightColor,
              hoverColor: _primaryColor,
            ),
            _SocialIcon(
              icon: Ionicons.logo_instagram,
              url: 'https://www.instagram.com/vitament',
              iconColor: _lightColor,
              hoverColor: _primaryColor,
            ),
            _SocialIcon(
              icon: Ionicons.logo_linkedin,
              url: 'https://www.linkedin.com/company/vitament',
              iconColor: _lightColor,
              hoverColor: _primaryColor,
            ),
          ],
        ),
        SizedBox(height: 20),
        // İletişim Bilgileri
        Column(
          children: [
            Text(
              'E-posta: info@vitament.net',
              style: TextStyle(color: _lightColor.withOpacity(0.8), fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Telefon: +90 123 456 7890',
              style: TextStyle(color: _lightColor.withOpacity(0.8), fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo ve Slogan
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/vitament1.png',
                    height: 60,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Education Services',
                    style: TextStyle(
                      color: _lightColor, // Açık metin rengi
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Vitament, online eğitim ve terapi hizmetleri sunan öncü bir platformdur. Uzman kadromuzla her zaman yanınızdayız.',
                style: TextStyle(
                  color: _lightColor.withOpacity(0.8), // Açık metin rengi
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Navigasyon Linkleri
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hızlı Erişim',
                style: TextStyle(
                  color: _lightColor, // Açık metin rengi
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FooterLink(text: 'Ana Sayfa', route: '/', hoverColor: _lightColor.withOpacity(0.2)),
                  _FooterLink(text: 'Kategoriler', route: '/categories', hoverColor: _lightColor.withOpacity(0.2)),
                  _FooterLink(text: 'Terapiler', route: '/courses', hoverColor: _lightColor.withOpacity(0.2)),
                ],
              ),
            ],
          ),
        ),
        // İletişim Bilgileri
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'İletişim',
                style: TextStyle(
                  color: _lightColor, // Açık metin rengi
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'E-posta: info@vitament.net',
                    style: TextStyle(color: _lightColor.withOpacity(0.8), fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Telefon: +90 123 456 7890',
                    style: TextStyle(color: _lightColor.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Sosyal Medya İkonları
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bizi Takip Edin',
                style: TextStyle(
                  color: _lightColor, // Açık metin rengi
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _SocialIcon(
                    icon: Icons.facebook,
                    url: 'https://www.facebook.com/vitament',
                    iconColor: _lightColor,
                    hoverColor: _primaryColor,
                  ),
                  _SocialIcon(
                    icon: Ionicons.logo_twitter,
                    url: 'https://www.twitter.com/vitament',
                    iconColor: _lightColor,
                    hoverColor: _primaryColor,
                  ),
                  _SocialIcon(
                    icon: Ionicons.logo_instagram,
                    url: 'https://www.instagram.com/vitament',
                    iconColor: _lightColor,
                    hoverColor: _primaryColor,
                  ),
                  _SocialIcon(
                    icon: Ionicons.logo_linkedin,
                    url: 'https://www.linkedin.com/company/vitament',
                    iconColor: _lightColor,
                    hoverColor: _primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final String route;
  final Color hoverColor;

  const _FooterLink({required this.text, required this.route, required this.hoverColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => context.go(route),
        hoverColor: hoverColor, // Hover rengi
        splashColor: Colors.transparent,
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFFEEEEEE).withOpacity(0.8), // Açık metin rengi
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;
  final Color iconColor;
  final Color hoverColor;

  const _SocialIcon({
    required this.icon,
    required this.url,
    required this.iconColor,
    required this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: iconColor),
      iconSize: 24,
      onPressed: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('URL açılamıyor')),
          );
        }
      },
      hoverColor: hoverColor, // Hover rengi
    );
  }
}