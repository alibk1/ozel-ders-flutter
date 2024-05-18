import 'package:flutter/material.dart';

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bize Ulaşın',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Bir problemle mi karşılaştınız? Yardım etmek için buradayız. Lütfen aşağıdaki formu doldurun ve size yardımcı olmamızı sağlayın.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Email adresiniz',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Mesaj konusu',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Mesajınız',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {},
                child: Text('Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
