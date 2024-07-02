import 'dart:convert';

import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:app/localstring.dart
import 'package:app/home.dart';
import 'package:app/splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
 import 'LocaleString.dart';
 // import 'localstring.dart';

void main() {
  runApp(
    const MyApp()
  );

}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // String _email = "example@email.com"; // Set default email
    // String _password = "examplePassword";
    // Get.put(LocaleString());
    return GetMaterialApp(
      translations: LocalString(),

       locale: Locale('en','US'),
      fallbackLocale: Locale('en', 'US'),
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      // home: SignUp(),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

  //     home: Stack(
  //       fit: StackFit.expand,
  //       children: [
  //       // Background image
  //       Image.asset(
  //       'images/i2.jpg',
  //       fit: BoxFit.cover,
  //     ),
  //     AnimatedSplashScreen(
  //         splash:
  //             Image.asset("images/wrd_logo.png"),
  //         // AssetImage('images/icon.jpeg'),
  //         // Icons.home,
  //           duration: 3000,
  //
  //         nextScreen: MyHomePage(title: 'PRSC' )),
  //           // email: _email,
  //           //   password: _password,)),
  //
  // ],
  //   ),

      home: AnimatedSplashScreen(
        duration: 3000,
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.transparent,
        // Set background image directly as a child of AnimatedSplashScreen
        splashIconSize: double.infinity,
        splash: Stack(
          children: [
            Image.asset(
              "images/i2.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Center(
              child: Image.asset("images/wrd_logo.png",
              width: 500, // Adjust width as needed
              height: 300,
              ),
            ),
          ],
        ),
        nextScreen: MyHomePage(title: 'PRSC'),
      ),


    );
  }
}
