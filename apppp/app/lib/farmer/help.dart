import 'dart:convert';

import 'package:app/farmer/mainfarmer.dart';
import 'package:app/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api_urls.dart';

class MyPdfViewer extends StatefulWidget {

  const MyPdfViewer({super.key});

  @override
  State<MyPdfViewer> createState() => _MyPdfViewerState();
}

class _MyPdfViewerState extends State<MyPdfViewer> {
  late String userName = ''; // Initialize with empty string
  late String userType = '';
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState() {
    super.initState();
    _getUserData();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/download_icon');
    // final IOSInitializationSettings initializationSettingsIOS =
    // IOSInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        );



  }
  Future<void> _handleNotificationClick(String? payload) async {
    if (payload != null) {
      // Navigate to the PDF viewer screen with the downloaded file
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PdfViewerScreen(filePath: payload)),
      );
    }
  }
  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userData_fullName') ?? '';
      userType = prefs.getString('userData_userType') ?? '';
    });
  }

  Future<void> _downloadPdfFromAssets() async {
    if (await _requestStoragePermission()) {
      try {
        ByteData pdfData = await rootBundle.load("assets/pims.pdf");

        // Get the public Downloads folder
        Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');

        if (downloadsDirectory.existsSync()) {
          String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          String savePath = '${downloadsDirectory.path}/pims_$timestamp.pdf';

          File file = File(savePath);
          await file.writeAsBytes(pdfData.buffer.asUint8List());
          const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'your channel id', 'your channel name',
            importance: Importance.max,
            priority: Priority.high,
            // icon: '@mipmap/download_icon',
          );
          const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
          await flutterLocalNotificationsPlugin.show(
            0,
            '',
            '$savePath',
            platformChannelSpecifics,
            payload: savePath,
          );


          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("PDF downloaded to: $savePath"),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Unable to access Downloads folder."),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error downloading PDF: ${e.toString()}"),
          ),
        );
        print("Error downloading PDF: ${e.toString()}");
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Storage permission is required to download PDF."),
        ),
      );
      return false;
    }
  }

  void _showPdfOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
            data: Theme.of(context).copyWith(
          dialogBackgroundColor: Colors.tealAccent, // Background color of the AlertDialog

        ),
        child:AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0), // Rounded corners
          ),
          title: Text('Action on File'.tr, textAlign: TextAlign.center,style: TextStyle(color: Colors.white),),
         // content: Text(""),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PdfViewerScreen(filePath: '')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Background color of the ElevatedButton
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  'View'.tr.toUpperCase(),
                  style: TextStyle(color: Colors.white), // Text color of the button text
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _downloadPdfFromAssets();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Background color of the ElevatedButton
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  'Download'.tr.toUpperCase(),
                  style: TextStyle(color: Colors.white), // Text color of the button text
                ),
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => PdfViewerScreen()),
            //     );
            //   },
            //   child: Text('View'.tr),
            // ),
            // TextButton(
            //   onPressed: () {
            //     Navigator.pop(context);
            //     _downloadPdfFromAssets();
            //   },
            //   child: Text('Download'.tr),
            // ),
          ],
        ),
        );
      },
    );
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
    return  MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WillPopScope(
        onWillPop: () async {
      // Navigate to mainxenpage when back button is pressed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Farmer(username: '')),
      );
      return false;
    },
    child:Scaffold(
      appBar: CustomAppBar(logoutCallback: _logout,
        // Access ScaffoldState and open drawer
      ),
      drawer: CustomDrawer(userName: userName, userType: userType),
      body:
      Stack(
        fit: StackFit.expand,
        children: [
        // Background Image
          Image.asset(
            'images/i2.jpg', // Replace with your actual image path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
       Positioned(
        left: 0,
         right: 0,
        top: 10,
         child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
               children: [
                  Text(
                    'HelpDocument'.tr,
              style: TextStyle(color: Colors.white),
                  ),
    SizedBox(height: 20), // Adjust the spacing as needed
    // PDF Viewer Button
         Padding(
           padding: EdgeInsets.symmetric(horizontal: 10), // Add margin here
           child: Container(
               width: double.infinity,
               color: Colors.blue,
               child: TextButton(
                 onPressed: () => _showPdfOptions(context),
                 style: TextButton.styleFrom(
                   foregroundColor: Colors.white,
                 ),
    child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: Text('ViewDocument'.tr.toUpperCase()),
    ),
    ),
    ),
         ),
    ],
        ),
    ),
      ],
        ),
        ),
    ),
    );
  }
}
class PdfViewerScreen extends StatefulWidget {
  final String filePath;
  PdfViewerScreen({required this.filePath});
  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late String userName = ''; // Initialize with empty string
  late String userType = '';
  @override
  void initState() {
    super.initState();
    _getUserData();
  }
  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userData_fullName') ?? '';
      userType = prefs.getString('userData_userType') ?? '';
    });
  }
//class PdfViewerScreen extends StatelessWidget {
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
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WillPopScope(
        onWillPop: () async {
      // Navigate to mainxenpage when back button is pressed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyPdfViewer()),
      );
      return false;
    },
    child:Scaffold(
      appBar: CustomAppBar(logoutCallback: _logout,
        // Access ScaffoldState and open drawer
      ),
      drawer: CustomDrawer(userName: userName, userType: userType),
      body: SfPdfViewer.asset("assets/pims.pdf"),
    ),
        ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyPdfViewer(),
  ));
}