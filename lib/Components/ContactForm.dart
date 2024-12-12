import 'package:flutter/material.dart';
import 'package:ozel_ders/services/FirebaseController.dart';

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

  // Form alanlarının odak renkleri ve stilleri için tema renklerini kullanabiliriz
  final Color _primaryColor = Color(0xFF76ABAE);
  final Color _textColor = Color(0xFFEEEEEE);
  final Color _backgroundColor = Color(0xFF222831);

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          // Gölge ve kenarlıkları düzenliyoruz
          borderRadius: BorderRadius.circular(12),
          color: _backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            // Elemanları ortalıyoruz
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'İletişim Formu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: _textColor),
                decoration: _inputDecoration('Adınız'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adınızı girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: _textColor),
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
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                style: TextStyle(color: _textColor),
                decoration: _inputDecoration('Mesajınız'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen mesajınızı girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  'Gönder',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _textColor),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _textColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
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
