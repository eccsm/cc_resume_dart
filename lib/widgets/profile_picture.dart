// lib/widgets/profile_picture.dart

import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Set size based on screen width
    double size;
    if (screenWidth > 1200) {
      size = 120;
    } else if (screenWidth > 800) {
      size = 100;
    } else {
      size = 80;
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundImage: const AssetImage('assets/images/profile_picture.png'),
      backgroundColor: Colors.transparent,
    );
  }
}
