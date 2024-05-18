import 'package:flutter/material.dart';

class RecipeReviewCard extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String photo;
  final String lectureCover;
  final String lecture;
  final String description;
  final Map<String, dynamic> lectureCost;
  final DateTime createdAt;

  RecipeReviewCard({
    required this.firstName,
    required this.lastName,
    required this.photo,
    required this.lectureCover,
    required this.lecture,
    required this.description,
    required this.lectureCost,
    required this.createdAt,
  });

  @override
  _RecipeReviewCardState createState() => _RecipeReviewCardState();
}

class _RecipeReviewCardState extends State<RecipeReviewCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.photo),
            ),
            title: Text('${widget.firstName} ${widget.lastName}'),
            subtitle: Text('${widget.createdAt.toLocal()}'.split(' ')[0]),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
          Image.network(widget.lectureCover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.lecture, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.description),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              Text('${widget.lectureCost['price']} TL | ${widget.lectureCost['minute']} dk'),
              IconButton(
                icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    expanded = !expanded;
                  });
                },
              ),
            ],
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Method:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Heat 1/2 cup of the broth in a pot until simmering, add saffron and set aside for 10 minutes.'),
                  Text('Heat oil in a (14- to 16-inch) paella pan or a large, deep skillet over medium-high heat.'),
                  Text('Add chicken, shrimp and chorizo, and cook, stirring occasionally until lightly browned, 6 to 8 minutes.'),
                  Text('Transfer shrimp to a large plate and set aside, leaving chicken and chorizo in the pan.'),
                  Text('Add pimentón, bay leaves, garlic, tomatoes, onion, salt and pepper, and cook, stirring often until thickened and fragrant, about 10 minutes.'),
                  Text('Add saffron broth and remaining 4 1/2 cups chicken broth; bring to a boil.'),
                  Text('Add rice and stir very gently to distribute. Top with artichokes and peppers, and cook without stirring, until most of the liquid is absorbed, 15 to 18 minutes.'),
                  Text('Reduce heat to medium-low, add reserved shrimp and mussels, tucking them down into the rice, and cook again without stirring, until mussels have opened and rice is just tender, 5 to 7 minutes more.'),
                  Text('Set aside off of the heat to let rest for 10 minutes, and then serve.'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
