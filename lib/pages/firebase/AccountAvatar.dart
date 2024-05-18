import 'package:flutter/material.dart';

class AccountMenu extends StatefulWidget {
  final String avatar;
  final String displayName;
  final Function logOut;

  AccountMenu({required this.avatar, required this.displayName, required this.logOut});

  @override
  _AccountMenuState createState() => _AccountMenuState();
}

class _AccountMenuState extends State<AccountMenu> {
  late Offset _tapPosition;

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _storePosition,
      onTap: () {
        final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
        showMenu(
          context: context,
          position: RelativeRect.fromRect(
              _tapPosition & Size(40, 40), Offset.zero & overlay.size),
          items: <PopupMenuEntry>[
            PopupMenuItem(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(widget.avatar),
                ),
                title: Text(widget.displayName),
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.person_add),
                title: Text('Online kurs girişi'),
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Çıkış Yap'),
                onTap: () {
                  widget.logOut();
                },
              ),
            ),
          ],
        );
      },
      child: CircleAvatar(
        backgroundImage: NetworkImage(widget.avatar),
      ),
    );
  }
}
