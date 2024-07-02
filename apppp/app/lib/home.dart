import 'package:app/api_urls.dart';
import 'package:app/farmer/mainfarmer.dart';
import 'package:app/xen/mainxen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:app/ForgetPassword.dart';
import 'package:app/SignUp.dart';
import 'package:app/farmer/mainfarmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'localstring.dart';
import 'LocaleString.dart';
// import 'package:app/localstring.dart';

class LanguagePreferences {
  static bool isEnglish = true;

  static toggleLanguage() {
    isEnglish = !isEnglish;
  }
}
class LanguageDropdownController extends GetxController {
  RxString selectedLanguage = 'Change language'.obs;

  void changeLanguage(String language) {
    selectedLanguage.value = language;
  }
}

// class LanguageDropdownController extends GetxController {
//   // RxString selectedLanguage = 'Punjabi'.obs; // Default language is English
//   RxString selectedLanguage = 'English'.obs;
//
//   void changeLanguage(String language) {
//     selectedLanguage.value = language;
//   }
// }
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LanguageController _languageController = Get.put(LanguageController());
  final List<Map<String, String>> locale = [
    {'name': 'English', 'locale': 'en_US'},
    {'name': 'Punjabi', 'locale': 'pa_IN'},
  ];
  late String _selectedLocale;
  bool passwordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late double _screenWidth;
  late double _screenHeight;
  late List<Data> _roleList;
  String? _selectedrole;

  @override
  void initState() {
    super.initState();
    _selectedLocale = 'en_US';
    _roleList = [];
    _fetchroles();
    passwordVisible = true;
    _autoLogin();
    _checkLoginState();
  }
  // void _changeLanguage(String locale) {

  // void _changeLanguage(String locale) {
  //   setState(() {
  //   _languageController.changeLanguage(locale);
  //   Get.updateLocale(Locale(locale.split('')[0], locale.split('')[1]));
  //   SharedPreferences.getInstance().then((prefs) {
  //     prefs.setString('language_code', locale);
  //   });
  //   });
  //   // setState(() {});
  // }
  void _checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? userType = prefs.getString('userData_userType');

    if (isLoggedIn) {
      if (userType == 'xen') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Xen(),
          ),
        );
      } else if (userType == 'farmer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Farmer(username: ''),
          ),
        );
      }
      else if (userType == 'sdo') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Xen(),
          ),
        );
      }
      else if (userType == 'je') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>Xen(),
          ),
        );
      }else {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(userData: {},),
          ),
        );
      }
    }
  }
  void _changeLanguage(String locale) {
    _languageController.changeLanguage(locale);
    List<String> codes = locale.split('_'); // Split into language and country code
    Get.updateLocale(Locale(codes[0], codes[1]));
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('language_code', locale);
    });
    setState(() {}); // Trigger UI rebuild
  }



  void showCustomToast(
      // BuildContext context,
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
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
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
                    SizedBox(width: 2),
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
  void loginUser()async{
    var url = Uri.parse(ApiUrls.login);
   // var url="http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/login";
    var data = {
      "login_id":_emailController.text,
      "password":_passwordController.text,
      "user_type":_selectedrole,
    };
    var bodyy=json.encode(data);
    //var urlParse=Uri.parse(url);
    http.Response response= await http.post(
        url,
        body: bodyy,
        headers: {
          "Content-Type": "application/json"
        }
    );
    print (response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      bool error = responseData['error'];
      final jsonData = json.decode(response.body);
      String message = jsonData['message'];
      showCustomToast(message, 'images/wrd_logo.png');


      if (!error && message == 'Success') {
        // showCustomToast(message, 'images/wrd_logo.png');
        // Credentials are correct
        Map<String, dynamic> userData = responseData['data'];
        _saveUserData(
          id: userData['id'],
          userId: userData['user_id'],
          fullName: userData['full_name'],
          userName: userData['user_name'],
          fatherName: userData['father_name'],
          email:userData['email'],
          userType: userData['user_type'],
          userRole: userData['user_role'],
          sessionKey: userData['session_key'],
          approvedLandRecordsFlag: userData['approved_land_records_flag'],
        );

        //if (_selectedrole != null && (_selectedrole!.toLowerCase().contains('xen') ||(_selectedrole!.toLowerCase().contains('sdo') || _selectedrole!.toLowerCase().contains('farmer'))) {
          // Get.off(SuccessScreen(userData: userData));
        if (_selectedrole != null && (_selectedrole!.toLowerCase().contains('xen') || _selectedrole!.toLowerCase().contains('sdo') || _selectedrole!.toLowerCase().contains('je') ||_selectedrole!.toLowerCase().contains('farmer'))) {

          await Future.delayed(Duration(seconds: 2));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessScreen(userData: userData),
            ),
          );
          showCustomToast(message, 'images/wrd_logo.png');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid role. Please select a valid role.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Credentials are incorrect
        // ScaffoldMessenger.of(context).showSnackBar(
        //   // SnackBar(
        //   //   content: Text(message),
        //   //   duration: Duration(seconds: 3),
        //   // ),
        // );
        // Get.snackbar(
        //   'Error',
        //   message,
        //   duration: Duration(seconds: 3),
        // );
      }
    } else {
      // Error occurred during login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred during login. Please try again later.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }


  _autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      String? userDataString = prefs.getString('userData');
      if (userDataString != null) {
        Map<String, dynamic> userData = json.decode(userDataString);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(userData: userData),
          ),
        );
      }
    }
  }
  void _saveUserData({
    required String id,
    required String userId,
    required String fullName,
    required String userName,
    required String email,
    required String fatherName,
    required String userType,
    required String userRole,
    required String sessionKey,
    required int approvedLandRecordsFlag,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    prefs.setString('userData_id', id);
    prefs.setString('userData_userId', userId);
    prefs.setString('userData_fullName', fullName);
    prefs.setString('userData_userName', userName);
    prefs.setString('userData_email', email);
    prefs.setString('userData_fatherName', fatherName);
    prefs.setString('userData_userType', userType);
    prefs.setString('userData_userRole', userRole);
    prefs.setString('userData_sessionKey', sessionKey);
    prefs.setInt('userData_approvedLandRecordsFlag', approvedLandRecordsFlag);
    // prefs.setString('userData', json.encode(userData));
  }
  // _saveUserData(Map<String, dynamic> userData) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool('isLoggedIn', true);
  //   prefs.setString('userData', json.encode(userData));
  // }


  Future<void> _fetchroles() async {
    try {
      List<Data> roles = await fetchData();
      setState(() {
        _roleList = roles;
      });
    } catch (error) {
      print('Error fetching districts: $error');
      // Handle error
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final LanguageDropdownController dropdownController = Get.put(LanguageDropdownController());
    // final localeString = Get.find<LocaleString>();
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
      child:Container(
    width: _screenWidth,
    padding: EdgeInsets.symmetric(horizontal: _screenWidth * 0.07, vertical: _screenHeight * 0.07),
    child: Column(
    children: [
    Padding(
    padding: EdgeInsets.only(bottom: _screenHeight * 0.02),
    // top: 40, // Adjust the top padding as needed
    // right: 35,
    // left: 35,
    // bottom: 20, // Add padding to the bottom to prevent overflow
    // ),
    child: Column(
    children: [
    Padding(
    padding: EdgeInsets.only(bottom: _screenHeight * 0.02),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Image.asset('images/wrd_logo.png', height: _screenHeight * 0.1),
    SizedBox(width: _screenWidth * 0.02),
    Text(
    'pims'.tr,
    style: TextStyle(color: Colors.white, fontSize: _screenWidth * 0.07, fontWeight: FontWeight.bold),
    ),
    SizedBox(width: _screenWidth * 0.02),
    Image.asset('images/logo.png', height: _screenHeight * 0.1),
    ],
    ),
    ),
    Text(
    'message'.tr,
    style: TextStyle(color: Colors.white, fontSize: _screenWidth * 0.035),
    ),

    SizedBox(height: _screenHeight * 0.02),
                            Center(
                           child: Form(
                      key: _formKey,
                      child: Column(
                        children: [

                         GetBuilder<LanguageDropdownController>(
                          // init: LanguageDropdownController(),
                           builder: (controller) => Align(
                    alignment: Alignment.centerRight,
                                child:Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                DropdownButton<String>(
                                  //value: 'Change language',
                              value: controller.selectedLanguage.value,
                                  dropdownColor: Colors.black,
                              icon: Icon(Icons.arrow_drop_down),
                              onChanged: (String? newValue) {
                               // if (newValue != null) {
                               //  if (newValue != null && newValue != 'Change language') {
                               //      _changeLanguage(newValue == 'English'
                               //          ? 'en_US'
                               //          : 'pa_IN');
                               //      controller.changeLanguage(newValue);
                               //  }
                                if (newValue != null) {
                                  if (newValue == 'English' || newValue == 'ਪੰਜਾਬੀ') {
                                    _changeLanguage(newValue == 'English' ? 'en_US' : 'pa_IN');
                                    controller.changeLanguage(newValue);
                                  }
                                } else {
                                  // If newValue is null, i.e., no item is selected, set the value to 'Change language'
                                  controller.changeLanguage('Change language');
                                }
                              },

                              items: [

                                  DropdownMenuItem<String>(
                                   value: 'Change language',
                                   // value: null,
                                    child: Text('changelang'.tr,style: TextStyle(color: Colors.white),),
                                    enabled: true,
                                  ),
                                DropdownMenuItem<String>(
                                  value: 'English',
                                  child: Text('English'.tr,style: TextStyle(color: Colors.white),),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'ਪੰਜਾਬੀ',
                                  //child: Text('ਪੰਜਾਬੀ'),
                                  // child: Text(LocalString.current['Punjabi']!),
                                  child: Text('Punjabi'.tr,style: TextStyle(color: Colors.white),),
                                ),
                              ],
                              disabledHint: Text( 'changelang'.tr, style: TextStyle(color: Colors.white),),
                                  hint: Text(
                                    //controller.selectedLanguage.value.tr,
                                    'changelang'.tr, // Add your hint text here
                                    style: TextStyle(color: Colors.white),
                                  ),
                            ),
    ],
                          ),
    ),

                         ),



                          SizedBox(height: _screenHeight * 0.02),
                           Text(
                            'title'.tr,
                            style: TextStyle(
                              color: Colors.white, // Change text color to white
                              fontSize: 20,
                            ),
                          ),

                      SizedBox(height: _screenHeight * 0.02),
                          Container(
                      margin: EdgeInsets.symmetric(horizontal: 0), // Add horizontal margin
                           child:
                          DropdownButtonFormField<String>(
                            value: _selectedrole,
                            dropdownColor: Colors.black,
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  'select'.tr, style: TextStyle(color: Colors.white),
                                ),
                              ),
                              ..._roleList.map((Data district) {
                                return DropdownMenuItem<String>(
                                  value: district.type,
                                  child: Text(district.type, style: TextStyle(color: Colors.white),),
                                );
                              }).toList(),
                            ],
                            onChanged: (String? value) {
                              setState(() {
                                _selectedrole = value;
                              });
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.white.withOpacity(0.19),
                              filled: true,
                              //labelText: 'select_role'.tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(0),    // No rounding for top corners
                                  bottom: Radius.circular(0), // No rounding for bottom corners
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'role_validate'.tr;
                              }
                              return null;
                            },
                            icon: null,
                          ),
                          ),

    SizedBox(height: _screenHeight * 0.02),
                         Container(
                      margin: EdgeInsets.symmetric(horizontal: 0),
                       child:TextFormField(
                            controller: _emailController,
                         style: TextStyle(color: Colors.white),
                         decoration: InputDecoration(
                              fillColor: Colors.white.withOpacity(0.19),
                              filled: true,
                              labelText:
                              'email'.tr,
                              labelStyle: TextStyle(color: Colors.white),
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(0),    // Round only top corners
                                  bottom: Radius.circular(0), // Round only bottom corners
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'emailvalidate'.tr;

                              }
                              return null;
                            },
                          ),

                         ),
    SizedBox(height: _screenHeight * 0.02),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 0),  // Adjust the opacity level as needed
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: passwordVisible,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                fillColor: Colors.white.withOpacity(0.19),
                                filled: true,
                                labelText: 'pass'.tr,labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(0),    // No rounding for top corners
                                    bottom: Radius.circular(0), // No rounding for bottom corners
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  color: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'passwordvalidate'.tr;
                                }
                                return null;
                              },
                            ),
                          ),

    SizedBox(height: _screenHeight * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end, // Align the button to the right side
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.5), // Grey color with opacity
                                  borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ForgetPassword()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent, // Make button transparent
                                    elevation: 0, // Remove button elevation
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10), // Match the container's border radius
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Adjust padding as needed
                                    child: Text(
                                      'forget'.tr,
                                      style: TextStyle(color: Colors.white), // Text color
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
    SizedBox(height: _screenHeight * 0.02),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20), // Add horizontal margin to create space on both sides
                            width: double.infinity, // Set width to match the screen width
                            child: Opacity(
                              opacity: 0.5,
                              child: ElevatedButton(
                                onPressed: () {
                                  loginUser();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue, // Set button color to blue
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Apply border radius to create a rectangle shape
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3), // Add vertical padding to adjust button height
                                  child: Text(
                                    'sign'.tr.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 27,
                                     // fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                              SizedBox(height: _screenHeight * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Align children at the center horizontally
                            children: [
                              Text(
                                'account'.tr,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
    SizedBox(height: _screenHeight * 0.02), // Add space between the text and the button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Align the button at the center horizontally
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegistrationScreen(registeredUsers: {}),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple, // Set button color to purple
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Apply border radius to create a rectangle shape
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Adjust padding as needed
                                  child: Text(
                                    'sign up'.tr.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Row(
                          //   children: [
                          //     Text(
                          //       'account'.tr,
                          //       style: TextStyle(color: Colors.white),
                          //     ),
                          //     Opacity(
                          //       opacity: 0.5, // Adjust the opacity level as needed
                          //       child: ElevatedButton(
                          //         onPressed: () {
                          //           Navigator.push(
                          //               context,
                          //               MaterialPageRoute(
                          //                   builder: (context) => RegistrationScreen(registeredUsers: {},)));
                          //         },
                          //         child: Text(
                          //           'sign up'.tr,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),

                        ],
                      ),
                    ),
    ),
                  ],
                ),
              ),
           // ),
         // ),
        //],
      //),
    ],
    ),
    ),
    ),
    ],
      ),
    );
  }
}

Future<List<Data>> fetchData() async {
  var url = Uri.parse(ApiUrls.usertype);
  //var url = Uri.parse('http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/usertype');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> data = jsonResponse['data'];
    List<Data> dataList = data.map((item) => Data.fromJson(item)).toList();
    return dataList;
  } else {
    throw Exception('Unexpected error occurred!');
  }
}

class Data {
  final String type;

  Data({required this.type});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      type: json['type'],
    );
  }
}

class SuccessScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  SuccessScreen({required this.userData});

  @override
  Widget build(BuildContext context) {
    if (userData['user_type'] == 'xen') {
      return Xen();
      // Replace 'XenScreen()' with your actual Xen screen widget
    } else if (userData['user_type'] == 'farmer') {
      return Farmer(username: '',);
    }else if (userData['user_type'] == 'sdo') {
      //return XenScreen();
      return Xen();
    }
    else if (userData['user_type'] == 'je') {
      return Xen();
      //return XenScreen();
    }
    else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Success'),
        ),
        body: Center(
          child: Text('Login Successful!'),
        ),
      );
    }
  }
}

// Replace 'XenScreen()' with your actual Xen screen widget
class XenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implement your Xen screen UI here
    return Scaffold(
      appBar: AppBar(
        title: Text('Xen Screen'),
      ),
      body: Center(
        child: Text('Welcome to Xen Screen!'),
      ),
    );
  }
}

void main()
{
  // Get.put(LocaleString());
  runApp(MaterialApp(

    home: MyHomePage(title: 'Login Page'),

  ));
}