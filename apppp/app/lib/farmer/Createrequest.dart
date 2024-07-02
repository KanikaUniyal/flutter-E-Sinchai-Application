import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:app/api_urls.dart';
import 'package:app/farmer/mainfarmer.dart';
import 'package:app/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data {
  final String? full_name;
  final String?father_name;
  final String? email;
  final String? mobile;
  final String? district;
  final String? tehsil;
  final String? block;
  final String? village;
  final String? gender;
  Data({
    this.full_name,
    this.father_name,
    this.email,
    this.mobile,
    this.district,
    this.tehsil,
    this.block,
    this.gender,
    this.village,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      full_name: json['full_name'],
      father_name: json['father_name'],
      email: json['email'],
      mobile: json['mobile'],
      district: json['district'],
      tehsil: json['tehsil'],
      block: json['block'],
      village: json['village'],
      gender: json['gender'],
    );
  }
}

class Village {
  final String district;
  final String tehsil;
  final String block;
  final String village;
  final String hadbastNo;

  Village({
    required this.district,
    required this.tehsil,
    required this.block,
    required this.village,
    required this.hadbastNo,
  });

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      district: json['district'],
      tehsil: json['tehsil'],
      block: json['block'],
      village: json['village'],
      hadbastNo: json['hadbast_no'],
    );
  }
}
class OutletInfo {
  final String outlet;
  final String patwariName;

  OutletInfo({required this.outlet, required this.patwariName});
}
class FileSelection {
  final String? file;
  final bool? checked;

  FileSelection({this.file, this.checked});
}
class DisplayData extends StatefulWidget {
  @override
  _DisplayDataState createState() => _DisplayDataState();
}

class _DisplayDataState extends State<DisplayData> {
  Map<String, FileSelection> _selectedFiles = {
    'Jamabandi'.tr: FileSelection(file: null, checked: false),
    'Chakbndi'.tr: FileSelection(file: null, checked: false),
    'naksha_nakal'.tr: FileSelection(file: null, checked: false),
    'Warabandi'.tr: FileSelection(file: null, checked: false),
    'Anyother'.tr: FileSelection(file: null, checked: false),
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<List<Map<String, dynamic>>> _applicationTypesFuture;
  String? _selectedApplicationType;
  String? _selectedNatureOfApplication;
  late Future<List<Map<String, dynamic>>> _natureOfApplicationFuture;
  late Future<List<String>> _waterChannelsFuture;
  String? _selectedWaterChannel;
  // late Future<Map<String, dynamic>> _outletDetailsFuture;
//  late Future<List<String>> _outlets;
  late Future<List<OutletInfo>> _outlets;
  String? _selectedOutlet;
  //List<File> _selectedFiles = []; // Variable to hold selected files
  String? _selectedDocument;
  List<String> _selectedDocuments = [];

  late Future<Data> _profileDataFuture;
  late Future<List<String>> _districtsFuture;
  late Future<List<String>> _tehsilsFuture = Future.value([]);
  late Future<List<String>> _blocksFuture = Future.value([]);
  //late Future<List<String>> _villagesFuture = Future.value([]);
  late Future<List<Village>> _villagesFuture;
  // late Future<List<String>> _tehsilsFuture;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _fatherNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _aadhaarController = TextEditingController();
  TextEditingController _mobileNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _acreageoflandController = TextEditingController();
  TextEditingController _mustilController = TextEditingController();
  TextEditingController _killaNumberController = TextEditingController();
  TextEditingController _reasonController = TextEditingController();
  String? _selectedDistrict;
  String? _selectedTehsil;
  String? _selectedBlock;
  String? _selectedVillage;
  String? _selectedGender;
  late List<String> _districts=[];
  late List<String> _tehsils = [];
  late List<String> _blocks = [];
  late List<String> _villages = [];
  late String userName = ''; // Initialize with empty string
  late String userType = '';

  // List<File> _selectedFiles = [];

  final List<String> _genders = ['Male', 'Female', 'Other'];


  // Map<String, List<File>> _selectedFilesMap = {
  //   'Jamabandi': [],
  //   'Chakbandi': [],
  //   'Naksha Nakal': [],
  //   'Wara Bandi': [],
  //   'Anyother': [],
  // };
  @override
  void initState() {
    super.initState();
    _villagesFuture = fetchVillages("district", "tehsil", "block");
    _applicationTypesFuture = fetchApplicationTypes();
    _natureOfApplicationFuture = fetchNatureOfApplication();
    _profileDataFuture = fetchProfileData();

    _waterChannelsFuture = _fetchWaterChannels(
      _selectedDistrict ?? '',
      _selectedTehsil ?? '',
      _selectedBlock ?? '',
      _selectedVillage ?? '',
    );


    _districtsFuture = fetchDistricts();
    _waterChannelsFuture = Future.value([]);
    _outlets = Future.value([]);

    _selectedDistrict = null;
    _selectedTehsil = null;
    _selectedBlock = null;
    _selectedVillage = null;
    _selectedOutlet = null;
    _districtsFuture.then((districts) {
      setState(() {
        _districts = districts;
      });
    }).catchError((error) {
      print('Error fetching districts: $error');
    });

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

  Future<void> _pickFile(String key) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // type: FileType.any,
      allowedExtensions: ['pdf', 'jpg'],
    );

    if (result != null) {
      setState(() {
        _selectedFiles[key] = FileSelection(file: result.files.first.name, checked: true);
      });
      print('Selected file for $key: ${result.files.first.name}');
    }
  }
  Future<void> _uploadFile(String fileName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/uploads/application/jamabandi/$fileName'),
      );

      // Add file to multipart
      _selectedFiles.forEach((key, value) async {
        if (value.checked == true && value.file != null) {
          var file = File(value.file!);
          request.files.add(await http.MultipartFile.fromPath(key, file.path));
        }
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        print('File uploaded successfully.');
      } else {
        print('Failed to upload file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchApplicationTypes() async {
    var url = Uri.parse(ApiUrls.applicationTypeUrl);
    // var url = Uri.parse(
    //     'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/applicationtype');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body)['data'];
        List<Map<String, dynamic>> applicationTypes = jsonResponse
            .map((type) => {'type': type['type']})
            .cast<Map<String, dynamic>>()
            .toList();
        return applicationTypes;
      } else {
        throw Exception('Error response status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during application type fetch: $error');
      throw Exception('Error occurred during application type fetch.');
    }
  }
  Future<List<Map<String, dynamic>>> fetchNatureOfApplication() async {
    if (_selectedApplicationType == null) {
      return []; // No need to make the request if application type is not selected
    }
    var url = Uri.parse('${ApiUrls.natureOfApplicationUrl}?application_type=$_selectedApplicationType');
    //var url = Uri.parse(
    //    'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/natureofapplication?application_type=$_selectedApplicationType');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body)['data'];
        List<Map<String, dynamic>> natureOfApplication = jsonResponse
            .map((item) => {'nature_of_application': item['nature_of_application']})
            .cast<Map<String, dynamic>>()
            .toList();
        return natureOfApplication;
      } else {
        throw Exception('Error response status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during nature of application fetch: $error');
      throw Exception('Error occurred during nature of application fetch.');
    }
  }


  Future<List<String>> _fetchWaterChannels(
      String? district, String? tehsil, String? block, String? village) async {
    if (district == null ||
        tehsil == null ||
        block == null ||
        village == null) {
      return [];
    }
    // final response = await http.get(Uri.parse(
    //     'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/waterchannel?district=$district&tehsil=$tehsil&block=$block&village=$village')
    // );
    final url = Uri.parse(ApiUrls.waterChannelUrl).replace(queryParameters: {
      'district': district,
      'tehsil': tehsil,
      'block': block,
      'village': village,
    });
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((item) => item['water_channel'] as String).toList();
      } else {
        throw Exception('Failed to load water channels');
      }
    }catch (e) {
      print('Error fetching water channels: $e');
      throw Exception('Failed to load water channels');
    }
  }

  Future<List<OutletInfo>> _fetchOutlets(
      String? district, String? tehsil, String? block, String? village, String? waterChannel) async {
    if (district == null ||
        tehsil == null ||
        block == null ||
        village == null ||
        waterChannel == null) {
      return [];
    }
    final response = await http.post(
        Uri.parse(ApiUrls.outletUrl),
        // final response = await http.post(
        //  Uri.parse('http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/outlet'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"district": district, "tehsil": tehsil, "block": block, "village": village, "water_channel": waterChannel, "session_key": "176fe08640ce42b1c857af93c272755a0e1ce87225fc5b3873a420c4825e785e"}));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((item) => OutletInfo(
        outlet: item['outlet'] as String,
        patwariName: item['patwari_name'] as String,
      )).toList();
    } else {
      throw Exception('Failed to load outlets');
    }
  }

  Future<Data> fetchProfileData() async {
    var url = Uri.parse(ApiUrls.profileUrl);
    // var url = Uri.parse('http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/profile');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String sessionKey = prefs.getString('userData_sessionKey') ?? '';
    userName = prefs.getString('userData_fullName') ?? '';
    userType = prefs.getString('userData_userType') ?? '';
    if (sessionKey.isEmpty) {
      print('Session key not found. Please log in first.');
      // return;
    }
    var headers = {"Content-Type": "application/json"};
    // var keyValuePairs = [
    //   {
    //     "key": "session_key",
    //     "value": "e22d17c541b3ab5aca67f3d89f4d1957f2a8bcf29c77ac7d363069ea2dd58736",
    //     "type": "default"
    //   }
    // ];
    var body = {};
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
          _nameController.text = profileData.full_name ?? '';
          _emailController.text = profileData.email ?? '';
          _mobileNumberController.text = profileData.mobile ?? '';
          _selectedDistrict = profileData.district;
          _selectedTehsil = profileData.tehsil;
          _selectedBlock = profileData.block;
          _selectedVillage = profileData.village;
          _tehsilsFuture = fetchTehsils(_selectedDistrict!);
          _blocksFuture = fetchBlocks(_selectedDistrict!, _selectedTehsil!);
          _villagesFuture = fetchVillages(_selectedDistrict!, _selectedTehsil!, _selectedBlock!);
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
  Future<List<String>> fetchDistricts() async {
    var url = Uri.parse(ApiUrls.districtUrl);
    //var url = Uri.parse('http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/district');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body)['data'];
        List<String> districts = jsonResponse.map((district) => district['district']).cast<String>().toList();
        return districts;
      } else {
        throw Exception('Error response status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during district data fetch: $error');
      throw Exception('Error occurred during district data fetch.');
    }
  }
  Future<List<String>> fetchTehsils(String district) async {
    var url = Uri.parse('${ApiUrls.tehsilUrl}?district=$district');
    //var url = Uri.parse('http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/tehsil?district=$district');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body)['data'];
        List<String> tehsils = jsonResponse.map((tehsil) => tehsil['tehsil']).cast<String>().toList();
        return tehsils;
      } else {
        throw Exception('Error response status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during tehsil data fetch: $error');
      throw Exception('Error occurred during tehsil data fetch.');
    }
  }
  Future<List<String>> fetchBlocks(String district, String tehsil) async {
    var url = Uri.parse('${ApiUrls.blockUrl}?district=$district&tehsil=$tehsil');
    //var url = Uri.parse('http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/block?district=$district&tehsil=$tehsil');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body)['data'];
        List<String> blocks = jsonResponse.map((block) => block['block']).cast<String>().toList();
        return blocks;
      } else {
        throw Exception('Error response status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during block data fetch: $error');
      throw Exception('Error occurred during block data fetch.');
    }
  }
  Future<List<Village>> fetchVillages(String district, String tehsil, String block) async {
    var url = Uri.parse('${ApiUrls.villageUrl}?district=$district&tehsil=$tehsil&block=$block');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((v) => Village.fromJson(v)).toList();
    } else {
      throw Exception('Error fetching villages');
    }
  }

  // Future<List<String>> fetchVillages(String district, String tehsil, String block) async {
  //   var url = Uri.parse('${ApiUrls.villageUrl}?district=$district&tehsil=$tehsil&block=$block');
  //   // var url = Uri.parse(
  //   //     'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/village?district=$district&tehsil=$tehsil&block=$block');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       List<dynamic> jsonResponse = json.decode(response.body)['data'];
  //       _villages = jsonResponse.map((village) => village['village']).cast<String>().toList();
  //       return _villages;
  //     } else {
  //       throw Exception('Error response status code: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error during village data fetch: $error');
  //     throw Exception('Error occurred during village data fetch.');
  //   }
  // }
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
    return
      // MaterialApp(
      //   debugShowCheckedModeBanner: false,
      //   home:
        WillPopScope(
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

            body:Stack(

              children: [
                Image.asset(
                  'images/i2.jpg', // Replace with your actual image path
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
            Form(
              key: _formKey,
              child:SingleChildScrollView(
              padding: EdgeInsets.all(0.0),
              child:
              //SizedBox(height: 20),
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
                        _nameController.text = profileData.full_name ?? '';
                        _emailController.text = profileData.email ?? '';
                        _mobileNumberController.text = profileData.mobile ?? '';
                        _fatherNameController.text=profileData.father_name??'';
                        return SingleChildScrollView(
                         // padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                          Padding(
                          padding: EdgeInsets.all(16.0),
                             child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.19),
                                  borderRadius: BorderRadius.circular(8.0),

                                ),
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Personal Information'.tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Name'.tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white, // Set the color of the bottom border
                                        width: 1.0, // Set the width of the bottom border
                                      ),
                                    ),
                                  ),

                            child:  TextField(
                                controller: _nameController,
                                enabled: false,
                                // initialValue: profileData.full_name,
                                // decoration: InputDecoration(
                                //   //labelText: 'Full Name',labelStyle: TextStyle(color: Colors.white),
                                //    ),
                                style: TextStyle(color: Colors.white),
                              ),

                              ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Father Name'.tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                              SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white, // Set the color of the bottom border
                                        width: 1.0, // Set the width of the bottom border
                                      ),
                                    ),
                                  ),

                                  child:
                              TextField(
                                controller: _fatherNameController,
                                enabled: false,
                                // initialValue: profileData.father_name,
                                decoration: InputDecoration(
                                  //labelText: 'Email',labelStyle: TextStyle(color: Colors.white),
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                                ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Mobile No'.tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                              SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white, // Set the color of the bottom border
                                        width: 1.0, // Set the width of the bottom border
                                      ),
                                    ),
                                  ),

                                  child:
                              TextFormField(
                                controller: _mobileNumberController,
                                enabled: false,
                                // initialValue: profileData.mobile,
                                decoration: InputDecoration(
                                  //labelText: 'Mobile',labelStyle: TextStyle(color: Colors.white),
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                                ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Email'.tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white, // Set the color of the bottom border
                                        width: 1.0, // Set the width of the bottom border
                                      ),
                                    ),
                                  ),

                                  child:
                                    TextField(
                                      controller: _emailController,
                                      enabled: false,
                                      // initialValue: profileData.father_name,
                                      decoration: InputDecoration(
                                       // labelText: 'Email',labelStyle: TextStyle(color: Colors.white),
                                      ),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                ),

                            ],
                          ),
                        ),
                          ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity, // Set width to match parent
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Your onPressed logic here
                                  }, // Set onPressed to null to make it non-clickable
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0), // Set border radius
                                    ),
                                    elevation: 0, // Set text color
                                    fixedSize: Size(double.infinity, 48), // Set button size
                                  ),
                                  child: Text(
                                    'create new request'.tr,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    SizedBox(height: 8),
                    Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Required'.tr, // Add your text here
                    style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    ),
                    ),
                    ),
                    ],
                    ),
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    SizedBox(height: 8),
                    Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                    'Select Application Type'.tr+'*', // Add your text here
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    //fontWeight: FontWeight.bold,
                    ),
                    ),
                    ),
                    Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),// Add horizontal padding
                    child:

                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _applicationTypesFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    List<Map<String, dynamic>> applicationTypes = snapshot.data ?? [];
                                    return DropdownButtonFormField<String>(
                                      dropdownColor: Colors.black,
                                      value: _selectedApplicationType,

                                      onChanged: (value) {
                                        setState(() {
                                          _selectedApplicationType = value;
                                          _selectedNatureOfApplication = null;
                                        });
                                        _natureOfApplicationFuture = fetchNatureOfApplication();
                                      },
                                      items: [

                                    DropdownMenuItem<String>(
                                  // value: 'Select Option',
                                         value:null,
                                      child: Text(
                                        'Select Option'.tr,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                     // enabled: false, // Disable the item
                                    ),
                                  ...applicationTypes.map((type) {
                                        return DropdownMenuItem<String>(
                                          value: type['type'],
                                          child: Text(type['type']),
                                        );
                                      }).toList(),
                                  ],
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        filled: true,
                                        fillColor: Colors.grey.withOpacity(0.3),
                                        //hintStyle: TextStyle(color: Colors.white),


                                      ),
                                       style: TextStyle(color: Colors.white),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                },
                              ),
                    ),
                    ],
                    ),
                    //
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    SizedBox(height: 8),
                    Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                    'Nature of case'.tr+'*', // Add your text here
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    //fontWeight: FontWeight.bold,
                    ),
                    ),
                    ),
                    // Padding(
                    // padding: EdgeInsets.symmetric(horizontal: 16.0),
                    // child: Expanded(// Add horizontal padding
                    // child:
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _natureOfApplicationFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    List<Map<String, dynamic>> natureOfApplications = snapshot.data ?? [];
                                    return DropdownButtonFormField<String>(
                                      dropdownColor: Colors.black,
                                      value: _selectedNatureOfApplication,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedNatureOfApplication = value;
                                        });
                                      },
                                      items: [

                                      DropdownMenuItem<String>(
                                      // value: 'Select Option',
                                      value:null,
                                      child: Text(
                                        'Select Option'.tr,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                       //enabled: false, // Disable the item
                                    ),
                                  ...natureOfApplications.map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item['nature_of_application'],
                                          child: Text(item['nature_of_application']),
                                        );
                                      }).toList(),
                                  ],
                                      decoration: InputDecoration(

                                      ),
                                       style: TextStyle(color: Colors.white),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                },
                              ),
                   // ),
                   // ),
                             ],
                   ),
                              SizedBox(height: 8),
                    Container(
                      margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                      //padding: EdgeInsets.all(16.0),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Application Detail'.tr, // Add your additional text here
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'District'.tr+'*', // Add your text here
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),// Add horizontal padding
                        child:

                              FutureBuilder<List<String>>(
                                future: _districtsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else {
                                    _districts = snapshot.data ?? [];
                                    return DropdownButtonFormField<String>(
                                      dropdownColor: Colors.black,
                                      value: _selectedDistrict,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedDistrict = value;
                                          _selectedTehsil = null;
                                          _selectedBlock = null;
                                          _selectedVillage = null;

                                          _tehsilsFuture = fetchTehsils(value!);

                                          _waterChannelsFuture = _fetchWaterChannels(
                                            value,
                                            _selectedTehsil ?? '',
                                            _selectedBlock ?? '',
                                            _selectedVillage ?? '',
                                          );
                                        });
                                      },
                                      items: _districts.map((String district) {
                                        return DropdownMenuItem<String>(
                                          value: district,
                                          child: Text(district),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        fillColor: Colors.white.withOpacity(0.19),
                                        filled: true,
                                        border: OutlineInputBorder(

                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      style: TextStyle(color: Colors.white),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                },
                              ),
                      ),
                      ],
                    ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Tehsil'.tr+'*', // Add your text here
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),// Add horizontal padding
                        child:

                              FutureBuilder<List<String>>(
                                future: _tehsilsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else {
                                    _tehsils = snapshot.data ?? [];
                                    return DropdownButtonFormField<String>(
                                      dropdownColor: Colors.black,
                                      value: _selectedTehsil,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedTehsil = value;
                                          _selectedBlock = null;
                                          _selectedVillage = null;
                                          _blocksFuture = fetchBlocks(_selectedDistrict!, value!);
                                          _waterChannelsFuture = _fetchWaterChannels(
                                            _selectedDistrict!,
                                            value,
                                            _selectedBlock ?? '',
                                            _selectedVillage ?? '',
                                          );


                                        });
                                      },
                                      items: _tehsils.map((String tehsil) {
                                        return DropdownMenuItem<String>(
                                          value: tehsil,
                                          child: Text(tehsil),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        fillColor: Colors.white.withOpacity(0.19),
                                        filled: true,
                                        border: OutlineInputBorder(

                                          borderSide: BorderSide.none,
                                        ),
                                       // labelText: 'Tehsil',labelStyle: TextStyle(color: Colors.white),
                                      ),
                                      style: TextStyle(color: Colors.white),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                },
                              ),
                      ),
                              ],
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Block'.tr+'*', // Add your text here
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),// Add horizontal padding
                        child:
                              FutureBuilder<List<String>>(
                                future: _blocksFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else {
                                    _blocks = snapshot.data ?? [];
                                    return DropdownButtonFormField<String>(
                                      dropdownColor: Colors.black,
                                      value: _selectedBlock,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedBlock = value;
                                          _selectedVillage = null;
                                          _villagesFuture =
                                              fetchVillages(_selectedDistrict!, _selectedTehsil!, value!);
                                          _waterChannelsFuture = _fetchWaterChannels(
                                            _selectedDistrict!,
                                            _selectedTehsil!,
                                            value,
                                            _selectedVillage ?? '',
                                          );


                                        });
                                      },
                                      items: _blocks.map((String block) {
                                        return DropdownMenuItem<String>(
                                          value: block,
                                          child: Text(block),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        fillColor: Colors.white.withOpacity(0.19),
                                        filled: true,
                                        border: OutlineInputBorder(

                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                       style: TextStyle(color: Colors.white),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                },
                              ),
                      ),
                              ],
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Village'.tr+'*', // Add your text here
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),// Add horizontal padding
                        child:
                        FutureBuilder<List<Village>>(
                          future: _villagesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Center(child: Text("Error fetching villages"));
                            } else {
                              var villages = snapshot.data ?? [];
                              return DropdownButtonFormField<Village>(
                                dropdownColor: Colors.black,
                                value: villages.firstWhereOrNull((v) => v.village == _selectedVillage),
                                onChanged: (village) {
                                  setState(() {
                                    _selectedVillage = village?.village;
                                  });
                                },
                                items: villages.map((village) {
                                  return DropdownMenuItem<Village>(
                                    value: village,
                                    child: Text('${village.village} ( ${village.hadbastNo})'),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  labelText: 'Village',
                                  labelStyle: TextStyle(color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.2),
                                ),
                                style: TextStyle(color: Colors.white),
                              );
                            }
                          },
                        ),
                              // FutureBuilder<List<String>>(
                              //   future: _villagesFuture,
                              //   builder: (context, snapshot) {
                              //     if (snapshot.connectionState == ConnectionState.waiting) {
                              //       return CircularProgressIndicator();
                              //     } else if (snapshot.hasError) {
                              //       return Text('Error: ${snapshot.error}');
                              //     } else {
                              //       return DropdownButtonFormField<String>(
                              //         dropdownColor: Colors.black,
                              //         value: _selectedVillage,
                              //         onChanged: (value) {
                              //           setState(() {
                              //             _selectedVillage = value;
                              //             _waterChannelsFuture = _fetchWaterChannels(
                              //               _selectedDistrict!,
                              //               _selectedTehsil!,
                              //               _selectedBlock!,
                              //               value!,
                              //             );
                              //             _selectedWaterChannel =
                              //             null;
                              //           });
                              //         },
                              //         items: _villages.map((String village) {
                              //           return DropdownMenuItem<String>(
                              //             value: village,
                              //             child: Text(village),
                              //           );
                              //         }).toList(),
                              //         decoration: InputDecoration(
                              //           //labelText: 'Village',labelStyle: TextStyle(color: Colors.white),
                              //           fillColor: Colors.white.withOpacity(0.19),
                              //           filled: true,
                              //           border: OutlineInputBorder(
                              //
                              //             borderSide: BorderSide.none,
                              //           ),
                              //         ),
                              //         style: TextStyle(color: Colors.white),
                              //         validator: (value) {
                              //           if (value == null || value.isEmpty) {
                              //             return '';
                              //           }
                              //           return null;
                              //         },
                              //       );
                              //     }
                              //   },
                              // ),
                      ),
                              ],
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Name of Water Channel'.tr+'*', // Add your text here
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),// Add horizontal padding
                        child:FutureBuilder<List<String>>(
                                future: _waterChannelsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return DropdownButtonFormField<String>(
                                      dropdownColor: Colors.black,
                                      decoration: InputDecoration(

                                          //labelText: 'Village',labelStyle: TextStyle(color: Colors.white),
                                          fillColor: Colors.white.withOpacity(0.19),
                                          filled: true,
                                          border: OutlineInputBorder(

                                            borderSide: BorderSide.none,
                                          ),

                                        //hintText: 'Select Water Channel',
                                        // You can add more styling or decoration here
                                      ),
                                      value: _selectedWaterChannel,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedWaterChannel = newValue;
                                          _outlets = _fetchOutlets(
                                            _selectedDistrict,
                                            _selectedTehsil,
                                            _selectedBlock,
                                            _selectedVillage,
                                            newValue,
                                          );
                                          _selectedOutlet = null; // Reset selected outlet
                                        });
                                      },
                                      items:  [

                                      DropdownMenuItem<String>(
                                      // value: 'Select Option',
                                      value:null,
                                      child: Text(
                                        'Name of Water Channel'.tr+'*',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      //enabled: false, // Disable the item
                                    ),
                                  ...snapshot.data!.map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        },
                                      ).toList(),
                                  ],
                                      style: TextStyle(color: Colors.white),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    );
                                  }
                                },
                              ),
                      ),
                              ],
                      ),


                              //FutureBuilder<List<String>>
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'R.D. of Outlet with side with Patwari Name'.tr+'*', // Add your text here
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),// Add horizontal padding
                        child: FutureBuilder<List<OutletInfo>>(
                                future: _outlets,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return DropdownButtonFormField<String>(
                                      dropdownColor: Colors.black,
                                      decoration: InputDecoration(
                                        fillColor: Colors.white.withOpacity(0.19),
                                        filled: true,
                                        border: OutlineInputBorder(

                                          borderSide: BorderSide.none,
                                        ),
                                        //hintText: 'Select Outlet',
                                        // You can add more styling or decoration here
                                      ),
                                      value: _selectedOutlet,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedOutlet = newValue;
                                        });
                                      },
                                      items:  [

                                      DropdownMenuItem<String>(
                                      // value: 'Select Option',
                                      value:null,
                                      child: Text(
                                        'R.D. of Outlet with side'.tr+'*',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      //enabled: false, // Disable the item
                                    ),
                                  ...snapshot.data!.map<DropdownMenuItem<String>>(
                                            (OutletInfo outletInfo) {
                                          return DropdownMenuItem<String>(
                                            value: outletInfo.outlet,
                                            child: Text('${outletInfo.outlet} - ${outletInfo.patwariName}', style: TextStyle(color: Colors.white),),
                                          );
                                        },
                                      ).toList(),
                                  ],
                                      // validator: (value) {
                                      //   if (value == null || value.isEmpty) {
                                      //     return '';
                                      //   }
                                      //   return null;
                                      // },
                                    );
                                  }
                                },
                              ),
                      ),
                              ],
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Enter Acreage of Land'.tr+'*', // Add your text here
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),// Add horizontal padding
                        child:
                        TextFormField(
                                controller: _acreageoflandController,
                                keyboardType: TextInputType.number,
                                // initialValue: profileData.mobile,
                                decoration: InputDecoration(
                                  fillColor: Colors.white.withOpacity(0.19),
                                  filled: true,
                                  border: OutlineInputBorder(

                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: 'Enter Acreage of Land'.tr+'*',hintStyle: TextStyle(color: Colors.white),
                                ),
                                style: TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '';
                            }
                            return null;
                          },
                              ),
                      ),
                              ],
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Mustil No.'.tr+'*', // Add your text here
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),// Add horizontal padding
                        child:

                              TextFormField(
                                controller: _mustilController,
                                // initialValue: profileData.mobile,
                                decoration: InputDecoration(fillColor: Colors.white.withOpacity(0.19),
                                  filled: true,
                                  border: OutlineInputBorder(

                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: 'Mustil No.'.tr+'*',hintStyle: TextStyle(color: Colors.white),),
                                style: TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '';
                                  }
                                  return null;
                                },
                              ),
                      ),
                              ],
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Enter killa/khasra No.'.tr+'*', // Add your text here
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          //  fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),// Add horizontal padding
                        child:

                              TextFormField(
                                controller: _killaNumberController,
                                // initialValue: profileData.mobile,
                                decoration: InputDecoration(fillColor: Colors.white.withOpacity(0.19),
                                  filled: true,
                                  border: OutlineInputBorder(

                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: 'Enter killa/khasra No.'.tr+'*',hintStyle: TextStyle(color: Colors.white),),
                                style: TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '';
                                  }
                                  return null;
                                },
                              ),
                      ),
                              ],
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Reason in detail, for submitting the application'.tr+'*', // Add your text here
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),// Add horizontal padding
                        child:
                              TextFormField(
                                controller: _reasonController,
                                // initialValue: profileData.mobile,
                                decoration: InputDecoration(fillColor: Colors.white.withOpacity(0.19),
                                  filled: true,
                                  border: OutlineInputBorder(

                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: 'Reason in detail, for submitting the application'.tr+'*',hintStyle: TextStyle(color: Colors.white),),
                                style: TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '';
                                  }
                                  return null;
                                },
                              ),
                      ),
                              ],
                    ),
                      SizedBox(height: 10),
                      ],
                    ),
                    ),
                              SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [   Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child:Text(
                                    'List of Documents with the application:'.tr,
                                    style: TextStyle(color: Colors.white,
                                       // fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                  for (var entry in _selectedFiles.entries)
                                  //for (String documentType in ['Jamabandi', 'Chakbandi', 'Naksha Nakal', 'Wara Bandi', 'Anyother'])
                                    Row(
                                      //crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                       Checkbox(
                                          value: entry.value.checked ?? false,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedFiles[entry.key] = FileSelection(
                                                file: entry.value.file,
                                                checked: value,
                                              );
                                            });
                                          },
                                          activeColor: Colors.white,
                                        ),

                                        GestureDetector(
                                          onTap: () {
                                            if (entry.value.checked == true) _pickFile(entry.key);
                                          },
                                          child: Text(entry.key, style: TextStyle(color: Colors.white),),
                                        ),
                                        SizedBox(width: 20),
                                        Visibility(
                                          visible: entry.value.checked == true,
                                          child: ElevatedButton(
                                            onPressed: () => _pickFile(entry.key),
                                            child: Text('Select File'),
                                          ),
                                        ),

                                        SizedBox(width: 20),

                                        if (entry.value.file != null && entry.value.checked == true)
                                          Text(
                                            entry.value.file!,
                                            style: TextStyle(color: Colors.white,fontSize: 16),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0.0),
                    color: Colors.blue, // Set the background color to blue
                    ),
                    child:
                              ElevatedButton(
                                onPressed: () async {

                                 //   if (_selectedApplicationType==null||_selectedNatureOfApplication==null||_killaNumberController.text.isEmpty
                                 //   ||_selectedOutlet==null||_waterChannelsFuture==null||_selectedVillage==null
                                 //   ||_selectedDistrict==null||_selectedTehsil==null||_selectedBlock==null||_acreageoflandController.text.isEmpty||_mustilController.text.isEmpty||_reasonController.text.isEmpty)
                                 //     {
                                 //
                                 //       // showCustomToast(context, 'error', 'images/wrd_logo.png');
                                 //     }
                                 // else
                                   if  (_formKey.currentState!.validate()) {
                                    //await updateProfile();

                                    _showConfirmationDialog();

                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.blue, // Set the text color to white
                                ),
                                child: Text('Submit'.tr.toUpperCase()),

                              ),

                    ),
                              SizedBox(height: 16),
                            ],
                          ),
                        );
                      } else {
                        return Center(child: Text('No profile data available'));
                      }
                    }
                  },
                ),
            ),
            ),
              ],

            ),
          ),
       // ),
      );
  }


  void _showConfirmationDialog()async {

    if (_formKey.currentState!.validate()) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
            // Set background color of AlertDialog to grey
            data: Theme.of(context).copyWith(
          dialogBackgroundColor: Colors.blueGrey[300],
        ),
        child:AlertDialog(
          //title: Text('Submit Application'),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        ),
          content: Text('Are you sure you want to submit this form?'.tr, style: TextStyle(color: Colors.white),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'.tr, style: TextStyle(color: Colors.teal[400]),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitForm();
              },
              child: Text('Yes'.tr, style: TextStyle(color: Colors.teal[400]),),
            ),
          ],
        ),
        );
      },
    );
  }
    else {
      // Form is invalid, fetch and show toast message


    }
  }



  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Your form submission logic goes here
      try {
        // Call your updateProfile function here
        await updateProfile();
      } catch (error) {
        print('Error during form submission: $error');
        // Show error message to the user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ));

      }
    }
  }

  Future<void> updateProfile() async {
  try {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String sessionKey = prefs.getString('userData_sessionKey') ?? '';
  if (sessionKey.isEmpty) {
  print('Session key not found. Please log in first.');
  return;
  }
  var url = Uri.parse(ApiUrls.createApplicationUrl);
  //var url = Uri.parse('http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/application/create');
  var headers = {"Content-Type": "application/json"};
  var body = {
  //"session_key": "f8329dce150599ba7ae97b4f053693cb9464d2723bb620ab38457c458eb8f8b2",
  "session_key": sessionKey,
  "full_name": _nameController.text,
  "father_name": _fatherNameController.text,
  "email": _emailController.text,
  "dob": _dobController.text,
  "aadhar": _aadhaarController.text,
  "mobile": _mobileNumberController.text,
  "address": _addressController.text,
  "district": _selectedDistrict,
  "tehsil": _selectedTehsil,
  "block": _selectedBlock,
  "village": _selectedVillage,
  "gender": _selectedGender,
  "application_type": _selectedApplicationType,
  "nature_of_application":_selectedNatureOfApplication,
  "water_channel":_selectedWaterChannel,
  "outlet":_selectedOutlet,
  // "outlet":_outletDetailsFuture,
  "acreage_of_land":_acreageoflandController.text,
  "mustil_no":_mustilController.text,
  "killa_no":_killaNumberController.text,
  "reason":_reasonController.text,
  'jamabandi': _selectedFiles['Jamabandi']?.file ?? '',
  'chakbandi': _selectedFiles['chakbndi']?.file ?? '',
  'naksha_nakal': _selectedFiles['naksha_nakal']?.file ?? '',
  'warabandi': _selectedFiles['warabandi']?.file ?? '',
  //"files": _selectedFilesMap,
  };
  _selectedFiles.forEach((key, value) {
  if (value.checked == true && value.file != null) {
  body[key.toLowerCase().replaceAll(' ', '_')] = value.file!;
  }
  });

  var bodyJson = jsonEncode(body);
  print('Request Body: $bodyJson');
  final response = await http.post(
  url,
  headers: headers,
  body: bodyJson,
  );
  print('Response status code: ${response.statusCode}');
  print('Response body: ${response.body}');
  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    // Handle success response
    // print('Success Response: $jsonResponse');
    // final jsonData = json.decode(response.body);
    // String message = jsonData['message'];
    //showCustomToast(message, 'images/wrd_logo.png');
    if (jsonResponse['error'] == false) {
      showCustomToast(context, jsonResponse['message'], 'images/wrd_logo.png');
    } else {
      showCustomToast(context, jsonResponse['message'], 'images/wrd_logo.png');
    }
  }
  else if (response.statusCode == 400) {
    // Handle error response with code 400
    var errorJson = json.decode(response.body);
    final errorMessage = errorJson['message'];
    showCustomToast(context, errorMessage, 'images/wrd_logo.png'); // Display dynamic toast message
    print('Error: $errorMessage');

  } else {
  print('Error Response: ${response.statusCode}, ${response.body}');
  throw Exception('Error response status code: ${response.statusCode}');
  }
  } catch (error) {
  print('Error during create: $error');
  // Handle error
  if (error is http.Response) {
  // Print the response body for more details
  print('Response Body: ${error.body}');
  }
  }
         }
}

void main() {
  runApp(MaterialApp(
    home: DisplayData(),
  ));
}