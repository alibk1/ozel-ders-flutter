import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PaymentService {
  final String merchantCode = '255220005161';
  final String secretWord = 'wKWf@%EsyBdR-HBHd9pxhF@tKnPa@baf6BZz4Ke2r?SAv3UBaG4Jd@-qaYDrHPhp';

  Future<void> createCheckoutPayment(String cardNumber, String expiryDate, String cvv) async {
    // Ödeme verileri
    final Map<String, dynamic> paymentData = {
      "merchantOrderId": "12345",
      "currency": "USD",
      "total": 100.00,
      "billingAddr": {
        "name": "John Doe",
        "addrLine1": "123 Main Street",
        "city": "San Francisco",
        "state": "CA",
        "zipCode": "94105",
        "country": "USA",
        "email": "johndoe@example.com",
      },
      "card": {
        "number": cardNumber,
        "expMonth": expiryDate.split('/')[0],
        "expYear": expiryDate.split('/')[1],
        "cvv": cvv,
      }
    };

    // API isteği gönderin
    final response = await http.post(
      Uri.parse('https://sandbox.2checkout.com/checkout/api/1/$merchantCode/rs/authService'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(paymentData),
    );

    if (response.statusCode == 200) {
      print('Payment Success: ${response.body}');
    } else {
      print('Payment Failed: ${response.body}');
    }
  }
}

class PaymentForm extends StatefulWidget {
  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  String cardNumber = '';
  String expiryDate = '';
  String cvv = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text('Kredi Kartı ile Ödeme'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Kart Numarası'),
                onChanged: (value) {
                  cardNumber = value;
                },
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Son Kullanma Tarihi (MM/YY)'),
                onChanged: (value) {
                  expiryDate = value;
                },
                keyboardType: TextInputType.datetime,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'CVV'),
                onChanged: (value) {
                  cvv = value;
                },
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Ödeme işlemini başlatın
                    print('Ödeme bilgileri: $cardNumber, $expiryDate, $cvv');
                  }
                },
                child: Text('Ödeme Yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

