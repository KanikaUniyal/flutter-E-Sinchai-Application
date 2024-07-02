import 'dart:convert';
import 'package:app/api_urls.dart';
import 'package:app/home.dart';
import 'package:app/xen/mainxen.dart';
import 'package:app/xen/managenewrequestdetail.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  runApp(MaterialApp(
    home: Myyy(),
  ));
}
// Define the Farmerrl class
class Farmr {
  final String id;
  final String application_type;
  final String nature_of_application;
  final String user_id;
  final String full_name;
  final String email;
  final String mobile;
  final String father_name;
  final String address;
  final String aadhar;
  final String district;
  final String tehsil;
  final String block;
  final String village;
  final String water_channel;
  final String outlet;
  final String patwari_name;
  final String acerage_of_land;
  final String mustil_no;
  final String killa_no;
  final String reason;
  final String created_date;
  final String status;
  final String status_remarks;

  Farmr({
    required this.id,
    required this.application_type,
    required this.nature_of_application,
    required this.user_id,
    required this.full_name,
    required this.email,
    required this.mobile,
    required this.father_name,
    required this.address,
    required this.aadhar,
    required this.district,
    required this.tehsil,
    required this.block,
    required this.village,
    required this.water_channel,
    required this.outlet,
    required this.patwari_name,
    required this.acerage_of_land,
    required this.mustil_no,
    required this.killa_no,
    required this.reason,
    required this.created_date,
    required this.status,
    required this.status_remarks,
  });

  factory Farmr.fromJson(Map<String, dynamic> json) {
    return Farmr(
      id: json['id'] ?? "",
      application_type: json['application_type'] ?? "",
      nature_of_application: json['nature_of_application'] ?? "",
      user_id: json['user_id'] ?? "",
      full_name: json['full_name'] ?? "",
      email: json['email'] ?? "",
      mobile: json['mobile'] ?? "",
      father_name: json['father_name'] ?? "",
      address: json['address'] ?? "",
      aadhar: json['aadhar'] ?? "",
      district: json['district'] ?? "",
      tehsil: json['tehsil'] ?? "",
      block: json['block'] ?? "",
      village: json['village'] ?? "",
      water_channel: json['water_channel'] ?? "",
      outlet: json['outlet'] ?? "",
      patwari_name: json['patwari_name'] ?? "",
      acerage_of_land: json['acerage_of_land'] ?? "",
      mustil_no: json['mustil_no'] ?? "",
      killa_no: json['killa_no'] ?? "",
      reason: json['reason'] ?? "",
      created_date: json['created_date'] ?? "",
      status: json['status'] ?? "",
      status_remarks: json['status_remarks'] ?? "",
    );
  }
}

// Define the MyAppp StatefulWidget
class Myyy extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// Define the _MyAppState State class
class _MyAppState extends State<Myyy> {
  final String apiUrl = ApiUrls.applicationList;
  late String sessionKey;
  late List<Farmr> farmers;
  late List<Farmr> filteredFarmers = [];
  TextEditingController searchController = TextEditingController();
  String userName = '';
  String userType = '';
  Future<void> _autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      String? storedSessionKey = prefs.getString('userData_sessionKey');
      String? storedUsername = prefs.getString('userData_fullName');
      String? storedUserType = prefs.getString('userData_userType');
      if (storedSessionKey != null) {
        setState(() {
         this.sessionKey = storedSessionKey;
         this. userName = storedUsername!;
          this.userType = storedUserType!;
        });
        fetchData('manage').then((data) {
          setState(() {
            farmers = data;
            filteredFarmers = data;
          });
        });
      }
    }
  }

  Future<List<Farmr>> fetchData(String status) async {
    try {
      var url = Uri.parse(apiUrl);
      var headers = {"Content-Type": "application/json"};
      var body = {
        "session_key": sessionKey,
        "status": status,
        //"farmer_id": farmerId,
      };

      var bodyJson = jsonEncode(body);
      final response = await http.post(
        url,
        headers: headers,
        body: bodyJson,
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        // final List<dynamic> data = json.decode(response.body)['data'];
        if (jsonData['error']  ){
          //if (jsonData['message'] == 'No data found.') {
          // Fluttertoast.showToast(
          //   msg: jsonData['message'],
          //   toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.CENTER,
          //   timeInSecForIosWeb: 1,
          //   backgroundColor: Colors.red,
          //   textColor: Colors.white,
          //   fontSize: 16.0,
          // );
          showCustomToast(
            context,
            jsonData['message'],
            'images/wrd_logo.png', // Provide the correct image path here
          );

          return [];
          // }// Return empty list
        }
        else {
          final List<dynamic> data = jsonData['data'];

          if (data.isNotEmpty) {
            return data.map((json) => Farmr.fromJson(json)).toList();
          } else {
            Fluttertoast.showToast(
              msg: 'No data found.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            // showCustomToast(
            //   context,
            //   jsonData['no data found'],
            //   'images/wrd_logo.png', // Provide the correct image path here
            // );
            return []; // Return empty list
          }
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

  void searchFarmers(String query) {
    setState(() {
      filteredFarmers = farmers
          .where((farmer) =>
      farmer.full_name.toLowerCase().contains(query.toLowerCase()) ||
          farmer.village.toLowerCase().contains(query.toLowerCase()) ||
          farmer.id.toLowerCase().contains(query.toLowerCase()) ||
          farmer.application_type
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          farmer.nature_of_application
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          farmer.user_id.toLowerCase().contains(query.toLowerCase()) ||
          farmer.created_date
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          farmer.reason.toLowerCase().contains(query.toLowerCase()) ||
          farmer.block.toLowerCase().contains(query.toLowerCase()) ||
          farmer.district.toLowerCase().contains(query.toLowerCase()) ||
          farmer.email.toLowerCase().contains(query.toLowerCase()) ||
          farmer.mobile.toLowerCase().contains(query.toLowerCase()) ||
          farmer.district.toLowerCase().contains(query.toLowerCase()) ||
          farmer.outlet.toLowerCase().contains(query.toLowerCase()) ||
          farmer.aadhar.toLowerCase().contains(query.toLowerCase()) ||
          farmer.acerage_of_land
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          farmer.aadhar.toLowerCase().contains(query.toLowerCase()) ||
          farmer.patwari_name.toLowerCase().contains(query.toLowerCase()) ||
          farmer.water_channel.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
  @override
  void initState() {
    super.initState();
    _autoLogin();
    fetchData('approved').then((data) {
      setState(() {
        farmers = data;
        filteredFarmers = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homee()),
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
              Image.asset(
                'images/i2.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Column(
                children: [
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildStatusButton('Pending', 'pending', 'Pending '),
                      buildStatusButton('Approved', 'approved', 'Approved '),
                      buildStatusButton('Rejected', 'rejected', 'Rejected'),
                    ],
                  ),
                  Padding(

                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        searchFarmers(value);
                      },
                      decoration: InputDecoration(

                        border: OutlineInputBorder(),
                        hintText: 'Manage New Request',
                        hintStyle: TextStyle(color: Colors.white),
                        // border: OutlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white), // Set the border color here
                        ),
                      ),
                    ),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   children: [
                  //     buildStatusButton('Pending', 'pending', 'Pending '),
                  //     buildStatusButton('Approved', 'approved', 'Approved '),
                  //     buildStatusButton('Rejected', 'rejected', 'Rejected'),
                  //   ],
                  // ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: filteredFarmers.map((farmer) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
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
                                            text: 'Request Id: ${farmer.id}    Request Date: ${farmer.created_date}\n\n',
                                            style: TextStyle(color: Colors.black),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: 'ApplicationType: ',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: '${farmer.application_type}\n',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: 'Nature of Application: ',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text:'${farmer.nature_of_application}\n\n',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: 'Outlet No: ${farmer.outlet}  Farmer Name: ${farmer.full_name}\n\n',
                                                // style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: 'Village Name: ${farmer.village}',
                                                // style: TextStyle(fontWeight: FontWeight.bold),
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
                                            MaterialPageRoute(builder: (context) => managedetailspage(farmer:farmer)),
                                          );
                                        },
                                        style:
                                        getStatusButtonStyle(farmer.status),
                                        child: Text('VIEW STATUS'),
                                      ),
                                    ),
                                    SizedBox(height: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatusButton(
      String buttonText, String status, String additionalData) {
    return Column(
      children:[
        SizedBox(
          width: 130,
          height: 10,
          child: ElevatedButton(
            onPressed: () {
              // Handle button tap
            },
            style: getStatusButtonStyle(status),
            child: Text(''),
          ),
        ),
        Text(additionalData),
      ],
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
        buttonColor = Colors.grey;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Set border radius to zero
      ),
      minimumSize: Size(140, 1),
    );
  }
}
