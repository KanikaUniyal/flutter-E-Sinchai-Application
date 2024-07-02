import 'package:app/main.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();

}

class _SplashState extends State<Splash> {
  // late String _email;
  // late String _password;
  @override
  void initState()
  {
    super.initState();
   _navigatetohome();
  }

  _navigatetohome()async
  {
    await Future.delayed(Duration(milliseconds: 1500), (){});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(title: 'PRSC',) ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/i2.jpg'), // Replace 'background_image.jpg' with your image asset path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 100,width: 100,color: Colors.blue,),
            Container(
              child:
               Text('Splash Screen',style: TextStyle(
                 fontSize: 24, fontWeight: FontWeight.bold
              ),
               ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}


