import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/AppointmentsPage.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade200,
              Colors.blue.shade800,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: isMobile ? 100 : 150,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                Text(
                  '404',
                  style: TextStyle(
                    fontSize: isMobile ? 60 : 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sayfa Bulunamadı',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 28,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aradığınız sayfa mevcut değil. Ana sayfaya dönmek için aşağıdaki butona tıklayabilirsiniz.',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () {
                    context.go("/");
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Ana Menüye Dön',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
