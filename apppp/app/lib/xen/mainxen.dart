import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:app/xen/giselection.dart';
import 'package:app/xen/helpdocument.dart';
import 'package:flip_card/flip_card.dart';
import 'package:app/farmer/changepassword.dart';
import 'package:app/farmer/totalapplicationfarmer.dart';
import 'package:app/home.dart';
import 'package:app/xen/approved.dart';
import 'package:app/xen/delayjustification.dart';
import 'package:app/xen/listofofficial.dart';
import 'package:app/xen/managenewrequest.dart';
import 'package:app/xen/passchange.dart';
import 'package:app/xen/pending.dart';
import 'package:app/xen/rejectedxen.dart';
import 'package:app/xen/updateprofilexen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_urls.dart';
import '../farmer/mainfarmer.dart';
import 'package:http/http.dart'as http;
import 'listoffarmer.dart';
import 'totalapplication.dart';
import 'managenewrequest.dart';

void main() {
  runApp(Xen());
}

class Xen extends StatelessWidget {
  const Xen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xen Dashboard',
      debugShowCheckedModeBanner: false,
      home: Homee(),
    );
  }
}

class Homee extends StatefulWidget {
  const Homee({Key? key}) : super(key: key);

  @override
  State<Homee> createState() => _HomeState();
}

class _HomeState extends State<Homee> {
  bool isFlipped = false;
  late Timer _timer;

  GlobalKey<FlipCardState> _cardKey1 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> _cardKey2 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> _cardKey3 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> _cardKey4 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> _cardKey5 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> _cardKey6 = GlobalKey<FlipCardState>();
  bool _flipped1 = false;
  bool _flipped2 = false;
  bool _flipped3 = false;
  bool _flipped4 = false;
  bool _flipped5 = false;
  bool _flipped6 = false;
  Map<String, dynamic> applicationData = {
    'all': '-',
    'pending': '-',
    'approved': '-',
    'rejected': '-',
    'manage':'-',
    'delayjustification':'-',
  };
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
    fetchData();
    _startAutoFlip();// Call the fetchData method when the widget is initialized
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
      if (_cardKey6.currentState != null) {
        _cardKey6.currentState!.toggleCard();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
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

      print('API URL: $apiUrl');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
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
                'manage':int.tryParse(data['manage'].toString())??0,
                'delayjustification_pending':int.tryParse(data['delayjustification_pending'].toString())??0,
                'delayjustification':int.tryParse(data['delayjustification'].toString())??0,
              };
              userName = username;
              this.userType = userType;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XenCustomAppBar(logoutCallback: _logout, userType: userType,
      ),
      drawer: XenCustomDrawer(
        userName: userName,
        userType: userType,
      ),
      body: Stack(
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
                        'Welcome'.tr+ ', $userName($userType)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Authorities'.tr,
                        //'(${'Farmer'.tr})',
                        style: TextStyle(fontSize: 16),
                      ),
                      ],
                    ),
                      SizedBox(
                        width: 20, // Add space between text and icon
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20), // Add margin to the icon
                        child: Icon(
                          FontAwesomeIcons.users,
                          size: 80,
                          color: Colors.white,
                          // margin: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                      ],
                    ),


                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                           child: Card(
                             color: Colors.blue,
                            child: GestureDetector(
                              onTap: () {
                                // if (!_flipped1) {
                                //   _flipped1 = true;
                                //   _cardKey1.currentState?.toggleCard();
                                // }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Myyy()),
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
                                            cardIcons[0],
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            '${'Manage new request'.tr}:${applicationData['manage']}',
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
                                            cardIcons[0],
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            '${'Manage new request'.tr}:${applicationData['manage']}',
                                            style: TextStyle(fontSize: 13, color: Colors.white),
                                          ),

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


                          Expanded(
                            child: Card(
                              color: Colors.redAccent,
                            child: GestureDetector(
                              onTap: () {
                                // if (!_flipped2) {
                                //   _flipped2 = true;
                                //   _cardKey2.currentState?.toggleCard();
                                // }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Mz()),
                                );
                              },
                              child: FlipCard(
                                key: _cardKey2,
                                //key: GlobalKey<FlipCardState>(),

                                flipOnTouch: false, // Disable flip on touch
                                front: Card(
                                  color: Colors.redAccent,
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
                                            cardIcons[1],
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            '${'Delay Justifications'.tr}:${applicationData['delayjustification']}|${'Pending'.tr}:${applicationData['delayjustification_pending']}',
                                            style: TextStyle(fontSize: 12, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                back: Container( // Add a back widget for the FlipCard
                                  height: 80,
                                  child: Card(
                                    color: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0), // Set border radius to 0
                                      side: BorderSide.none, // Set border side to none
                                    ),// Example back card color
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            cardIcons[1],
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            '${'Delay Justifications'.tr}:${applicationData['delayjustification']}|${'Pending'.tr}:${applicationData['delayjustification_pending']}',
                                            style: TextStyle(fontSize: 12, color: Colors.white),
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

                      Row(
                        children: [

                          Expanded(
                            child: Card(
                              color: Colors.orange,
                            child: FlipCard(
                              key: _cardKey3,
                              flipOnTouch: false, // Disable flip on touch
                              front: GestureDetector(
                                onTap: () {
                                  // if (!_flipped3) {
                                  //   _flipped3 = true;
                                  //   _cardKey3.currentState?.toggleCard();
                                  // }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PendingMyAp()),
                                  );
                                },
                                child: Container(
                                  height: 80,
                                  child: Card(
                                    color: Colors.orange,
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
                                              '${'Pending Application'.tr}:${applicationData['pending']}',
                                              style: TextStyle(fontSize: 13, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              back: Container(
                                height: 80,
                                child: Card(
                                  color: Colors.orange,
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
                                          '${'Pending Application'.tr}:${applicationData['pending']}',
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

                          Expanded(
                            child:Card(
                              color: Colors.yellow,
                            child: GestureDetector(
                              onTap: () {
                                // if (!_flipped4) {
                                //   _flipped4 = true;
                                //   _cardKey4.currentState?.toggleCard();
                                // }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MyAppp()),
                                );
                              },
                              child: FlipCard(
                                key: _cardKey4,
                                flipOnTouch: false, // Disable flip on touch
                                front: Card(
                                  color: Colors.yellow,
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
                                            '${'Total Application'.tr}:${applicationData['all']}',
                                            style: TextStyle(fontSize: 13, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                back: Card( // Add a back widget for the FlipCard
                                  color: Colors.yellow,
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
                                            '${'Total Application'.tr}:${applicationData['all']}',
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


                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              color: Colors.green,
                            child: FlipCard(
                              key: _cardKey5,
                              flipOnTouch: false, // Disable flip on touch
                              front: GestureDetector(
                                onTap: () {
                                  // if (!_flipped5) {
                                  //   _flipped5 = true;
                                  //   _cardKey5.currentState?.toggleCard();
                                  // }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => My()),
                                  );
                                },
                                child: Container(
                                  height: 80,
                                  child: Card(
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
                                              Icons.approval,
                                              //cardIcons[2],
                                              size: 40,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              '${'Approved Application'.tr}:${applicationData['approved']}',

                                              style: TextStyle(fontSize: 13, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
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
                                          Icons.approval,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          '${'Approved Application'.tr}:${applicationData['approved']}',

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

                          Expanded(
                            child: Card(
                              color: Colors.red,
                            child: GestureDetector(
                              onTap: () {
                                // if (!_flipped6) {
                                //   _flipped6 = true;
                                //   _cardKey6.currentState?.toggleCard();
                                // }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => rejectedMyAp()),
                                );
                              },
                              child: FlipCard(
                                key: _cardKey6,
                                flipOnTouch: false, // Disable flip on touch
                                front: Card(
                                  color: Colors.red,
                                  // shape: RoundedRectangleBorder(
                                  //   borderRadius: BorderRadius.circular(0), // Set border radius to 0
                                  //   side: BorderSide.none, // Set border side to none
                                  // ),
                                  child: Container(
                                    height: 80,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.disabled_by_default,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            '${'Rejected Application'.tr}:${applicationData['rejected']}',
                                            style: TextStyle(fontSize: 13, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                back:
                                Card( // Add a back widget for the FlipCard
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
                                            Icons.disabled_by_default,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            '${'Rejected Application'.tr}:${applicationData['rejected']}',
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




class XenCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Future<void> Function(BuildContext) logoutCallback;
  final String userType;

  XenCustomAppBar({
    required this.logoutCallback,
    required this.userType,
  });

  @override
  Size get preferredSize => Size.fromHeight(120.0); // Increased height for better display

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns the content to the right
              children: [
                Container( // Add container to apply margin
                  margin: EdgeInsets.symmetric(horizontal: 5), // Apply margin
                  child: Text(
                    '$userType',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container( // Add container to apply margin
                  margin: EdgeInsets.symmetric(horizontal: 10), // Apply margin
                  child:Row(
                    children: [
                      Radio(
                        value: 'en',
                        groupValue: _languageController.locale.value!,
                        onChanged: (value) {
                          _languageController.changeLanguage(value as String);
                        },
                      ),
                      Text('English'.tr, style: TextStyle(
                        color: Colors.white,
                      ),),
                      Radio(
                        value: 'pa',
                        groupValue: _languageController.locale.value!,
                        onChanged: (value) {
                          _languageController.changeLanguage(value as String);
                        },
                      ),
                      Text('Punjabi'.tr, style: TextStyle(
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

                leading: Icon(Icons.logout),
                title: Text('Logout'.tr),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
class XenCustomDrawer extends StatelessWidget {
  final String userName;
  final String userType;

  const XenCustomDrawer({
    required this.userName,
    required this.userType,
  });

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
            child: Homee(),
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
            child: UpdateDisplayDataScreen(),
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
        color:Colors.black,
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
                    FontAwesomeIcons.user,
                    size: 50,
                    color: Colors.white,
                    // margin: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$userName (${ "gis".tr })',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Authorities'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, size: 20, color: Colors.white),
              title: Text('Home'.tr,style: TextStyle(
                color: Colors.white,
              ),),
              onTap: () {
                _handleDrawerItemClick(context,'Home');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Homee()),

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
                  MaterialPageRoute(builder: (context) => UpdateDisplayDataScreen()),
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
                  MaterialPageRoute(builder: (context) => XenPasswordChangePage()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.person, size: 20, color: Colors.white),
              title: Text('gis'.tr,style: TextStyle(
                color: Colors.white,
              ),),
              onTap: () {
                _handleDrawerItemClick(context,'GIS Election');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => giselection()),
                );
              },
            ),


            ListTile(
              leading: Icon(Icons.description, size: 20, color: Colors.white),
              title: Text('List of Officials'.tr,style: TextStyle(
                color: Colors.white,
              ),),
              onTap: () {
                _handleDrawerItemClick(context,'List of Officals');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => official()),

                );
              },
            ),
            ListTile(
              leading: Icon(Icons.description, size: 20, color: Colors.white),
              title: Text('List of Farmers'.tr,style: TextStyle(
                color: Colors.white,
              ),),
              onTap: () {
                _handleDrawerItemClick(context,'List of Farmers');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),

                );
              },
            ),
            ListTile(
              leading: Icon(Icons.description, size: 20, color: Colors.white),
              title: Text('Manage new request'.tr,style: TextStyle(
                color: Colors.white,
              ),),
              onTap: () {
                _handleDrawerItemClick(context,'Manage new request');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Myyy()),

                );
              },
            ),
            ListTile(
              leading: Icon(Icons.description, size: 20, color: Colors.white),
              title: Text('Delay Justifications'.tr,style: TextStyle(
                color: Colors.white,
              ),),
              onTap: () {
                _handleDrawerItemClick(context,'Delay Justifications');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Mz()),

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
                  MaterialPageRoute(builder: (context) => MyAppp()),

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
                  MaterialPageRoute(builder: (context) => PendingMyAp()),

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
                  MaterialPageRoute(builder: (context) => My()),

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
                  MaterialPageRoute(builder: (context) =>rejectedMyAp()),

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
                  MaterialPageRoute(builder: (context) =>MyPdfView()),

                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

