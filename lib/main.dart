/*
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) => CoursesPage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go('/courses');
          },
          child: Text('Go to Courses'),
        ),
      ),
    );
  }
}

class CoursesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses Page'),
      ),
      body: Center(
        child: Text('Welcome to Courses Page'),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ozel_ders/App.dart'; // App.dart dosyanızdaki App widget'ını ekleyin

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAoEBxQyBErpVzHH8-jhyrSgRU5OLTnBrE",
      authDomain: "ortakozelders.firebaseapp.com",
      projectId: "ortakozelders",
      storageBucket: "ortakozelders.appspot.com",
      messagingSenderId: "619520758342",
      appId: "1:619520758342:web:12c44b2582dbdcb9b67047",
      measurementId: "G-MZLW5M94M2",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return App();
  }
}
