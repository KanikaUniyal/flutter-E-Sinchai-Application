import 'dart:convert';
import 'dart:async';
import 'package:app/api_urls.dart';
import 'package:app/farmer/mainfarmer.dart';
import 'package:app/home.dart';
import 'package:app/xen/mainxen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:app/localstring.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data {
  final String? user_name;
  final String? full_name;
  final String? father_name;
  final String? email;
  final String? dob;
  final String? aadhar;
  final String? mobile;
  final String? address;
  final String? circle_office;
  final String? sub_division_office;
  final String? hrms_code;
  final String? zilladari_section;


  final String? gender;

  Data({
    this.user_name,
    this.full_name,
    this.father_name,
    this.email,
    this.dob,
    this.aadhar,
    this.mobile,
    this.address,
    this.circle_office,
    this.sub_division_office,
    this.hrms_code,
    this.zilladari_section,

    this.gender,

  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      user_name: json['user_name']??'',
      full_name: json['full_name']??'',
      father_name: json['father_name']??'',
      email: json['email']??'',
      dob: json['dob']??'',
      aadhar: json['aadhar']??'',
      mobile: json['mobile']??'',
      address: json['address']??'',
      hrms_code: json['hrms_code']??'',
      circle_office: json['circle_office']??'',
      sub_division_office: json['sub_division_office']??'',
      zilladari_section: json['zilladari_section']??'',

      gender: json['gender']??'',
    );
  }

}



class UpdateDisplayDataScreen extends StatefulWidget  {
  @override
  _DisplayDataScreenState createState() => _DisplayDataScreenState();
}

class _DisplayDataScreenState extends State<UpdateDisplayDataScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<Data> _profileDataFuture;
  DateTime? _selectedDate;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _fatherNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _aadhaarController = TextEditingController();
  TextEditingController _mobileNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _hrmsController = TextEditingController();
  TextEditingController _circleController = TextEditingController();
  TextEditingController _subdivisionController = TextEditingController();
  TextEditingController _zilladariController = TextEditingController();

  // late String _sessionKey = '';

  String? _selectedGender;

  final List<String> _genders = ['male'.tr, 'female'.tr, 'other'.tr];
  late String userName = ''; // Initialize with empty string
  late String userType = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _profileDataFuture = fetchProfileData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userData_userName') ?? '';
      userType = prefs.getString('userData_userType') ?? '';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    )) ??
        DateTime.now();

    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
      _dobController.text =
      "${picked.day}/${picked.month}/${picked.year}";
    }
  }


  Future<Data> fetchProfileData() async {
    var url = Uri.parse(ApiUrls.profileUrl);
    // var url = Uri.parse('http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/profile');
    var headers = {"Content-Type": "application/json"};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String sessionKey = prefs.getString('userData_sessionKey') ?? '';
    userName = prefs.getString('userData_fullName') ?? '';
    userType = prefs.getString('userData_userType') ?? '';
    if (sessionKey.isEmpty) {
      print('Session key not found. Please log in first.');
      // return;
    }

    var body = {
    };
    // for (var pair in keyValuePairs) {
    //   body[pair["key"]] = pair["value"];
    // }
    var bodyJson = jsonEncode(body);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $sessionKey',
        },
        body: jsonEncode({
          'session_key': sessionKey,
        }),
        // body: bodyJson,
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        dynamic data = jsonResponse['data'];
        if (data is Map<String, dynamic>) {
          Data profileData = Data.fromJson(data);
          _usernameController.text = profileData.user_name ?? '';
          _nameController.text = profileData.full_name ?? '';
          _fatherNameController.text = profileData.father_name ?? '';
          _emailController.text = profileData.email ?? '';
          _dobController.text = profileData.dob ?? '';
          _aadhaarController.text = profileData.aadhar ?? '';
          _mobileNumberController.text = profileData.mobile ?? '';
          _addressController.text = profileData.address ?? '';
          _aadhaarController.text = profileData.aadhar ?? '';
          _subdivisionController.text = profileData.sub_division_office ?? '';
          _zilladariController.text = profileData.zilladari_section ?? '';
          _hrmsController.text = profileData.hrms_code ?? '';
          _circleController.text = profileData.circle_office ?? '';

          // _selectedGender = profileData.gender;
          return profileData;
        } else {
          throw Exception('Invalid data format: $data');
        }
      }
      else {
        throw Exception('Error response status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during profile data fetch: $error');
      throw Exception('Error occurred during profile data fetch.');
    }
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
            MaterialPageRoute(builder: (context) => Xen()),
          );
          return false;
        },
        child: Scaffold(

          appBar: XenCustomAppBar(logoutCallback: _logout, userType: userType,
            // Access ScaffoldState and open drawer
          ),
          drawer: XenCustomDrawer(userName: userName, userType: userType),
          body: Stack(

            children: [
              Image.asset(
                'images/i2.jpg', // Replace with your actual image path
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child:
                  FutureBuilder<Data>(
                    future: _profileDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        Data? profileData = snapshot.data;
                        if (profileData != null) {
                          _usernameController.text = profileData.user_name ??
                              '';
                          _nameController.text = profileData.full_name ?? '';
                          _fatherNameController.text = profileData
                              .father_name ?? '';
                          _emailController.text = profileData.email ?? '';
                          _dobController.text = profileData.dob ?? '';
                          _aadhaarController.text = profileData.aadhar ?? '';
                          _mobileNumberController.text = profileData.mobile ??
                              '';
                          _addressController.text = profileData.address ?? '';
                          _subdivisionController.text = profileData
                              .sub_division_office ?? '';
                          _zilladariController.text = profileData
                              .zilladari_section ?? '';
                          _hrmsController.text = profileData.hrms_code ?? '';
                          _circleController.text = profileData.circle_office ??
                              '';
                          return SingleChildScrollView(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  'Required'.tr, // Add the text you want above the username field
                                  style: TextStyle(color: Colors.red),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'username'.tr+ '*',
                                  style: TextStyle(color: Colors.white),
                                ),

                                SizedBox(height: 4),
                                TextFormField(
                                  controller: _usernameController,
                                  // initialValue: profileData.full_name,
                                  decoration: InputDecoration(
                                    //labelText: 'username'.tr,labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.2),
                                    prefixIcon: Icon(
                                      Icons.person, color: Colors.white,),),

                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },

                                ),
                                SizedBox(height: 8),
                                Text(
                                  'name'.tr+ '*',
                                  style: TextStyle(color: Colors.white),
                                ),

                                SizedBox(height: 4),
                                TextFormField(
                                  controller: _nameController,
                                  // initialValue: profileData.full_name,
                                  decoration: InputDecoration(
                                    //labelText: 'name'.tr,labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.2),
                                    prefixIcon: Icon(
                                      Icons.person, color: Colors.white,),),

                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },


                                ),
                                SizedBox(height: 8),
                                Text(
                                  'fathername'.tr+ '*',
                                  style: TextStyle(color: Colors.white),
                                ),

                                SizedBox(height: 4),
                                TextFormField(
                                  controller: _fatherNameController,
                                  // initialValue: profileData.father_name,
                                  decoration: InputDecoration(
                                    //labelText: 'fathername'.tr,labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.2),
                                    prefixIcon: Icon(
                                      Icons.person, color: Colors.white,),),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Select DOB'.tr+ '*',
                                      style: TextStyle(color: Colors.white),
                                    ),

                                    SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => _selectDate(context),
                                      child: AbsorbPointer(
                                        child: TextFormField(
                                          controller: _dobController,
                                          keyboardType: TextInputType.datetime,
                                          decoration: InputDecoration(
                                            // labelText: 'DOB'.tr,
                                            //labelStyle: TextStyle(color: Colors.white),
                                            filled: true,
                                            fillColor: Colors.grey.withOpacity(
                                                0.2),
                                            prefixIcon: Icon(
                                              Icons.calendar_month,
                                              color: Colors.white,),
                                          ),
                                          style: TextStyle(color: Colors.white),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return '';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Mobile No'.tr+ '*',
                                  style: TextStyle(color: Colors.white),
                                ),

                                SizedBox(height: 4),
                                TextFormField(
                                  controller: _mobileNumberController,
                                  keyboardType: TextInputType.phone,
                                  // initialValue: profileData.mobile,
                                  decoration: InputDecoration(
                                    //labelText: 'Mobile No'.tr,labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.2),
                                    prefixIcon: Icon(
                                      Icons.call, color: Colors.white,),),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Email'.tr+ '*',
                                  style: TextStyle(color: Colors.white),
                                ),

                                SizedBox(height: 4),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  // initialValue: profileData.father_name,
                                  decoration: InputDecoration(
                                    //labelText: 'Email'.tr,labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.2),
                                    prefixIcon: Icon(
                                      Icons.email, color: Colors.white,),),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                Text(
                                   'Aadhar'.tr +'*',
                                  style: TextStyle(color: Colors.white),
                                ),

                                SizedBox(height: 4),
                                TextFormField(
                                  // initialValue: profileData.aadhar,
                                  controller: _aadhaarController,
                                  decoration: InputDecoration(
                                    //labelText: 'Aadhar'.tr,
                                   // labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.2),
                                    prefixIcon: Icon(
                                      Icons.format_list_numbered_sharp,
                                      color: Colors.white,),),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'circle_office'.tr+ '*',
                                  style: TextStyle(color: Colors.white),
                                ),

                                SizedBox(height: 4),
                                TextFormField(
                                  // initialValue: profileData.aadhar,
                                  controller: _circleController,
                                  decoration: InputDecoration(
                                    //labelText: 'circle_office'.tr,labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.2),
                                    prefixIcon: Icon(
                                      Icons.format_list_numbered_sharp,
                                      color: Colors.white,),),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'sub_division_office'.tr+ '*',
                                  style: TextStyle(color: Colors.white),
                                ),

                                SizedBox(height: 4),
                                TextFormField(
                                  // initialValue: profileData.aadhar,
                                  controller: _subdivisionController,
                                  decoration: InputDecoration(
                                    //labelText: 'sub_division_office'.tr,labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.2),
                                    prefixIcon: Icon(
                                      Icons.format_list_numbered_sharp,
                                      color: Colors.white,),),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'hrms_code'.tr+ '*',
                                  style: TextStyle(color: Colors.white),
                                ),

                                SizedBox(height: 4),
                                TextFormField(
                                  // initialValue: profileData.aadhar,
                                  controller: _hrmsController,
                                  decoration: InputDecoration(
                                    //labelText: 'hrms_code'.tr,labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.2),
                                    prefixIcon: Icon(
                                      Icons.format_list_numbered_sharp,
                                      color: Colors.white,),),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'zilladari_section'.tr+ '*',
                                  style: TextStyle(color: Colors.white),
                                ),

                                SizedBox(height: 4),
                                TextFormField(
                                  // initialValue: profileData.aadhar,
                                  controller: _zilladariController,
                                  decoration: InputDecoration(
                                    //labelText: 'zilladari_section'.tr,labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.2),
                                    prefixIcon: Icon(
                                      Icons.format_list_numbered_sharp,
                                      color: Colors.white,),),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 8),
                                Text(
                                  'Address'.tr+ '*',
                                  style: TextStyle(color: Colors.white),
                                ),

                                SizedBox(height: 4),
                                TextFormField(
                                  // initialValue: profileData.address,
                                  controller: _addressController,
                                  decoration: InputDecoration(
                                    //labelText: 'Address'.tr,labelStyle: TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.2),
                                    prefixIcon: Icon(
                                      Icons.home, color: Colors.white,),),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'gender'.tr+ '*', // Your text here
                                      style: TextStyle(color: Colors.white),
                                    ),

                                    SizedBox(height: 4),
                                    DropdownButtonFormField<String>(
                                      value: _selectedGender,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGender = value;
                                        });
                                      },
                                      items:
                                      [
                                        DropdownMenuItem<String>(
                                        value: null,
                                        child:
                                        // Row(
                                        //   Children:[
                                            Text('gender'.tr+ '*',
                                            style: TextStyle(
                                                color: Colors.white)
                                        ),

                                      ),
                                        ..._genders.map((String gender) {
                                          return DropdownMenuItem<String>(
                                            value: gender,
                                            child: Text(gender),
                                          );
                                        }).toList(),
                                      ],
                                      dropdownColor: Colors.black,
                                      decoration: InputDecoration(
                                        //labelText: 'gender'.tr,labelStyle: TextStyle(color: Colors.white),
                                        filled: true,
                                        fillColor: Colors.grey.withOpacity(
                                            0.2),),
                                      style: TextStyle(color: Colors.white),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),

                                // SizedBox(height: 8),
                                // Text('gender: ${profileData.gender}'),
                                SizedBox(height: 16),
                                // ElevatedButton(
                                //   onPressed: () {
                                //     // Implement button functionality here
                                //   },
                                //   child: Text('Submit'),
                                // ),

                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    // Set the background color to blue
                                    borderRadius: BorderRadius.circular(
                                        0), // Set the border radius for rounded corners
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () async {
    if (_selectedGender == null) {
    // Display separate toast message for gender not selected
    showCustomToast(context, 'Please select a gender.'.tr, 'images/wrd_logo.png');
    }
    else if (
    _usernameController.text.isEmpty||
    _nameController.text.isEmpty ||
    _fatherNameController.text.isEmpty ||
    _emailController.text.isEmpty ||
    _dobController.text.isEmpty ||
    _aadhaarController.text.isEmpty ||
    _mobileNumberController.text.isEmpty ||
    _addressController.text.isEmpty ||
    _subdivisionController.text.isEmpty||
    _hrmsController.text.isEmpty||
    _circleController.text.isEmpty||
    _zilladariController.text.isEmpty
    //_selectedGender == null
    ) {
    // Display toast message indicating that all fields are required
    showCustomToast(context, 'Please select a valid information'.tr, 'images/wrd_logo.png');
    } else {

    if (_formKey.currentState!.validate()) {
      await updateProfile();
    }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      // Set transparent background for ElevatedButton
                                      elevation: 0, // Set elevation to 0 to remove shadow
                                    ),
                                    child: Text('Update profile'.tr.toUpperCase(),
                                      style: TextStyle(color: Colors.white),),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Center(
                              child: Text('No profile data available'));
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      //),
    );
  }

  Future<void> updateProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? sessionKey = prefs.getString('userData_sessionKey');
      if (sessionKey != null) {
        //var url = Uri.parse(ApiUrls.updateProfileUrl);
        var url = Uri.parse(
            'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/user/updateprofile');
        var headers = {"Content-Type": "application/json"};
        var body = {
          //"session_key": "ca9290928b610d9f144b49f494392c29d040a87ec36763adc7fbf79a6b98e99e",
          "session_key": sessionKey,
          "user_name": _usernameController.text,
          "full_name": _nameController.text,
          "father_name": _fatherNameController.text,
          "email": _emailController.text,
          "dob": _dobController.text,
          "aadhar": _aadhaarController.text,
          "mobile": _mobileNumberController.text,
          "address": _addressController.text,
          "hrms_code": _hrmsController.text,
          "zilladari_section": _zilladariController.text,
          "circle_office": _circleController.text,
          "sub_division_office": _subdivisionController.text,
          // "gender": _selectedGender,
          "gender": _selectedGender == 'male'.tr ? 'm' : _selectedGender ==
              'female'.tr ? 'f' : 'o',
        };

        var bodyJson = jsonEncode(body);
        print('Request Body: $bodyJson');
        final response = await http.post(
          url,
          headers: headers,
          body: bodyJson,
        );

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          // Handle success response
          if (jsonResponse['error'] == false) {
            showCustomToast(context, jsonResponse['message'], 'images/wrd_logo.png');
          } else {
            showCustomToast(context, jsonResponse['message'], 'images/wrd_logo.png');
          }

         // print('Success Response: $jsonResponse');
        } else {
          print('Error Response: ${response
              .statusCode}, ${response.body}');
          throw Exception(
              'Error response status code: ${response
                  .statusCode}');
        }
      }
      else {
        throw Exception('Session key not found in SharedPreferences.');
      }
    } catch (error) {
      print('Error during update profile: $error');
      // Handle error
      if (error is http.Response) {
        // Print the response body for more details
        print('Response Body: ${error.body}');
      }
    }
  }
  // void showCustomToast(
  //     BuildContext context,
  //     String message,
  //     String imagePath, {
  //       int duration = 2,
  //       ToastGravity gravity = ToastGravity.BOTTOM,
  //       Toast toastLength = Toast.LENGTH_SHORT,
  //     }) {
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       backgroundColor: Colors.black,
  //       duration: Duration(seconds: duration),
  //       content: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Image.asset(
  //             imagePath,
  //             height: 20,
  //             width: 18,
  //           ),
  //           SizedBox(width: 2),
  //           Text(
  //             message,
  //             style: TextStyle(color: Colors.white,fontSize: 12),
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
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

}
// },
// }
void main() {
  runApp(MaterialApp(
    home: UpdateDisplayDataScreen(),
  ));
}