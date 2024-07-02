import 'dart:convert';

import 'package:app/home.dart';
import 'package:app/xen/listofofficalviewstatus.dart';
import 'package:app/xen/mainxen.dart';
import 'package:app/xen/totalapplication.dart';
import 'package:app/xen/totalapplicationdetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api_urls.dart';
import 'listofofficial.dart';

class Farmofficial {
  final String id;
  final String applicationType;
  final String natureOfApplication;
  final String userId;
  final String fullName;
  final String email;
  final String mobile;
  final String fatherName;
  final String address;
  final String aadhar;
  final String district;
  final String tehsil;
  final String block;
  final String village;
  final String waterChannel;
  final String outlet;
  final String patwariName;
  final String acreageOfLand;
  final String mustilNo;
  final String killaNo;
  final String reason;
  final String createdDate;
  final String status;
  final String statusRemarks;

  Farmofficial({
    required this.id,
    required this.applicationType,
    required this.natureOfApplication,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.fatherName,
    required this.address,
    required this.aadhar,
    required this.district,
    required this.tehsil,
    required this.block,
    required this.village,
    required this.waterChannel,
    required this.outlet,
    required this.patwariName,
    required this.acreageOfLand,
    required this.mustilNo,
    required this.killaNo,
    required this.reason,
    required this.createdDate,
    required this.status,
    required this.statusRemarks,
  });

  factory Farmofficial.fromJson(Map<String, dynamic> json) {
    return Farmofficial(
      id: json['id'] ?? "",
      applicationType: json['application_type'] ?? "",
      natureOfApplication: json['nature_of_application'] ?? "",
      userId: json['user_id'] ?? "",
      fullName: json['full_name'] ?? "",
      email: json['email'] ?? "",
      mobile: json['mobile'] ?? "",
      fatherName: json['father_name'] ?? "",
      address: json['address'] ?? "",
      aadhar: json['aadhar'] ?? "",
      district: json['district'] ?? "",
      tehsil: json['tehsil'] ?? "",
      block: json['block'] ?? "",
      village: json['village'] ?? "",
      waterChannel: json['water_channel'] ?? "",
      outlet: json['outlet'] ?? "",
      patwariName: json['patwari_name'] ?? "",
      acreageOfLand: json['acerage_of_land'] ?? "",
      mustilNo: json['mustil_no'] ?? "",
      killaNo: json['killa_no'] ?? "",
      reason: json['reason'] ?? "",
      createdDate: json['created_date'] ?? "",
      status: json['status'] ?? "",
      statusRemarks: json['status_remarks'] ?? "",
    );
  }
}


class OfficialDetailsPage extends StatefulWidget {
  final Farmzz farmer;

  OfficialDetailsPage({required this.farmer});

  @override
  _OfficialDetailsPageState createState() => _OfficialDetailsPageState();
}

class _OfficialDetailsPageState extends State<OfficialDetailsPage> {
  late Future<List<Map<String, dynamic>>> _fetchData;
  final String _apiUrl = ApiUrls.applicationList;
  late String _sessionKey = '';
  String userName = ''; // Variable to hold the user's name
  String userType = '';



  //get farmer => null;

  @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  Future<void> _autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      String? storedSessionKey = prefs.getString('userData_sessionKey');
      String? storedUsername = prefs.getString('userData_fullName');
      String? storedUserType = prefs.getString('userData_userType');
      if (storedSessionKey != null) {
        setState(() {
          _sessionKey = storedSessionKey;
          this.userName = storedUsername!;
          this.userType = storedUserType!;
        });
        _fetchData = _fetchApplications('all');
      }
    } else {
      // Handle scenario when user is not logged in
      // For example, you can navigate to a login screen or show a message
    }
  }

  Future<List<Map<String, dynamic>>> _fetchApplications(String status) async {
    try {
      if (_sessionKey.isEmpty) {
        throw Exception("Session key is empty");
      }

      var url = Uri.parse(_apiUrl);
      var headers = {"Content-Type": "application/json"};
      var body = {
        "session_key": _sessionKey,
        "status": status,
      };

      var bodyJson = jsonEncode(body);
      final response = await http.post(
        url,
        headers: headers,
        body: bodyJson,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];

        if (data.isNotEmpty) {
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Data is empty');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error during API call: $error');
      throw error;
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

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('loggedInUser');



        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Prsc')),
        );
      } else {

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
            MaterialPageRoute(builder: (context) => official()),
          );
          return false;
        },
        child: Scaffold(
          appBar: XenCustomAppBar(logoutCallback: _logout, userType: userType),
          drawer: XenCustomDrawer(
            userName: userName,
            userType: userType,
          ),
          body: SingleChildScrollView( // Wrap the body with SingleChildScrollView
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/i2.jpg'), // Provide your image path here
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Adding white box with opacity above 'Personal Information'
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.19),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildSectionTitle('Personal Information'.tr),
                            Text('Name'.tr, style: TextStyle(color: Colors.white)),
                            buildTextField(widget.farmer.fullName),
                            Text('Father Name'.tr, style: TextStyle(color: Colors.white)),
                            buildTextField(widget.farmer.fatherName),
                            Text('Mobile No'.tr, style: TextStyle(color: Colors.white)),
                            buildTextField(widget.farmer.mobile),
                            Text('Email'.tr, style: TextStyle(color: Colors.white)),
                            buildTextField(widget.farmer.email),
                            Text('User Type'.tr, style: TextStyle(color: Colors.white)),
                            buildTextField(widget.farmer.user_type),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.purple),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: Colors.purple),
                            ),
                          ),
                        ),
                        child: Text(
                          'Application Status'.tr.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else {
                          final applications = snapshot.data ?? [];
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: applications.length,
                            itemBuilder: (context, index) {
                              final application = applications[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Center(
                                            child: RichText(
                                              text: TextSpan(
                                                text: 'Request Id: ${application['id']}    Request Date: ${application['created_date']}\n\n',
                                                style: TextStyle(color: Colors.black),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: 'ApplicationType: ',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                    text: '${application['application_type']}\n',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                    text: 'Nature of Application: ',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                    text: '${application['nature_of_application']}\n\n',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                    text: 'Outlet No: ${application['outlet']}  Farmer Name: ${application['full_name']}\n\n',
                                                  ),
                                                  TextSpan(
                                                    text: 'Village Name: ${application['village']}',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2.0),
                                        Container(
                                          height: 50,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => xendetailspage(farmer: Farmerrl.fromJson(application))),
                                              );
                                            },
                                            style: getStatusButtonStyle(application['status']),
                                            child: Text(
                                              'View status'.tr.toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle getStatusButtonStyle(String status) {
    Color buttonColor;

    switch (status.toLowerCase()) {
      case 'pending':
      case 'in process':
        buttonColor = Colors.orange;
        break;
      case 'approved':
        buttonColor = Colors.green;
        break;
      case 'rejected':
        buttonColor = Colors.red;
        break;
      default:
        buttonColor =
            Colors.grey; // Default color, you can change it as needed
    }

    return ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Set border radius to zero
      ),

      minimumSize: Size(140, 1),
    );
  }

  Widget buildTextField(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
    child: Container(
      width: double.infinity,
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.19),
    borderRadius: BorderRadius.circular(8.0),
    ),
      child: TextField(
        decoration: InputDecoration(
          //labelText: label,
          border: OutlineInputBorder(),
        ),
        style: TextStyle(color: Colors.white),
        controller: TextEditingController(text: value),
        readOnly: true,
      ),
    ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}