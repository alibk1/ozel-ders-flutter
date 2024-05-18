import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ozel_ders/components/NavBar/MobileNavLinks.dart';
import 'package:ozel_ders/components/NavBar/NavLink.dart';
import 'package:ozel_ders/pages/firebase/GoogleLogin.dart';

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  bool toggle = false;
  bool active = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    setState(() {
      active = _scrollController.position.pixels > 20;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: active ? Colors.white : Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                toggle = !toggle;
              });
            },
            child: Icon(toggle ? FontAwesomeIcons.times : FontAwesomeIcons.bars),
          ),
          Image.asset('assets/logo1.png', width: 100.0),
          Row(
            children: [
              NavLink(href: '/home', link: 'Home'),
              NavLink(href: '/about', link: 'About'),
              NavLink(href: '/services', link: 'Services'),
              NavLink(href: '/contact', link: 'Contact'),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/login');
            },
            child: GoogleLogin(),
          ),
          toggle
              ? Container(
            color: Colors.white,
            child: Column(
              children: [
                MobileNavLinks(
                  href: '/home',
                  link: 'Home',
                  setToggle: () {
                    setState(() {
                      toggle = false;
                    });
                  },
                ),
                MobileNavLinks(
                  href: '/about',
                  link: 'About',
                  setToggle: () {
                    setState(() {
                      toggle = false;
                    });
                  },
                ),
                MobileNavLinks(
                  href: '/services',
                  link: 'Services',
                  setToggle: () {
                    setState(() {
                      toggle = false;
                    });
                  },
                ),
                MobileNavLinks(
                  href: '/contact',
                  link: 'Contact',
                  setToggle: () {
                    setState(() {
                      toggle = false;
                    });
                  },
                ),
              ],
            ),
          )
              : Container(),
        ],
      ),
    );
  }
}
