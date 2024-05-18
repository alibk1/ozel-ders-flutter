import 'package:flutter/material.dart';

class NavLink extends StatelessWidget {
  final String href;
  final String link;

  NavLink({required this.href, required this.link});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, href);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          link,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
