import 'package:flutter/material.dart';
import 'package:tech_snap/utils/colors.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color:mobileBackgroundColor,
      padding: EdgeInsets.symmetric(vertical: 10),//so non sticky
      child: Column(children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 4,horizontal: 16).copyWith(right: 0),
          child: Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1718703382898-743dd5bd5e38?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw4fHx8ZW58MHx8fHx8'),
            ),
            Expanded(child: 
            Padding(padding: EdgeInsets.only(left:8),
            child: Column(mainAxisSize:MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('username',
              style:TextStyle(
                fontWeight: FontWeight.bold
              )
              )
            ],
            ),
            )
            ),
            IconButton(onPressed: (){}, icon: Icon(Icons.more_vert))
          ],
          ),
        )
      ],
      
      ),
    );
  }
}