import 'package:flutter/material.dart';

import '../../../res/app_assets.dart';

class GSTScreen extends StatelessWidget {
  const GSTScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.backgroundImg),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
