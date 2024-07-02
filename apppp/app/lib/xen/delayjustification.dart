import 'dart:convert';


import 'package:app/api_urls.dart';
import 'package:app/home.dart';
import 'package:app/xen/mainxen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'delayjustificationdetail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: Mz(),
  ));
}

class Farmerz {
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

  Farmerz({
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

  factory Farmerz.fromJson(Map<String, dynamic> json) {
    return Farmerz(
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

class Mz extends StatefulWidget {
  @override
  _MyApppState createState() => _MyApppState();
}
//
// class _MyApppState extends State<Mz> {
//   // final String apiUrl =
//   //     "http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/application/list";
//   final String apiUrl = ApiUrls.applicationList;
//  // final String sessionKey =
//    //   "94ddf7655fe53c6bc08ac35dbba938adc78ce98a1d677c4be8f5719c534203da";
//   String? sessionKey;
//   late List<Farmerz> farmers;
//   late List<Farmerz> filteredFarmers = [];
//   TextEditingController searchController = TextEditingController();
//   String userName = ''; // Variable to hold the user's name
//   String userType = '';
//   late String farmerId='';
//   Future<void> fetchSessionKey() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       sessionKey = prefs.getString('userData_sessionKey')??'';
//      userName = prefs.getString('userData_fullName')??'';
//      userType= prefs.getString('userData_userType')??'';
//     });
//   }
//   Future<List<Farmerz>> fetchData(String status) async {
//     try {
//       var url = Uri.parse(apiUrl);
//       var headers = {"Content-Type": "application/json"};
//       var body = {
//         "session_key": sessionKey,
//         "status": status,
//         "farmer_id": farmerId,
//       };
//
//       var bodyJson = jsonEncode(body);
//       final response = await http.post(
//         url,
//         headers: headers,
//         body: bodyJson,
//       );
//       print('Response status code: ${response.statusCode}');
//       print('Response body: ${response.body}');
//       if (response.statusCode == 200) {
//         final dynamic jsonData = json.decode(response.body);
//
//         // Check if error is true in the response
//         if (jsonData['error'] && jsonData['message'] == 'Session Expired, Please login again.') {
//           // Do not show toast for session expiration message
//           return [];
//         }
//         else
//         if (jsonData['error']  ){
//           //if (jsonData['message'] == 'No data found.') {
//           // Fluttertoast.showToast(
//           //   msg: jsonData['message'],
//           //   toastLength: Toast.LENGTH_SHORT,
//           //   gravity: ToastGravity.CENTER,
//           //   timeInSecForIosWeb: 1,
//           //   backgroundColor: Colors.red,
//           //   textColor: Colors.white,
//           //   fontSize: 16.0,
//           // );
//           showCustomToast(
//             context,
//             jsonData['message'],
//             'images/wrd_logo.png', // Provide the correct image path here
//           );
//
//           return [];
//           // }// Return empty list
//         }
//         else {
//           final List<dynamic> data = jsonData['data'];
//
//           if (data.isNotEmpty) {
//             return data.map((json) => Farmerz.fromJson(json)).toList();
//           } else {
//             Fluttertoast.showToast(
//               msg: 'No data found.',
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.CENTER,
//               timeInSecForIosWeb: 1,
//               backgroundColor: Colors.red,
//               textColor: Colors.white,
//               fontSize: 16.0,
//             );
//             return []; // Return empty list
//           }
//         }
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (error) {
//       print('Error during API call: $error');
//       throw error;
//     }
//   }
//   // Future<List<Farmerz>> fetchData(String status, {String? fullNameFilter}) async {
//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse(apiUrl),
//   //       body: {
//   //         "session_key": sessionKey ?? '',
//   //         "status": status,
//   //         "full_name_filter": fullNameFilter ?? "",
//   //         "farmer_id": farmerId,
//   //       },
//   //     );
//   //
//   //     print('Response status code: ${response.statusCode}');
//   //     print('Response body: ${response.body}');
//   //     if (response.statusCode == 200) {
//   //       final dynamic jsonData = json.decode(response.body);
//   //
//   //       // Show toast message if present
//   //       if (jsonData['message'] != null && jsonData['message'].isNotEmpty) {
//   //         showCustomToast(context, jsonData['message'], 'images/wrd_logo.png');
//   //       }
//   //
//   //       if (jsonData['error']) {
//   //         if (jsonData['message'] == 'Session Expired, Please login again.') {
//   //           // Handle session expiration
//   //           // Do not show toast for session expiration message
//   //           return [];
//   //         } else {
//   //           // Other errors
//   //           return [];
//   //         }
//   //       } else {
//   //         final List<dynamic> data = jsonData['data'];
//   //         if (data.isNotEmpty) {
//   //           if (fullNameFilter != null && fullNameFilter.isNotEmpty) {
//   //             return data
//   //                 .where((json) => Farmerz.fromJson(json).full_name == fullNameFilter)
//   //                 .map((json) => Farmerz.fromJson(json))
//   //                 .toList();
//   //           } else {
//   //             return data.map((json) => Farmerz.fromJson(json)).toList();
//   //           }
//   //         } else {
//   //           return [];
//   //         }
//   //       }
//   //     } else {
//   //       throw Exception('Failed to load data');
//   //     }
//   //   } catch (error) {
//   //     throw error;
//   //   }
//   // }
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     fetchSessionKey();
//
//     fetchAndSetData('delayjustification');
//
//   }
//   void fetchAndSetData(String status) {
//     fetchData(status).then((data) {
//       setState(() {
//         farmers = data;
//         filteredFarmers = data;
//       });
//     });
//   }
//   // void fetchAndSetData(String status, {String? fullNameFilter}) {
//   //   fetchData(status, fullNameFilter: fullNameFilter).then((data) {
//   //     setState(() {
//   //       farmers = data;
//   //       filteredFarmers = data;
//   //     });
//   //   });
//   // }
//
//   void searchFarmers(String query) {
//     setState(() {
//       filteredFarmers = farmers
//           .where((farmer) =>
//       farmer.full_name.toLowerCase().contains(query.toLowerCase()) ||
//           farmer.village.toLowerCase().contains(query.toLowerCase()) ||
//           farmer.id.toLowerCase().contains(query.toLowerCase()) ||
//           farmer.application_type.toLowerCase().contains(query.toLowerCase()) ||
//           farmer.nature_of_application.toLowerCase().contains(query.toLowerCase()) ||
//
//           farmer.created_date.toLowerCase().contains(query.toLowerCase()) ||
//           farmer.outlet.toLowerCase().contains(query.toLowerCase())
//       )
//           .toList();
//     });
//   }
//   void showCustomToast(
//       BuildContext context,
//       String message,
//       String imagePath, {
//         int duration = 2,
//       }) {
//     OverlayEntry? overlayEntry;
//
//     // Create a builder function for the overlay entry
//     OverlayEntry createOverlayEntry() {
//       return OverlayEntry(
//         builder: (BuildContext context) {
//           // Calculate the maximum width for the toast message
//           double maxWidth = MediaQuery.of(context).size.width * 0.8; // Adjust the fraction as needed
//           double messageWidth = (message.length * 8.0) + 48.0; // Calculate initial width based on message length
//
//           // Ensure that the calculated width does not exceed the maximum width
//           double finalWidth = messageWidth > maxWidth ? maxWidth : messageWidth;
//
//           return Positioned(
//             bottom: 16.0, // Adjust this value to change the distance from the bottom
//             left: (MediaQuery.of(context).size.width - finalWidth) / 2, // Center horizontally
//             child: Material(
//               color: Colors.transparent,
//               child: Container(
//                 width: finalWidth, // Set the width of the container
//                 padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
//                 decoration: BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.circular(0.0),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Image.asset(
//                       imagePath,
//                       height: 20,
//                       width: 20,
//                       //color: Colors.white,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       message,
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     }
//
//     // Show the custom toast overlay
//     overlayEntry = createOverlayEntry();
//     Overlay.of(context)?.insert(overlayEntry!);
//
//     // Remove the overlay after a specified duration
//     Future.delayed(Duration(seconds: duration), () {
//       overlayEntry?.remove();
//     });
//   }
//   Future<void> _logout(BuildContext context) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? sessionKey = prefs.getString('userData_sessionKey');
//     if (sessionKey == null || sessionKey.isEmpty) {
//       print('Session key not found. Please log in first.');
//       // Handle the case where session key is not available
//       return;
//     }
//     prefs.clear();
//     try {
//       print('Sending logout request...');
//       final response = await http.post(Uri.parse(ApiUrls.logout),
//         // final response = await http.post(
//         //   Uri.parse('http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/logout'),
//         body: {
//           'session_key': sessionKey,
//           //'session_key': 'cc125f6b52bf1223e2b2552742a571580eee23e5391b08293dd0870d7ba422f1',
//         },
//       );
//
//       print('Logout response status code: ${response.statusCode}');
//       print('${response.body}');
//
//       if (response.statusCode == 200) {
//
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.remove('loggedInUser');
//         final jsonResponse = json.decode(response.body);
//         String message = jsonResponse['message'] ?? 'Logout successful';
//         showCustomToast(context, message, 'images/wrd_logo.png');
//
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => MyHomePage(title: 'Prsc')),
//         );
//       } else {
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to logout. Please try again.'),
//           ),
//         );
//       }
//     } catch (e) {
//       // If an error occurs during logout, display an error message
//       print('Error during logout: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to logout. Please try again.'),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: WillPopScope(
//         onWillPop: () async {
//           // Navigate to mainxenpage when back button is pressed
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => Xen()),
//           );
//           return false;
//         },
//         child: Scaffold(
//           appBar: XenCustomAppBar(logoutCallback: _logout, userType: userType,
//           ),
//           drawer: XenCustomDrawer(
//             userName: userName,
//             userType: userType,
//           ),
//           // home: Scaffold(
//           //   appBar: AppBar(
//           //     title: Text('Farmers List'),
//           //   ),
//           body:Stack(
//             children: [
//             // Background image
//             Image.asset(
//             'images/i2.jpg', // Replace with your image path
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//           ),
//           Column(
//             children: [
//               SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   buildStatusButton('Pending', 'pending', 'Pending '),
//                   buildStatusButton('Approved', 'approved', 'Completed '),
//                   // buildStatusButton('Rejected', 'rejected', 'Rejected '),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   controller: searchController,
//                   onChanged: (value) {
//                     searchFarmers(value);
//                   },
//                   decoration: InputDecoration(
//                     hintText: 'Delay Justifications',
//                     hintStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white), // Set the border color here
//                     ),
//                   ),
//                 ),
//               ),
//               // Row(
//               //   mainAxisAlignment: MainAxisAlignment.spaceAround,
//               //   children: [
//               //     buildStatusButton('Pending', 'pending', 'Pending '),
//               //     buildStatusButton('Approved', 'approved', 'Completed '),
//               //     // buildStatusButton('Rejected', 'rejected', 'Rejected '),
//               //   ],
//               // ),
//
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: filteredFarmers.map((farmer) {
//                       return Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Card(
//                           color: Colors.white,
//                           elevation: 3.0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 ListTile(
//                                   title: Center(
//                                     child: Text(
//                                       'Request Id: ${farmer.id}    Request Date: ${farmer.created_date}\nApplicationType: ${farmer.application_type}\nNature of Application: ${farmer.nature_of_application}\nOutlet No: ${farmer.outlet}     Farmer Name: ${farmer.full_name}\nVillage Name: ${farmer.village}',
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 8.0),
//                                 Center(
//                                   child: ElevatedButton(
//                                     onPressed: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               delaydetailspage(farmer: farmer),
//                                         ),
//                                       );
//                                     },
//                                     style: getStatusButtonStyle(farmer.status),
//                                     child: Text('VIEW STATUS'),
//                                   ),
//                                 ),
//                                 SizedBox(height: 8.0),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           ],
//         ),
//       ),
//       ),
//     );
//
//   }
//
//   Widget buildStatusButton(
//       String buttonText, String status, String additionalData) {
//     return Column(
//       children:[
//         SizedBox(
//           width: 130,
//           height: 10,
//           child: ElevatedButton(
//             onPressed: () {
//               fetchAndSetData(status);
//             },
//             style: getStatusButtonStyle(status),
//             child: Text(''),
//           ),
//         ),
//         Text(additionalData),
//       ],
//     );
//   }
//
//   ButtonStyle getStatusButtonStyle(String status) {
//     Color buttonColor;
//
//     switch (status.toLowerCase()) {
//       case 'pending':
//       case 'in process':
//         buttonColor = Colors.orange;
//         break;
//       case 'approved':
//         buttonColor = Colors.green;
//         break;
//       case 'rejected':
//         buttonColor = Colors.red;
//         break;
//       default:
//         buttonColor = Colors.grey; // Default color
//     }
//
//     return ElevatedButton.styleFrom(
//       primary: buttonColor,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.zero, // Set border radius to zero
//       ),
//       minimumSize: Size(200, 1),
//     );
//   }
// }

class _MyApppState extends State<Mz> {
  bool _isPageLoaded = false;
  final String apiUrl = ApiUrls.applicationList;
  // final String apiUrl =
  //     "http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/application/list";
  // final String sessionKey =
  //   "94ddf7655fe53c6bc08ac35dbba938adc78ce98a1d677c4be8f5719c534203da";
  late String sessionKey;
  late List<Farmerz> farmers;
  late List<Farmerz> filteredFarmers = [];
  TextEditingController searchController = TextEditingController();
  String userName = ''; // Variable to hold the user's name
  String userType = '';
  late String farmerId='';

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
          this.userName = storedUsername!;
          this.userType = storedUserType!;
        });
        fetchData('rejected').then((data) {
          setState(() {
            farmers = data;
            filteredFarmers = data;
          });
          String? message = data.isNotEmpty ? 'Data loaded successfully' : 'Data is empty';
          if (message != null) {
            //showCustomToast(message, 'images/wrd_logo.png');
          }
        });
      }
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


  Future<List<Farmerz>> fetchData(String status) async {
    try {
      var url = Uri.parse(apiUrl);
      var headers = {"Content-Type": "application/json"};
      var body = {
        "session_key": sessionKey,
        "status": status,
        "farmer_id": farmerId,
      };

      var bodyJson = jsonEncode(body);
      final response = await http.post(
        url,
        headers: headers,
        body: bodyJson,
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // Check if error is true in the response
        if (jsonData['error'] && jsonData['message'] == 'Session Expired, Please login again.') {
          // Do not show toast for session expiration message
          return [];
        }
        else
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
            return data.map((json) => Farmerz.fromJson(json)).toList();
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

  @override
  void initState() {
    super.initState();

    _autoLogin();
    fetchAndSetData('delayjustification');
    // Future.delayed(Duration.zero, () {
    //   showCustomToast('Welcome to the rejected applications page!', 'images/wrd_logo.png');
    // });

  }

  void fetchAndSetData(String status) {
    fetchData(status).then((data) {
      setState(() {
        farmers = data;
        filteredFarmers = data;
      });
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
        final jsonResponse = json.decode(response.body);
        String message = jsonResponse['message'] ?? 'Logout successful';
        showCustomToast(context, message, 'images/wrd_logo.png');


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
  void searchFarmers(String query) {
    setState(() {
      filteredFarmers = farmers
          .where((farmer) =>
      farmer.full_name.toLowerCase().contains(query.toLowerCase()) ||
          farmer.village.toLowerCase().contains(query.toLowerCase()) ||
          farmer.id.toLowerCase().contains(query.toLowerCase()) ||
          farmer.application_type.toLowerCase().contains(query.toLowerCase()) ||
          farmer.nature_of_application.toLowerCase().contains(query.toLowerCase()) ||
          farmer.user_id.toLowerCase().contains(query.toLowerCase()) ||
          farmer.created_date.toLowerCase().contains(query.toLowerCase()) ||
          farmer.reason.toLowerCase().contains(query.toLowerCase()) ||
          farmer.block.toLowerCase().contains(query.toLowerCase()) ||
          farmer.district.toLowerCase().contains(query.toLowerCase()) ||
          farmer.email.toLowerCase().contains(query.toLowerCase()) ||
          farmer.mobile.toLowerCase().contains(query.toLowerCase()) ||
          farmer.district.toLowerCase().contains(query.toLowerCase()) ||
          farmer.outlet.toLowerCase().contains(query.toLowerCase()) ||
          farmer.aadhar.toLowerCase().contains(query.toLowerCase()) ||
          farmer.acerage_of_land.toLowerCase().contains(query.toLowerCase()) ||
          farmer.aadhar.toLowerCase().contains(query.toLowerCase()) ||
          farmer.water_channel.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
            MaterialPageRoute(builder: (context) => Xen()),
          );
          return false;
        },
        child: Scaffold(
          appBar: XenCustomAppBar(logoutCallback: _logout, userType: userType,
          ),
          drawer: XenCustomDrawer(
            userName: userName,
            userType: userType,
          ),
          // appBar: AppBar(
          // title: Text('Farmers List'),
          // ),
          // home: Scaffold(
          //   appBar: AppBar(
          //     title: Text('Farmers List'),
          //   ),
          body:Stack(
            children: [
              // Background image
              Image.asset(
                'images/i2.jpg', // Replace with your image path
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
                      buildStatusButton('Rejected', 'rejected', 'Rejected '),
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
                        hintText: 'Delay Justifications',
                        hintStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white), // Set the border color here
                        ),
                      ),
                    ),
                  ),


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
                                borderRadius: BorderRadius.circular(8.0),
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
                                          )
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
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  delaydetailspage(farmer: farmer),
                                            ),
                                          );
                                        },
                                        style: getStatusButtonStyle(farmer.status),
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
              fetchAndSetData(status);
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
        buttonColor = Colors.grey; // Default color
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