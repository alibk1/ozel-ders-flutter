import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:glassmorphism/glassmorphism.dart';

class ContactForm extends StatefulWidget {
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingController'ları tanımlıyoruz
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Renk şemasını HomePage'den alıyoruz
  final Color _primaryColor = Color(0xFFA7D8DB);
  final Color _textColor = Color(0xFF222831);
  final Color _backgroundColor = Color(0xFFEEEEEE);

  @override
  void dispose() {
    // Bellek sızıntılarını önlemek için controller'ları dispose ediyoruz
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 800;
    return GlassmorphicContainer(
      width: isMobile ? width - 20 : width - 380,
      padding: EdgeInsets.all(24.0),
      borderRadius: 20,
      blur: 20,
      border: 2,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
      ),
      borderGradient: LinearGradient(colors: [Colors.white24, Colors.white12]),
      height: 450,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20,),
            Text(
              'Bizimle İletişime Geçin',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 500.ms),
            SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.poppins(color: _textColor),
              decoration: _inputDecoration('Adınız'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen adınızı girin';
                }
                return null;
              },
            ).animate().fadeIn(duration: 600.ms),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              style: GoogleFonts.poppins(color: _textColor),
              decoration: _inputDecoration('E-posta'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen e-posta adresinizi girin';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Lütfen geçerli bir e-posta adresi girin';
                }
                return null;
              },
            ).animate().fadeIn(duration: 700.ms),
            SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              style: GoogleFonts.poppins(color: _textColor),
              decoration: _inputDecoration('Mesajınız'),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen mesajınızı girin';
                }
                return null;
              },
            ).animate().fadeIn(duration: 800.ms),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(
                'Gönder',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ).animate().fadeIn(duration: 900.ms),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: _textColor),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Form alanlarını kaydediyoruz
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String message = _messageController.text.trim();

      // Firebase'e verileri gönderiyoruz
      await FirestoreService().createMessage(email, name, message);

      // Form alanlarını temizliyoruz
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();

      // Başarılı gönderim mesajı gösteriyoruz
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mesajınız başarıyla gönderildi'),
          backgroundColor: _primaryColor,
        ),
      );
    }
  }
}