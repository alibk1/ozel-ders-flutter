import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/AppointmentsPage.dart';
import 'package:ozel_ders/CategoriesPage.dart';
import 'package:ozel_ders/CoursePage.dart';
import 'package:ozel_ders/CoursesPage.dart';
import 'package:ozel_ders/HomePage.dart';

import 'ProfilePage.dart';
import 'auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        builder: (context, state) => CoursesPage(category: '', subCategory: '',),
      ),
      GoRoute(
        path: '/courses/:category/:subcategory',
        builder: (context, state) {
          final category = state.pathParameters['category']!;
          final subcategory = state.pathParameters['subcategory']!;
          return  CoursesPage(category: category, subCategory: subcategory);
        },
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => CategoriesPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginSignupPage(),
      ),
      GoRoute(
        path: '/profile/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return ProfilePage(uid: uid);
        },
      ),
      GoRoute(
        path: '/appointments/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return AppointmentsPage(uid: uid);
        },
      ),
      GoRoute(
        path: '/courses/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return CoursePage(uid: uid);
        },
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

/*class HomePage extends StatelessWidget {
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
}*/

