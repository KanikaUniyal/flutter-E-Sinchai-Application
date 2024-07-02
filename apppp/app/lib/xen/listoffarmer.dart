import 'dart:convert';
import 'package:app/api_urls.dart';
import 'package:app/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'listoffamerdetails.dart';
import 'mainxen.dart';

void main() {
  runApp(MyApp());
}

class Farmer {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String mobile;
  final String user_type;
  final String dob;
  final String userId;
  final String gender;
  final String fatherName;
  final String address;
  final String district;
  final String tehsil;
  final String block;
  final String village;
  final String createdDate;

  Farmer({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.userId,
    required this.mobile,
    required this.user_type,
    required this.dob,
    required this.gender,
    required this.fatherName,
    required this.address,
    required this.district,
    required this.tehsil,
    required this.block,
    required this.village,
    required this.createdDate,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'] ?? "",
      userId: json['user_id'] ?? "",
      fullName: json['full_name'] ?? "",
      userName: json['user_name'] ?? "",
      email: json['email'] ?? "",
      mobile: json['mobile'] ?? "",
      user_type: json['user_type'] ?? "",
      dob: json['dob'] ?? "",
      gender: json['gender'] ?? "",
      fatherName: json['father_name'] ?? "",
      address: json['address'] ?? "",
      district: json['district'] ?? "",
      tehsil: json['tehsil'] ?? "",
      block: json['block'] ?? "",
      village: json['village'] ?? "",
      createdDate: json['created_date'] ?? "",
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String userName = ''; // Variable to hold the user's name
  String userType = '';
  String fullName = '';
  final String apiUrl = ApiUrls.farmerList;
  String _searchQuery = '';

  Future<Map<String, String?>> getSessionKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionKey = prefs.getString('userData_sessionKey');


    return {
      'sessionKey': sessionKey,

    };
  }

  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userData_userName') ?? "";
    userType = prefs.getString('userData_userType') ?? "";
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getSessionKey();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Xen()),
          );
          return false;
        },
        child: Scaffold(
          appBar: XenCustomAppBar(logoutCallback: _logout, userType: userType),
          drawer: XenCustomDrawer(
            userName: userName,
            userType: userType,
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/i2.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),

                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          onChanged: _updateSearchQuery,
                          decoration: InputDecoration(
                            //labelText: 'Search',
                            //prefixIcon: Icon(Icons.search),
                            hintText: 'List of Farmers',
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors
                                  .white), // Set the border color here
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.19),
                          borderRadius: BorderRadius.circular(0.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            FutureBuilder<List<Farmer>>(
                              future: fetchData(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                      child: Text(''));
                                } else {
                                  final sessionData = getSessionKey();
                                  return FutureBuilder<Map<String, String?>>(
                                    future: sessionData,
                                    builder: (context, sessionSnapshot) {
                                      if (sessionSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else if (sessionSnapshot.hasError) {
                                        return Center(child: Text(
                                            'Error: ${sessionSnapshot.error}'));
                                      } else if (!sessionSnapshot.hasData ||
                                          sessionSnapshot.data!['sessionKey'] ==
                                              null) {
                                        return Center(child: Text(
                                            'Session key not found'));
                                      } else {
                                        return FarmerList(
                                            farmers: getFilteredFarmers(
                                                snapshot.data!),
                                            sessionKey: sessionSnapshot
                                                .data!['sessionKey']!);
                                      }
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<Map<String, String?>> getSessionKey() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? sessionKey = prefs.getString('userData_sessionKey');
  //   String? userName = prefs.getString('userData_userName');
  //   String? userType = prefs.getString('userData_userType');
  //
  //
  //   return {
  //     'sessionKey': sessionKey,
  //     'userName': userName,
  //     'userType': userType,
  //   };
  // }
  // @override
  // void initState() {
  //   super.initState();
  //   getSessionKey();
  // }


  Future<List<Farmer>> fetchData() async {
    //Future<List<String>> fetchData() async {
    Map<String, String?> sessionData = await getSessionKey();
    String? sessionKey = sessionData['sessionKey'];
    if (sessionKey == null) {
      throw Exception('Session key not found');
    }
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {"session_key": sessionKey},
    );
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      //final List<dynamic> data = json.decode(response.body)['data'];
      final dynamic jsonData = json.decode(response.body);
      if (jsonData['error'] &&
          jsonData['message'] == 'Session Expired, Please login again.') {
        // Do not show toast for session expiration message
        return [];
      }
      else if (jsonData['error']) {
        showCustomToast(
          context,
          jsonData['message'],
          'images/wrd_logo.png', // Provide the correct image path here
        );
        return [];
      }
      else {
        final List<dynamic> data = jsonData['data'];
        if (data.isNotEmpty) {
          // saveMobileNumbers(data);
          List<String> mobileNumbers = data.map((
              json) => json['mobile'] as String).toList();
          // printMobileNumbers(mobileNumbers);
          // // Save mobile numbers to SharedPreferences
          // saveMobileNumbers(mobileNumbers);
          return data.map((json) => Farmer.fromJson(json)).toList();
        }
        // else {   Fluttertoast.showToast(
        //   msg: 'No data found.',
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.CENTER,
        //   timeInSecForIosWeb: 1,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
        return []; // Return empty list
      }
    }
  else
   {
        throw Exception('Data is empty');
      }
    }

  void printMobileNumbers(List<String> mobileNumbers) {
    print('Mobile Numbers:');
    mobileNumbers.forEach((mobileNumber) {
      print(mobileNumber);
    });
  }
  void saveMobileNumbers(List<String> mobileNumbers) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? existingMobileNumbers = prefs.getStringList('farmerMobileNumbers');
    if (existingMobileNumbers == null) {
      existingMobileNumbers = [];
    }
    existingMobileNumbers.addAll(mobileNumbers);
    await prefs.setStringList('farmerMobileNumbers', existingMobileNumbers);
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
      return;
    }
    prefs.clear();
    try {
      final response = await http.post(Uri.parse(ApiUrls.logout),
        body: {
          'session_key': sessionKey,
        },
      );

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
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout. Please try again.'),
        ),
      );
    }
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  List<Farmer> getFilteredFarmers(List<Farmer> farmers) {
    if (_searchQuery.isEmpty) {
      return farmers;
    }

    return farmers.where((farmer) {
      return farmer.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farmer.user_type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farmer.village.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
}

class FarmerList extends StatelessWidget {
  final List<Farmer> farmers;
  final String sessionKey;

  FarmerList({required this.farmers, required this.sessionKey});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: farmers.map((farmer) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Name: ${farmer.fullName}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold, // Bold the text
                  ),
                ),
                subtitle: Text(
                  'User Type: ${farmer.user_type}\nVillage: ${farmer.village}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              SizedBox(height: 10.0),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FarmerDetailsPage(farmer: farmer),
                      ),
                    );
                  },
                  child: Text('View Details'.tr.toUpperCase()),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0), // Adjust the radius as needed
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    // Set button color to green
                  ),
                ),
              ),
              SizedBox(height: 4.0),
              Divider(), // Add a divider between items
            ],
          );
        }).toList(),
      ),
    //),
    //]
    //)
   // )
   // )
    //)
    );
  }
}