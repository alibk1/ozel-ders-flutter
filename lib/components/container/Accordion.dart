import 'package:flutter/material.dart';

class Accordion extends StatefulWidget {
  final int id;
  final String title;

  Accordion({required this.id, required this.title});

  @override
  _AccordionState createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  int? activeIndex;

  void handleClick(int id) {
    setState(() {
      activeIndex = id == activeIndex ? null : id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(
                  activeIndex == widget.id
                      ? Icons.expand_less
                      : Icons.expand_more,
                ),
                onPressed: () => handleClick(widget.id),
              ),
            ],
          ),
          if (activeIndex == widget.id)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Lorem ipsum dolor sit amet consectetur adipisicing elit. Quos, eum beatae porro voluptatum aspernatur, id nesciunt reiciendis maxime unde necessitatibus illum accusamus mollitia incidunt qui nisi tempora facere magni magnam?',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
