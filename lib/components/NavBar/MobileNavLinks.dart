import 'package:flutter/material.dart';

class MobileNavLinks extends StatelessWidget {
  final String href;
  final String link;
  final Function setToggle;

  MobileNavLinks({required this.href, required this.link, required this.setToggle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        link,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () {
        setToggle();
        Navigator.pushNamed(context, href);
      },
    );
  }
}
