import 'package:app/api_urls.dart';
import 'package:app/farmer/mainfarmer.dart';
import 'package:app/home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordChangePage extends StatefulWidget {
  @override
  _PasswordChangePageState createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  late String userName = ''; // Initialize with empty string
  late String userType = '';
  bool isPasswordChanged = false;
  bool obscureOldPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch userName and userType when the page initializes
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userData_fullName') ?? '';
    userType = prefs.getString('userData_userType') ?? '';
    setState(() {}); // Update the UI after fetching data
  }
  Future<void> changePassword(BuildContext context) async {
    final oldPassword = oldPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String sessionKey = prefs.getString('userData_sessionKey') ?? '';
    // userName = prefs.getString('userData_fullName') ?? '';
    // userType = prefs.getString('userData_userType') ?? '';
    //final sessionKey = '83a92e686ca17a3f97ab70babe7cf52004cfbabb0e1aad41404a94cf73dab431';


    final url = ApiUrls.changePasswordUrl;
    //final url = 'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/changepassword';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $sessionKey',
        },
        body: jsonEncode(<String, String>{
          'oldpassword': oldPassword,
          'newpassword': newPassword,
          'confirmpassword': confirmPassword,
          'session_key': sessionKey,
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['error'] == false) {
          showCustomToast(context, jsonResponse['message'], 'images/wrd_logo.png');
        } else {
          showCustomToast(context, jsonResponse['message'], 'images/wrd_logo.png');
        }
      } else {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['error'] == true && jsonResponse.containsKey('message')) {
          showCustomToast(context, jsonResponse['message'], 'images/wrd_logo.png');
        } else {
          showCustomToast(context, 'An error occurred. Please try again.', 'images/wrd_logo.png');
        }
      }
    }catch (error) {
      print('Error during password change: $error');
      showCustomToast(context, 'Error during password change. Please try again.', 'images/wrd_logo.png');
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
    return  WillPopScope(
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
    body: SingleChildScrollView(
      child:
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(
    image: DecorationImage(
    image: AssetImage("images/i2.jpg"), // Replace with your image asset path
    fit: BoxFit.cover,
    ),
    ),

      child: Padding(

        padding: EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Change Password'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child:Text(

                'Name'.tr+ ' $userName($userType)',
                style: TextStyle(color: Colors.white,fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 250.0,
              child: Container(
                color: Colors.white.withOpacity(0.19),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildPasswordField(
                      controller: oldPasswordController,
                      labelText: 'Old Password'.tr,
                      obscureText: obscureOldPassword,
                      onPressed: () {
                        setState(() {
                          obscureOldPassword = !obscureOldPassword;
                        });
                      },
                    ),

                    buildPasswordField(
                      controller: newPasswordController,
                      labelText: 'New Password'.tr,
                      obscureText: obscureNewPassword,
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                    buildPasswordField(
                      controller: confirmPasswordController,
                      labelText: 'Confirm Password'.tr,
                      obscureText: obscureConfirmPassword,
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity, // Match the width of the SizedBox
              child: ElevatedButton(
                onPressed: () => changePassword(context),
                child: Text(
                  'Change Password'.tr.toUpperCase(),
                  style: TextStyle(color: Colors.white), // Set text color to white
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Set border radius
                  ),
                  backgroundColor: Colors.blue, // Set button background color to blue
                ),
              ),
            ),


          ],
        ),
      ),
    ),
   // ],
    ),
       // ),
    ),
    //),
    );
  }
  Widget buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onPressed,
  }) {
    return Container(
      color: Colors.white.withOpacity(0.19),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(color: Colors.white),
            ),
            obscureText: obscureText,
          ),
          IconButton(
            icon: Icon(Icons.visibility, color: Colors.white, ),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

