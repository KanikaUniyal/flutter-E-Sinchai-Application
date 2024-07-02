import 'dart:async';
import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Blinking Status Button'),
//         ),
//         body: BlinkingStatusButton(),
//       ),
//     );
//   }
// }

class BlinkingStatusButton extends StatefulWidget {
  @override
  _BlinkingStatusButtonState createState() => _BlinkingStatusButtonState();
}

class _BlinkingStatusButtonState extends State<BlinkingStatusButton> {
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    // Start blinking when the widget is initialized
    startBlinking();
  }

  void startBlinking() {
    // Toggle the visibility of the button every 500 milliseconds
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        isVisible = !isVisible;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20), // Adjust spacing as needed
          Container(
            height: 40, // Adjust height as needed
            width: 40, // Adjust width as needed
            child: Visibility(
              visible: isVisible,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(0),
                ),
                child: Icon(Icons.arrow_forward),),
            ),
          ),
          SizedBox(height: 20), // Adjust spacing as needed
          Container(
            height: 100, // Adjust height as needed
            width: 10, // Adjust width as needed
            child: Visibility(
              visible: isVisible,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(''),
              ),
            ),
          ),
          SizedBox(height: 20), // Adjust spacing as needed
          // You can add more widgets below the blinking button
          Text('Other content here'),
        ],
      ),
    );
  }
}
