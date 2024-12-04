import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders/CoursePage.dart';

class CourseCard extends StatefulWidget {
  final Map<String, dynamic> course;
  final Map<String, dynamic> author;

  CourseCard({
    required this.course,
    required this.author,
  });

  @override
  _CourseCardState createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool isExpanded = false;
  final int maxLinesCollapsed = 3;
  final int maxLinesExpanded = 7;

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25), // Yuvarlak köşe
          topRight: Radius.circular(25), // Yuvarlak köşe
          bottomLeft: Radius.circular(25), // Sivri köşe
          bottomRight: Radius.circular(25),
        ),
        side: BorderSide(
          width: 3,
          color: Color(int.parse("#31363F".substring(1, 7), radix: 16) + 0xFF000000),
        ),
      ),
      color: Color(int.parse("#222831".substring(1, 7), radix: 16) + 0xFF000000),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: PageView(
                children: widget.course['photos'].map<Widget>((photoUrl) {
                  return Image.network(photoUrl, fit: BoxFit.cover);
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 4),
          TextButton(
            child: Text(
              widget.course['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 15 : 20,
                color: Color(int.parse("#EEEEEE".substring(1, 7), radix: 16) + 0xFF000000),
              ),
            ),
            onPressed: ()
            {
              context.go('/courses/' + widget.course["UID"]);
            },
          ),
          Text(
            widget.author["name"],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 12 : 15,
              color: Color(int.parse("#EEEEEE".substring(1, 7), radix: 16) + 0xFF000000),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                color: Color(int.parse("#76ABAE".substring(1, 7), radix: 16) + 0xFF000000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5), // Yuvarlak köşe
                    topRight: Radius.circular(5), // Yuvarlak köşe
                    bottomLeft: Radius.circular(5), // Sivri köşe
                    bottomRight: Radius.circular(5),
                  ),
                  side: BorderSide(
                    width: 1,
                    color: Color(int.parse("#EEEEEE".substring(1, 7), radix: 16) + 0xFF000000),
                  ),
                ),
                child: Text(
                  "   ${widget.course['hourlyPrice']} TL   ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(int.parse("#EEEEEE".substring(1, 7), radix: 16) + 0xFF000000),
                  ),
                ),
              ),
            ],
          ),
          if(!isMobile) Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Stack(
                  children: [
                    Text(
                      widget.course['desc'],
                      maxLines: isExpanded ? maxLinesExpanded : maxLinesCollapsed,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(int.parse("#76ABAE".substring(1, 7), radix: 16) + 0xFF000000),
                      ),
                    ),
                    if (!isExpanded)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white.withOpacity(0.0), Colors.white],
                              stops: [0.0, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Text(
                            "...",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(int.parse("#76ABAE".substring(1, 7), radix: 16) + 0xFF000000),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        isExpanded ? "Daha az göster" : "Devamını oku",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(int.parse("#76ABAE".substring(1, 7), radix: 16) + 0xFF000000),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Color(int.parse("#76ABAE".substring(1, 7), radix: 16) + 0xFF000000),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
