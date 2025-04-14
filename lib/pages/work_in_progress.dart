import 'package:flutter/material.dart';
import 'package:EcoFinder/common_widgets/navbar_widget.dart';

class WorkInProgressPage extends StatelessWidget {
  final int index;
  const WorkInProgressPage({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(selectedIndex: index),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.eco_rounded,
              size: 150,
              color: Color(0xFF3E8E4D),
            ),
            SizedBox(height: 24),
            Text(
              'Work In Progress...',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}