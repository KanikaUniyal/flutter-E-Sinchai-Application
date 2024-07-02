import 'dart:convert';
import 'package:app/api_urls.dart';
import 'package:app/home.dart';
import 'package:app/xen/listofofficaldetail.dart';
import 'package:app/xen/mainxen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(official());
}

class Farmzz {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String mobile;
  final String user_type;
  final String dob;
  final String gender;
  final String fatherName;
  final String address;
  final String district;
  final String tehsil;
  final String block;
  final String village;
  final String createdDate;

  Farmzz({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
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

  factory Farmzz.fromJson(Map<String, dynamic> json) {
    return Farmzz(
      id: json['id'] ?? "",
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

class official extends StatefulWidget {
  @override
  _officialState createState() => _officialState();
}

class _officialState extends State<official> {
  late String sessionKey;
  late String selectedUserType = 'all'; // Default selected value
  List<String> userTypes = ['all'];
  String userName = ''; // Variable to hold the user's name
  String userType = '';
  List<Farmzz> farmers = [];
  List<Farmzz> filteredFarmers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getSessionKey();
    _getUserData();
    _fetchUserTypes();
    fetchData(selectedUserType);
  }

  Future<void> _getSessionKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sessionKey = prefs.getString('userData_sessionKey') ?? "";
  }

  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userData_userName') ?? "";
    userType = prefs.getString('userData_userType') ?? "";
    setState(() {});
  }

  Future<void> _fetchUserTypes() async {
    final response = await http.get(
        Uri.parse(ApiUrls.usertype),
     // Uri.parse("http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/usertype"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      List<String> types = ['all']; // Initialize with 'all'
      if (data.isNotEmpty) {
        types.addAll(data.map((json) => json['type']).where((type) => type != 'Farmer').cast<String>());
        setState(() {
          userTypes = types;
        });
      }
    } else {
      throw Exception('Failed to load user types');
    }
  }

  Future<void> fetchData(String userType) async {
    final response = await http.post(
      Uri.parse(ApiUrls.userlist),
      //Uri.parse("http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/user/list"),
      body: {
        "session_key": sessionKey,
       // "user_type": userType == 'all' ? null : userType,
        "user_type": userType, // Include selected user type in the request body
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];

      if (data.isNotEmpty) {
        setState(() {
          farmers = data.map((json) => Farmzz.fromJson(json)).toList();
          filteredFarmers = farmers;
        });
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
      print('Sending logout request...');
      final response = await http.post(
        Uri.parse(ApiUrls.logout),
        body: {
          'session_key': sessionKey,
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
      if (query.isEmpty) {
        filteredFarmers = farmers;
      } else {
        filteredFarmers = farmers.where((farmer) =>
        farmer.fullName.toLowerCase().contains(query.toLowerCase()) ||
            farmer.user_type.toLowerCase().contains(query.toLowerCase())).toList();
      }
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
                // child: Padding(
                //   padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedUserType,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedUserType = newValue!;
                          });
                          fetchData(selectedUserType);
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.18),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          //border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.white), // Set text color to white
                        dropdownColor: Colors.black,
                        items: userTypes.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(color: Colors.white),),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: searchController,
                        onChanged: searchFarmers,
                        decoration: InputDecoration(
                          hintText: 'List of Officials'.tr,
                          //hintText: 'Enter farmer name or user type',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // Set the border color here
                          ),
                          //prefixIcon: Icon(Icons.search),
                         // border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      FarmerList(farmers: filteredFarmers),
                    ],
                  ),
                ),
             // ),
            ],
          ),
        ),
      ),
    );
  }
}



// class FarmerList extends StatelessWidget {
//   final List<Farmzz> farmers;
//
//   FarmerList({required this.farmers});
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Container(
//       margin: EdgeInsets.all(0.0),
//     decoration: BoxDecoration(
//     color: Colors.white.withOpacity(0.19),
//     borderRadius: BorderRadius.circular(10.0),
//     ),
//        // width: screenWidth +20.0,
//       child:Column(
//       children: farmers.map((farmer) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ListTile(
//               title: Text(
//                 'Name: ${farmer.fullName}\nUser Type: ${farmer.user_type}',
//               ),
//             ),
//             Container(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => OfficialDetailsPage(farmer: farmer),
//                     ),
//                   );
//                 },
//                 child: Text('View Details'),
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(4.0), // Adjust the radius as needed
//                   ),
//                   backgroundColor: Colors.green,
//                 ),
//               ),
//             ),
//             Divider(),
//           ],
//         );
//       }).toList(),
//     ),
//     );
//   }
// }
class FarmerList extends StatelessWidget {
  final List<Farmzz> farmers;

  FarmerList({required this.farmers});

  @override
  Widget build(BuildContext context) {
    //double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.19),

      ),
      child: Column(
        children: farmers.asMap().entries.map((entry) {
          final farmer = entry.value;
          final index = entry.key;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Name: ${farmer.fullName}\nUser Type: ${farmer.user_type}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold, // Bold the text
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                  width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OfficialDetailsPage(farmer: farmer),
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
                  ),
                ),
              ),
              SizedBox(height: 4.0), // Add space between items
              if (index != farmers.length - 1) // Add divider for all except the last item
                Divider(
                  color: Colors.black12,
                  thickness: 7.0,
                  height: 1.0,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
