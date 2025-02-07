import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/AppointmentsPage.dart';
import 'package:ozel_ders/BlogCreatePage.dart';
import 'package:ozel_ders/BlogPage.dart';
import 'package:ozel_ders/BlogsPage.dart';
import 'package:ozel_ders/CategoriesPage.dart';
import 'package:ozel_ders/CoursePage.dart';
import 'package:ozel_ders/CoursesPage.dart';
import 'package:ozel_ders/HomePage.dart';
import 'package:ozel_ders/TeamProfilePage.dart';

import 'ProfilePage.dart';
import 'auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  /*Platform.isAndroid
      ? await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAoEBxQyBErpVzHH8-jhyrSgRU5OLTnBrE",
          authDomain: "ortakozelders.firebaseapp.com",
          projectId: "ortakozelders",
          storageBucket: "ortakozelders.appspot.com",
          messagingSenderId: "619520758342",
          appId: "1:619520758342:web:12c44b2582dbdcb9b67047",
          measurementId: "G-MZLW5M94M2"
      )
  )
      :*/
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
        builder: (context, state) => CoursesPage(category: '', subCategory: '',)//AdminPanel2() ,
      ),
      GoRoute(
        path: '/blog-update/:uid/:blogUID',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          final blogUID = state.pathParameters['blogUID']!;
          return BlogWritePage(uid: uid, isUpdate: true, blogUID: blogUID);
        },
      ),
      GoRoute(
        path: '/blog-create/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return BlogWritePage(uid: uid,);
        },
      ),
      GoRoute(
        path: '/blog/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return BlogPage(blogUID: uid,);
        },
      ),
      GoRoute(
        path: '/blogs',
        builder: (context, state) => BlogsPage(),
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
        builder: (context, state) => LoginSignupPage(reference: "",),
      ),
      GoRoute(
        path: '/newuser/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return LoginSignupPage(reference: uid);
        },
      ),
      GoRoute(
        path: '/profile/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return ProfilePage(uid: uid);
        },
      ),
      GoRoute(
        path: '/team/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return TeamProfilePage(uid: uid);
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
      title: "Vitament",
      routerConfig: _router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Uygulamanız hangi dilleri destekleyecekse buraya ekleyin.
      supportedLocales: const [
        Locale('en', 'US'), // İngilizce
        Locale('tr', 'TR'), // Türkçe
      ],
      // Uygulamanın varsayılan dili
      locale: const Locale('tr', 'TR'),
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

