// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ProfileUpdateScreen(
//         fullName: 'John Doe',
//         userName: 'john.doe@example.com',
//         email: 'john.doe@example.com',
//         mobile: '1234567890',
//         dob: '1990-01-01',
//         gender: 'Male',
//         fatherName: 'Doe Sr.',
//         address: '',
//         aadhar: '',
//         district: '',
//         tehsil: '',
//         block: '',
//         village: '',
//         sessionKey: '',
//       ),
//     );
//   }
// }
//
// class ProfileUpdateScreen extends StatefulWidget {
//   final String fullName;
//   final String userName;
//   final String email;
//   final String mobile;
//   final String dob;
//   final String gender;
//   final String fatherName;
//   final String address;
//   final String aadhar;
//   final String district;
//   final String tehsil;
//   final String block;
//   final String village;
//   final String sessionKey;
//
//   ProfileUpdateScreen({
//     required this.fullName,
//     required this.userName,
//     required this.email,
//     required this.mobile,
//     required this.dob,
//     required this.gender,
//     required this.fatherName,
//     required this.address,
//     required this.aadhar,
//     required this.district,
//     required this.tehsil,
//     required this.block,
//     required this.village,
//     required this.sessionKey,
//   });
//
//   @override
//   _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
// }
//
// class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
//   TextEditingController fullNameController = TextEditingController();
//   TextEditingController userNameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController mobileController = TextEditingController();
//   TextEditingController dobController = TextEditingController();
//   TextEditingController genderController = TextEditingController();
//   TextEditingController fatherNameController = TextEditingController();
//   TextEditingController addressController = TextEditingController();
//   TextEditingController aadharController = TextEditingController();
//   TextEditingController districtController = TextEditingController();
//   TextEditingController tehsilController = TextEditingController();
//   TextEditingController blockController = TextEditingController();
//   TextEditingController villageController = TextEditingController();
//   TextEditingController sessionKeyController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     fullNameController.text = widget.fullName;
//     userNameController.text = widget.userName;
//     emailController.text = widget.email;
//     mobileController.text = widget.mobile;
//     dobController.text = widget.dob;
//     genderController.text = widget.gender;
//     fatherNameController.text = widget.fatherName;
//     addressController.text = widget.address;
//     aadharController.text = widget.aadhar;
//     districtController.text = widget.district;
//     tehsilController.text = widget.tehsil;
//     blockController.text = widget.block;
//     villageController.text = widget.village;
//     sessionKeyController.text = widget.sessionKey;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Update Profile'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: fullNameController,
//               decoration: InputDecoration(labelText: 'Full Name'),
//             ),
//             TextField(
//               controller: userNameController,
//               decoration: InputDecoration(labelText: 'User Name'),
//             ),
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: mobileController,
//               decoration: InputDecoration(labelText: 'Mobile'),
//             ),
//             TextField(
//               controller: dobController,
//               decoration: InputDecoration(labelText: 'Date of Birth (yyyy-mm-dd)'),
//             ),
//             TextField(
//               controller: genderController,
//               decoration: InputDecoration(labelText: 'Gender (m/f)'),
//             ),
//             TextField(
//               controller: fatherNameController,
//               decoration: InputDecoration(labelText: 'Father Name'),
//             ),
//             TextField(
//               controller: addressController,
//               decoration: InputDecoration(labelText: 'Address'),
//             ),
//             TextField(
//               controller: aadharController,
//               decoration: InputDecoration(labelText: 'Aadhar'),
//             ),
//             TextField(
//               controller: districtController,
//               decoration: InputDecoration(labelText: 'District'),
//             ),
//             TextField(
//               controller: tehsilController,
//               decoration: InputDecoration(labelText: 'Tehsil'),
//             ),
//             TextField(
//               controller: blockController,
//               decoration: InputDecoration(labelText: 'Block'),
//             ),
//             TextField(
//               controller: villageController,
//               decoration: InputDecoration(labelText: 'Village'),
//             ),
//             TextField(
//               controller: sessionKeyController,
//               decoration: InputDecoration(labelText: 'Session Key'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 updateProfile();
//               },
//               child: Text('Update Profile'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> updateProfile() async {
//     final url = 'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/farmer/updateprofile';
//     final headers = {'Content-Type': 'application/json'};
//
//     final bodyData = {
//       "code": 400,
//       "error": true,
//       "message": "Session Expired, Please login again.",
//       "data": [],
//     };
//
//     final response = await http.post(
//       Uri.parse(url),
//       headers: headers,
//       body: jsonEncode(bodyData),
//     );
//
//     if (response.statusCode == 200) {
//       print('Profile updated successfully');
//       print(response.body);
//     } else {
//       print('Failed to update profile');
//       print(response.statusCode);
//       print(response.body);
//     }
//   }
// }
//
// class Data {
//   final String districtName;
//
//   Data({required this.districtName});
//
//   factory Data.fromJson(Map<String, dynamic> json) {
//     return Data(districtName: json['DistrictName']);
//   }
// }
//
// class Tehsil {
//   final String tehsilName;
//
//   Tehsil({required this.tehsilName});
//
//   factory Tehsil.fromJson(Map<String, dynamic> json) {
//     return Tehsil(tehsilName: json['TehsilName']);
//   }
// }
//
// class Block {
//   final String blockName;
//
//   Block({required this.blockName});
//
//   factory Block.fromJson(Map<String, dynamic> json) {
//     return Block(blockName: json['BlockName']);
//   }
// }
//
// class Village {
//   final String villageName;
//
//   Village({required this.villageName});
//
//   factory Village.fromJson(Map<String, dynamic> json) {
//     return Village(villageName: json['VillageName']);
//   }
// }
//
// Future<List<Data>> fetchData() async {
//   final response = await http.get(
//     Uri.parse('http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/farmer/districtlist'),
//   );
//
//   if (response.statusCode == 200) {
//     List<dynamic> data = jsonDecode(response.body)['data'];
//     return data.map((json) => Data.fromJson(json)).toList();
//   } else {
//     throw Exception('Failed to load data');
//   }
// }