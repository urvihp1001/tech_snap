import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tech_snap/utils/colors.dart';
import 'package:tech_snap/widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: mobileBackgroundColor,
      centerTitle: false,
      title:SvgPicture.asset('assets/techsnap-modified.svg',
      color: Colors.blueGrey[50],
      height: 32,
      ),
      
      ),
    body: PostCard(),
    );
  }
}