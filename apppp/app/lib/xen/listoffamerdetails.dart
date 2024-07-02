import 'dart:async';
import 'dart:convert';
import 'package:app/home.dart';
import 'package:app/xen/totalapplication.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/xen/mainxen.dart';
import 'package:app/xen/totalapplicationdetails.dart';
import '../api_urls.dart';
import 'listoffarmer.dart';


class Application {
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

  Application({
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

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
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
      acreageOfLand: json['acreage_of_land'] ?? "",
      mustilNo: json['mustil_no'] ?? "",
      killaNo: json['killa_no'] ?? "",
      reason: json['reason'] ?? "",
      createdDate: json['created_date'] ?? "",
      status: json['status'] ?? "",
      statusRemarks: json['status_remarks'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_type': applicationType,
      'nature_of_application': natureOfApplication,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'mobile': mobile,
      'father_name': fatherName,
      'address': address,
      'aadhar': aadhar,
      'district': district,
      'tehsil': tehsil,
      'block': block,
      'village': village,
      'water_channel': waterChannel,
      'outlet': outlet,
      'patwari_name': patwariName,
      'acreage_of_land': acreageOfLand,
      'mustil_no': mustilNo,
      'killa_no': killaNo,
      'reason': reason,
      'created_date': createdDate,
      'status': status,
      'status_remarks': statusRemarks,
    };
  }
// }
// class Farmlist {
//   final String id;
//   final String applicationType;
//   final String natureOfApplication;
//   final String userId;
//   final String fullName;
//   final String email;
//   final String mobile;
//   final String fatherName;
//   final String address;
//   final String aadhar;
//   final String district;
//   final String tehsil;
//   final String block;
//   final String village;
//   final String waterChannel;
//   final String outlet;
//   final String patwariName;
//   final String acreageOfLand;
//   final String mustilNo;
//   final String killaNo;
//   final String reason;
//   final String createdDate;
//   final String status;
//   final String statusRemarks;
//
//   Farmlist({
//     required this.id,
//     required this.applicationType,
//     required this.natureOfApplication,
//     required this.userId,
//     required this.fullName,
//     required this.email,
//     required this.mobile,
//     required this.fatherName,
//     required this.address,
//     required this.aadhar,
//     required this.district,
//     required this.tehsil,
//     required this.block,
//     required this.village,
//     required this.waterChannel,
//     required this.outlet,
//     required this.patwariName,
//     required this.acreageOfLand,
//     required this.mustilNo,
//     required this.killaNo,
//     required this.reason,
//     required this.createdDate,
//     required this.status,
//     required this.statusRemarks,
//   });
//
//   factory Farmlist.fromJson(Map<String, dynamic> json) {
//     return Farmlist(
//       id: json['id'] ?? "",
//       applicationType: json['application_type'] ?? "",
//       natureOfApplication: json['nature_of_application'] ?? "",
//       userId: json['user_id'] ?? "",
//       fullName: json['full_name'] ?? "",
//       email: json['email'] ?? "",
//       mobile: json['mobile'] ?? "",
//       fatherName: json['father_name'] ?? "",
//       address: json['address'] ?? "",
//       aadhar: json['aadhar'] ?? "",
//       district: json['district'] ?? "",
//       tehsil: json['tehsil'] ?? "",
//       block: json['block'] ?? "",
//       village: json['village'] ?? "",
//       waterChannel: json['water_channel'] ?? "",
//       outlet: json['outlet'] ?? "",
//       patwariName: json['patwari_name'] ?? "",
//       acreageOfLand: json['acreage_of_land'] ?? "",
//       mustilNo: json['mustil_no'] ?? "",
//       killaNo: json['killa_no'] ?? "",
//       reason: json['reason'] ?? "",
//       createdDate: json['created_date'] ?? "",
//       status: json['status'] ?? "",
//       statusRemarks: json['status_remarks'] ?? "",
//     );
//   }
 }
class FarmerDetailsPage extends StatefulWidget {
  final Farmer farmer;

  FarmerDetailsPage({required this.farmer});

  @override
  _OfficialDetailsPageState createState() => _OfficialDetailsPageState();
}

class _OfficialDetailsPageState extends State<FarmerDetailsPage> {
  //late Future<List<Application>> _fetchData;
  late Future<List<Application>> _fetchData = Future.value([]);

  final String _apiUrl = ApiUrls.applicationList;
  late String _sessionKey;
  String userName = '';
  String userType = '';
  String mobile = '';
  late Timer _timer;

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
      String? storedMobile = prefs.getString('userData_mobile');
      if (storedSessionKey != null && storedUsername != null) {
        setState(() {
          _sessionKey = storedSessionKey;
          userName = storedUsername;
          userType = storedUserType!;
          mobile = storedMobile ?? '';
        });

        // Fetch applications for the current farmer
        List<Application> applications = await fetchApplications(widget.farmer.userId);
        setState(() {
          _fetchData = Future.value(applications);
        });
      }
    } else {
      // Handle scenario when user is not logged in
      // For example, you can navigate to a login screen or show a message
    }
  }

  Future<List<Application>> fetchApplications(String userId) async {
    // Function to fetch applications for a specific user
    // You can use this function to initialize _fetchData
    if (_sessionKey.isEmpty) {
      throw Exception("Session key is empty");
    }

    var url = Uri.parse(_apiUrl);
    var headers = {"Content-Type": "application/json"};
    var body = {
      "session_key": _sessionKey,
      "status": "all",
      "user_type": userType,
      "mobile": mobile,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      if (data.isNotEmpty) {
        List<Application> applications = data
            .map((e) => Application.fromJson(e))
            .where((app) => app.userId == userId)
            .toList();
        return applications;
      } else {
        throw Exception('Data is empty');
      }
    } else {
      throw Exception('Failed to load data');
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
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
      final response = await http.post(
        Uri.parse(ApiUrls.logout),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );

          return false;
        },
        child: Scaffold(
          appBar: XenCustomAppBar(logoutCallback: _logout, userType: userType),
          drawer: XenCustomDrawer(
            userName: userName,
            userType: userType,
          ),
          body: // Wrap the entire body with SingleChildScrollView
   Container(
    decoration: BoxDecoration(
    image: DecorationImage(
    image: AssetImage('images/i2.jpg'), // Background image
    fit: BoxFit.cover,
    ),
    ),

    child: Padding(

    padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //SizedBox(height: 20),
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
                 Text('Name'.tr, style: TextStyle(color: Colors.white),),
                 // buildSectionTitle('Full Name'),
                  buildTextField( widget.farmer.fullName),
                  Text('Father Name'.tr, style: TextStyle(color: Colors.white),),
                 // buildSectionTitle('Father Name'),
                  buildTextField( widget.farmer.fatherName),
                 // buildSectionTitle('Mobile',),
                  Text('Mobile No'.tr, style: TextStyle(color: Colors.white),),
                  buildTextField( widget.farmer.mobile),
                 // buildSectionTitle('Email',),
                  Text('Email'.tr, style: TextStyle(color: Colors.white),),
                  buildTextField( widget.farmer.email),
                  //buildSectionTitle('User Type',),
                  Text('User Type'.tr, style: TextStyle(color: Colors.white),),
                  buildTextField( widget.farmer.user_type),
                ],
              ),
            ),
          ),
                //SizedBox(height: 20),
                Container(
                  height: 50,
                  width: double.infinity,
                  child:
                  ElevatedButton(
                    onPressed: () {



                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.purple),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as needed
                          side: BorderSide(color: Colors.purple), // Border color
                        ),
                      ),
                    ),

                    // style: getStatusButtonStyle(application['status']),
                    child: Text('Application Status'.tr.toUpperCase(),style: TextStyle(
                      color: Colors.white,
                    ),),
                  ),
                ),

                Expanded(
                  child: FutureBuilder<List<Application>>(
                    future: _fetchData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting || _fetchData == null) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        final applications = snapshot.data ?? [];
                        return ListView.builder(
                          itemCount: applications.length,
                          itemBuilder: (context, index) {
                            final application = applications[index];
                            return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child:Card(
                            color: Colors.white,
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            ),
                              //margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // child: ListTile(
                              //   title: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                            Text('Request Id: ${application.id}   Request Date: ${application.createdDate}'),
                            SizedBox(height: 8.0),

                            Text(
                                      'Application Type: ${application.applicationType}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                            SizedBox(height: 8.0),
                            Text('Nature of Application: ${application.natureOfApplication}'),
                            SizedBox(height: 8.0),
                            Text('Outlet No: ${application.outlet}'),
                            SizedBox(height: 8.0),
                            Text('Village Name: ${application.village}'),
                           // SizedBox(height: 8.0),


                                //   ],
                                // ),
                                //subtitle: Text(application.natureOfApplication),
                                // onTap: () {
                                //   // Navigate to application details page
                                // },
                            SizedBox(height: 8.0), // Add space before the button

                                Container(
                                    height: 50,
                                    width: double.infinity,
                                    child:
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => xendetailspage(farmer: Farmerrl.fromJson(application)),
                                    //   ),
                                    // );


                                  },


                                  style: getStatusButtonStyle(application.status),

                                 // style: getStatusButtonStyle(application['status']),
                                  child: Text('View status'.tr.toUpperCase(),style: TextStyle(
                                    color: Colors.white,
                                  ),),
                                ),
                              ),
                              SizedBox(height: 0.0),
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
                ),


           // ),

              ],
            ),
          ),
        ),
      ),
      ),
      //),
    );
  }
  ButtonStyle getStatusButtonStyle(String status) {
    Color buttonColor;

    switch (status.toLowerCase()) {
      case 'pending':
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

  Widget buildTextField( String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.19),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: TextField(
          decoration: InputDecoration(
           // labelText: label,
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

