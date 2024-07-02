import 'dart:async';
import 'dart:convert';
import 'package:app/farmer/help.dart';
import 'package:app/language_controller.dart';
import 'package:app/LocaleString.dart';
import 'package:app/api_urls.dart';
import 'package:app/farmer/Createrequest.dart';
import 'package:app/farmer/approvedapplicationfarmer.dart';
import 'package:app/farmer/changepassword.dart';
import 'package:app/farmer/newproject.dart';
import 'package:app/farmer/updateprofile.dart';
import 'package:app/farmer/pendingapplicationfarmer.dart';
// import 'package:app/farmer/profile.dart';
import 'package:app/farmer/rejectedapplicationfarmer.dart';
import 'package:app/home.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:app/farmer/totalapplicationfarmer.dart';
import 'package:get/get.dart';
import 'package:app/custom_app_bar.dart';

import 'package:app/LocaleString.dart';
// import 'language_controller.dart';
import '../ForgetPassword.dart';
import '../SignUp.dart';

void main() {
  LanguageController languageController = Get.put(LanguageController());
  runApp(GetMaterialApp(
    title: 'Farmer Dashboard',
    debugShowCheckedModeBanner: false,
    home: Farmer(username: 'username'),
    initialBinding: BindingsBuilder(() {
      // Register the LanguageController
      Get.put(LanguageController());
    }),
  ));
}


class Farmer extends StatelessWidget {
  final String username;  // Add this line

  Farmer({required this.username});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Farmer Dashboard',
      debugShowCheckedModeBanner: false,
      home: Home(username: username),
    );
  }
}

class Home extends StatefulWidget {
  final String username;
  const Home({Key? key,required this.username}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late LanguageController _languageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FlipCardState> _cardKey1 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> _cardKey2 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> _cardKey3 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> _cardKey4 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> _cardKey5 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> _cardKey6 = GlobalKey<FlipCardState>();
  bool isFlipped = false;
  late Timer _timer;
  Map<String, dynamic> applicationData = {
    'all': '-',
    'pending': '-',
    'approved': '-',
    'rejected': '-',
  };
  List<Color> cardColors = [
    Colors.yellow,
    Colors.deepOrange,
    Colors.green,
    Colors.red,
  ];

  List<IconData> cardIcons = [
    Icons.settings_applications,
    Icons.pending,
    Icons.check,
    Icons.close,
  ];
  String userName = ''; // Variable to hold the user's name
  String userType = '';


  @override
  void initState() {
    super.initState();
    _languageController = Get.put(LanguageController());
    fetchData();
    _startAutoFlip();
  }
  void _startAutoFlip() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      // Toggle the first card state
      if (_cardKey1.currentState != null) {
        _cardKey1.currentState!.toggleCard();
      }
      if (_cardKey2.currentState != null) {
        _cardKey2.currentState!.toggleCard();
      }
      if (_cardKey3.currentState != null) {
        _cardKey3.currentState!.toggleCard();
      }
      if (_cardKey4.currentState != null) {
        _cardKey4.currentState!.toggleCard();
      }
      if (_cardKey5.currentState != null) {
        _cardKey5.currentState!.toggleCard();
      }

    });
  }
  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  Future<void> fetchData() async {
    final String apiUrl = ApiUrls.dashboard;


    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String sessionKey = prefs.getString('userData_sessionKey') ?? '';
    final String username = prefs.getString('userData_fullName') ?? '';
    final String userType = prefs.getString('userData_userType') ?? '';
    if (sessionKey.isEmpty) {
      print('Session key not found. Please log in first.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $sessionKey',
        },
        body: jsonEncode({
          'session_key': sessionKey,
        }),
      );


      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data is Map<String, dynamic>) {

            setState(() {
              applicationData = {
                'all': int.tryParse(data['all'].toString()) ?? 0,
                'pending': int.tryParse(data['pending'].toString()) ?? 0,
                'approved': int.tryParse(data['approved'].toString()) ?? 0,
                'rejected': int.tryParse(data['rejected'].toString()) ?? 0,
              };
            });

          } else {
            print('Invalid data format: $data');
          }
        } else {
          print('Invalid response format: $responseData');
        }
      } else {
        print('Failed to load application data. Status Code: ${response.statusCode}');
      }
      setState(() {
        userName = prefs.getString('userData_fullName') ?? '';
        this.userType = prefs.getString('userData_userType') ?? '';
      });
      // setState(() {
      //   userName = username;
      //   this.userType = userType;
      // });
    } catch (error) {
      print('Error loading application data: $error');
    }
  }
  void showCustomToast(
      BuildContext context,
      String message,
      String imagePath, {
        int duration = 2,
      }) {
    OverlayEntry? overlayEntry;

    // Create a builder function for the overlay entry
    OverlayEntry createOverlayEntry() {
      return OverlayEntry(
        builder: (BuildContext context) {
          // Calculate the maximum width for the toast message
          double maxWidth = MediaQuery.of(context).size.width * 0.8; // Adjust the fraction as needed
          double messageWidth = (message.length * 8.0) + 48.0; // Calculate initial width based on message length

          // Ensure that the calculated width does not exceed the maximum width
          double finalWidth = messageWidth > maxWidth ? maxWidth : messageWidth;

          return Positioned(
            bottom: 16.0, // Adjust this value to change the distance from the bottom
            left: (MediaQuery.of(context).size.width - finalWidth) / 2, // Center horizontally
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: finalWidth, // Set the width of the container
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(0.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      imagePath,
                      height: 20,
                      width: 20,
                      //color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      message,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // Show the custom toast overlay
    overlayEntry = createOverlayEntry();
    Overlay.of(context)?.insert(overlayEntry!);

    // Remove the overlay after a specified duration
    Future.delayed(Duration(seconds: duration), () {
      overlayEntry?.remove();
    });
  }
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? sessionKey = prefs.getString('userData_sessionKey');
    if (sessionKey == null || sessionKey.isEmpty) {
      print('Session key not found. Please log in first.');
      // Handle the case where session key is not available
      return;
    }
    prefs.clear();
    try {
      print('Sending logout request...');
      final response = await http.post(Uri.parse(ApiUrls.logout),
        // final response = await http.post(
        //   Uri.parse('http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/logout'),
        body: {
          'session_key': sessionKey,
          //'session_key': 'cc125f6b52bf1223e2b2552742a571580eee23e5391b08293dd0870d7ba422f1',
        },
      );

      print('Logout response status code: ${response.statusCode}');
      print('${response.body}');

      if (response.statusCode == 200) {
        // Clear any locally stored session data
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('loggedInUser');


        // Navigate back to the login page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Prsc')),
        );
      } else {
        // If logout failed, display an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout. Please try again.'),
          ),
        );
      }
    } catch (e) {
      // If an error occurs during logout, display an error message
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;
    final _screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: CustomAppBar(logoutCallback: _logout,
      ),
      drawer: CustomDrawer(
        userName: userName,
        userType: userType,
      ),

      body:Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/i2.jpg'), // Replace with your image path
                  fit: BoxFit.cover,
                )
            ),
          ),
          SingleChildScrollView(
            child:Column(
              children: [
                Container(
                  padding:EdgeInsets.all(20.0),
                  child:Column(
                    children:[
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome'.tr+ ', $userName',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                      Text(
                        // '(Farmer)'.tr,
                        '(${'Farmer'.tr})',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                      ],
    ),
                      SizedBox(
                        width: 20, // Add space between text and icon
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 40), // Add margin to the icon
                        child: Icon(
                        FontAwesomeIcons.tractor,
                        size: 80,
                        color: Colors.white,
                       // margin: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ],
                   ),
                    // ],
                    // ),
                      SizedBox(height: 60),
                     Card(
                     color: Colors.blue,
                    child: GestureDetector(
                          onTap: () {

                      Navigator.push(
                     context,
                  MaterialPageRoute(builder: (context) => DisplayData()),
                   );
                    },
                child: FlipCard(
                 key: _cardKey1,
    // key: GlobalKey<FlipCardState>(), // Add a GlobalKey for the FlipCard
            flipOnTouch: false, // Disable flip on touch
           front: Container(
            height: 80,
             child: Card(
               color: Colors.blue,
                shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(0), // Set border radius to 0
                side: BorderSide.none, // Set border side to none
    ),
               child: Center(
                 child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                    Icon(
                      Icons.create,
                size: 40,
               color: Colors.white,
                      ),
                 Text(
                                 'create new request'.tr,
                                 // 'pims'.tr,
                                 style: TextStyle(fontSize: 15, color: Colors.white),
                               ),
    ],
    ),
    ),
    ),
    ),
                 back: Container(
             height: 80,
             child: Card(
              color: Colors.blue,
                shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(0), // Set border radius to 0
                 side: BorderSide.none, // Set border side to none
    ),
                    child: Center(
                 child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [

                   Icon(
                     Icons.create,
                  size: 40,
                 color: Colors.white,
    ),
                   Text(
                     'create new request'.tr,
                     // 'pims'.tr,
                     style: TextStyle(fontSize: 15, color: Colors.white),
                   ),

    ],
    ),
    ),
    ),
    ),
    ),
    ),
                     ),

                      SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              color: Colors.yellow,
                            child:GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MyAp()),
                                );
                              },
                              child: FlipCard(
                                key: _cardKey2,
                                // key: GlobalKey<FlipCardState>(), // Add a GlobalKey for the FlipCard
                                flipOnTouch: false, // Disable flip on touch
                                front: Container(
                                  height: 80,
                            child: Card(
                              color: Colors.yellow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0), // Set border radius to 0
                                side: BorderSide.none, // Set border side to none
                              ),
                        child: Center(
                  child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                      Icon(
                        FontAwesomeIcons.file,
                       size: 40,
                       color: Colors.white,
                   ),
                       Text(
    '${'Total Application'.tr}: ${applicationData['all']}',
    style: TextStyle(fontSize: 13, color: Colors.white),
    ),

    //),
    ],
    ),
    ),
    ),
    ),
                              back: Container(
                                height: 80,
                          child: Card(
                          color: Colors.yellow,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0), // Set border radius to 0
                 side: BorderSide.none, // Set border side to none
                          ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.file,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        '${'Total Application'.tr}: ${applicationData['all']}',
                                        style: TextStyle(fontSize: 13, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ),
                          ),
    ),
                          Expanded(
                            child: Card(
                              color: Colors.deepOrange,
                            child:GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MyyAp()),
                                );
                              },
                              child: FlipCard(
                                key: _cardKey3,
                                //key: GlobalKey<FlipCardState>(),

                                flipOnTouch: false, // Disable flip on touch
                                front: Card(
                              color: Colors.deepOrange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0), // Set border radius to 0
                                    side: BorderSide.none, // Set border side to none
                                  ),
                              child: Container(
                                height: 80,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.file_copy,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        '${'Pending Application'.tr}: ${applicationData['pending']}'.tr,
                                        style: TextStyle(fontSize: 13, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                                back: Container( // Add a back widget for the FlipCard
                                  height: 80,
                                  child: Card(
                                    color: Colors.deepOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0), // Set border radius to 0
                                      side: BorderSide.none, // Set border side to none
                                    ),// Example back card color
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.file_copy,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            '${'Pending Application'.tr}: ${applicationData['pending']}'.tr,
                                            style: TextStyle(fontSize: 13, color: Colors.white),
                                          ), // Add content for the back side of the card if needed
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // autoFlipDuration: Duration(seconds: 3),
                              ),
                          ),
                          ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        children: [

                          Expanded(
                            child:Card(
                              color: Colors.green,
                            child:GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MAp()),
                                );
                              },
                              child: FlipCard(
                                key: _cardKey4,
                                flipOnTouch: false, // Disable flip on touch
                                front: Card(
                              color: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0), // Set border radius to 0
                                    side: BorderSide.none, // Set border side to none
                                  ),
                              child: Container(
                                height: 80,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        cardIcons[2],
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        '${'Approved Application'.tr}: ${applicationData['approved']}'.tr,
                                        style: TextStyle(fontSize: 13, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                                  back: Container(
                            height: 80,
                           child: Card(
                    color: Colors.green,
                   shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(0), // Set border radius to 0
                      side: BorderSide.none, // Set border side to none
    ),
                        child: Center(
                          child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     Icon(
                         cardIcons[2],
                    size: 40,
                   color: Colors.white,
                    ),
                      Text(
                        '${'Approved Application'.tr}: ${applicationData['approved']}'.tr,
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
    ],
    ),
    ),
    ),
    ),
    ),
    ),
    ),),

                          Expanded(
                            child: Card(
                              color: Colors.red,
                           child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>MApp()),
                                );
                              },
                        child: FlipCard(
                       key: _cardKey5,
                       flipOnTouch: false, // Disable flip on touch
                                front: Card(
                          //  child: Card(
                              color: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0), // Set border radius to 0
                                    side: BorderSide.none, // Set border side to none
                                  ),
                              child: Container(
                                height: 80,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        cardIcons[3],
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        '${'Rejected Application'.tr}: ${applicationData['rejected']}'.tr,
                                        style: TextStyle(fontSize: 13, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          back: Card( // Add a back widget for the FlipCard
                            color: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0), // Set border radius to 0
                              side: BorderSide.none, // Set border side to none
                            ),// Example back card color
                            child: Container(
                              height: 80,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      cardIcons[3],
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      '${'Rejected Application'.tr}: ${applicationData['rejected']}'.tr,
                                      style: TextStyle(fontSize: 13, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                          ),
                          ),
                          ),
                        ],
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
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Future<void> Function(BuildContext) logoutCallback;

  CustomAppBar({
    required this.logoutCallback,
  });

  @override
  Size get preferredSize => Size.fromHeight(120.0);

  @override
  Widget build(BuildContext context) {
    LanguageController _languageController = Get.find();
    return AppBar(
      backgroundColor: Colors.blue,
      title: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 3), // Add some top padding
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/wrd_logo.png',
                  width: 60,
                  height: 50,
                ),
                SizedBox(width: 8),
                Text(
                  'pims'.tr,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(width: 8),
                Image.asset(
                  'images/logo.png',
                  width: 60,
                  height: 60,
                ),
              ],
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: Colors.white,
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Adjust as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 4), // Add some spacing above the message text
            Text(
              'message'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //SizedBox(width: 0),
                Container( // Add container to apply margin
                  margin: EdgeInsets.symmetric(horizontal: 10), // Apply margin
                  child: Text(
                  'Farmer'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                ),
                Container( // Add container to apply margin
                  margin: EdgeInsets.symmetric(horizontal: 10), // Apply margin
                  child: Row(
                  children: [
                    Radio(
                      value: 'en',
                      groupValue: _languageController.locale.value!,
                      onChanged: (value) {
                        _languageController.changeLanguage(value as String);
                      },
                    ),
                    Text(
                      'English'.tr,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Radio(
                      value: 'pa',
                      groupValue: _languageController.locale.value!,
                      onChanged: (value) {
                        _languageController.changeLanguage(value as String);
                      },
                    ),
                    Text(
                      'Punjabi'.tr,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(width: 16),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Colors.white, // Set the color to white
          ),
          onSelected: (String value) {
            if (value == 'logout') {
              logoutCallback(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout,),
                title: Text('Logout'.tr),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userType;

  const CustomDrawer({
    required this.userName,
    required this.userType,
  });

  // void _handleDrawerItemClick(String item) {
  //   // Handle item click based on the item name
  //   print('Clicked on: $item');
  //   // You can navigate or perform other actions here
  // }
  void _handleDrawerItemClick(BuildContext context, String item) {
    // Handle item click based on the item name
    print('Clicked on: $item');
    // You can navigate or perform other actions here
    Navigator.pop(context); // Close the drawer after item click
    if (item == 'Home') {
      // Navigate to the Home screen with sliding animation
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0), // Slide from left
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.easeInOut,
            )),
            child: Farmer(username: ''),
          ),
        ),
            (route) => false, // Clear all existing routes
      );
    } else if (item == 'Profile') {
      // Navigate to the Profile screen with sliding animation
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0), // Slide from left
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.easeInOut,
            )),
            child: DisplayDataScreen(),
          ),
        ),
            (route) => false, // Clear all existing routes
      );
    }
    // Add more conditions for other menu items as needed
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:Container(
        color: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //     Text(
                //   'Farmer App',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 24,
                //   ),
                // ),
                Icon(
                  FontAwesomeIcons.tractor,
                  size: 50,
                  color: Colors.white,
                  // margin: EdgeInsets.symmetric(horizontal: 20),
                ),
                SizedBox(height: 4),
                Text(
                  ' $userName ($userType)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Farmer'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),

              ],
            ),

          ),
          ListTile(
            leading: Icon(Icons.home, size: 20, color: Colors.white),
            title: Text('Home'.tr,
    style: TextStyle(
    color: Colors.white,
    ),),
            onTap: () {
              _handleDrawerItemClick(context,'Home');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Farmer(username: '',)),

              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person, size: 20, color: Colors.white),
            title: Text('Profile'.tr,style: TextStyle(
    color: Colors.white,
    ),),
            onTap: () {
              _handleDrawerItemClick(context,'Profile');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DisplayDataScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.description, size: 20, color: Colors.white),
            title: Text('change password'.tr,style: TextStyle(
    color: Colors.white,
    ),),
            onTap: () {
              _handleDrawerItemClick(context,'Change Password');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PasswordChangePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.description, size: 20, color: Colors.white),
            title: Text('create new request'.tr,style: TextStyle(
    color: Colors.white,
    ),),
            onTap: () {
              _handleDrawerItemClick(context,'Create a new request');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DisplayData()),

              );
            },
          ),
          ListTile(
            leading: Icon(Icons.description, size: 20, color: Colors.white),
            title: Text('Total Application'.tr,style: TextStyle(
    color: Colors.white,
    ),),
            onTap: () {
              _handleDrawerItemClick(context,'Total Application');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyAp()),

              );
            },
          ),
          ListTile(
            leading: Icon(Icons.description, size: 20, color: Colors.white),
            title: Text('Pending Application'.tr,style: TextStyle(
    color: Colors.white,
    ),),
            onTap: () {
              _handleDrawerItemClick(context,'Pending Application');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyyAp()),

              );
            },
          ),
          ListTile(
            leading: Icon(Icons.description, size: 20, color: Colors.white),
            title: Text('Approved Application'.tr,style: TextStyle(
    color: Colors.white,
    ),),
            onTap: () {
              _handleDrawerItemClick(context,'Approved Application');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MAp()),

              );
            },
          ),
          ListTile(
            leading: Icon(Icons.description, size: 20, color: Colors.white),
            title: Text('Rejected Application'.tr,style: TextStyle(
    color: Colors.white,
    ),),
            onTap: () {
              _handleDrawerItemClick(context,'Rejected Application');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MApp()),

              );
            },
          ),
          ListTile(
            leading: Icon(Icons.description, size: 20, color: Colors.white),
            title: Text('Help Document'.tr,style: TextStyle(
    color: Colors.white,
    ),),
            onTap: () {
              _handleDrawerItemClick(context,'Help Document');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>MyPdfViewer()),

              );
            },
          ),
        ],
      ),
      ),
    );
  }
}
class LanguageController extends GetxController {
  var locale = 'en'.obs; // Default language is English

  void changeLanguage(String languageCode) {
    locale.value = languageCode;
    Get.updateLocale(Locale(languageCode));
    // You can implement logic to load language settings here
    // For simplicity, I'm just changing the locale value
  }

  String getLanguage() {
    return locale.value;
  }
}