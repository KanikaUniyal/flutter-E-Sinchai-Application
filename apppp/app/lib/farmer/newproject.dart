// import 'package:app/SignUp.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class DisplayData extends StatefulWidget {
//
//
//   @override
//   _DisplayDataScreenState createState() => _DisplayDataScreenState();
// }
//
// class _DisplayDataScreenState extends State<DisplayData> {
//   late String _sessionKey;
//   late Map<String, String> _registrationData;
//   late Future<List<String>> _districtsFuture;
//   late Future<List<String>> _tehsilsFuture;
//   late Future<List<String>> _blocksFuture;
//   late Future<List<String>> _villagesFuture;
//   // late Future<List<String>> _waterChannelsFuture;
//   String    selectedWaterChannel='';
//   List<String> waterChannels=[];
//
//   TextEditingController _typeOfApplicationController = TextEditingController();
//   TextEditingController _landController = TextEditingController();
//   TextEditingController _musilController = TextEditingController();
//   TextEditingController _killaController = TextEditingController();
//   List<String> _applicationTypes = [];
//   List<String> _natureOfApplications = [];
//   String? _selectedApplicationType;
//   String? _selectedNatureOfApplication;
//   String selectedNatureOfCase = '';
//   List<String> _districts = [];
//   List<String> _tehsils = [];
//   List<String> _blocks = [];
//   List<String> _villages = [];
//   String? _selectedDistrict;
//   String? _selectedTehsil;
//   String? _selectedBlock;
//   String? _selectedVillage;
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     // _registrationData = RegistrationDataSingleton().registrationData;
//     // Call the API on initialization
//     _districtsFuture = _fetchDistricts();
//     // _tehsilsFuture = Future.value([]);
//     _selectedDistrict = _registrationData['District'];
//     _tehsilsFuture = _fetchTehsils(_selectedDistrict!);
//     _selectedTehsil = _registrationData['Tehsil'];
//     _blocksFuture = _fetchBlocks(_selectedDistrict!, _selectedTehsil!);
//     _selectedBlock = _registrationData['Block'];
//     _villagesFuture =
//         _fetchVillages(_selectedDistrict!, _selectedTehsil!, _selectedBlock!);
//     _selectedVillage = _registrationData['Village'];
//     fetchWaterChannels(_selectedDistrict!, _selectedTehsil!, _selectedBlock!, _selectedVillage!);
//     _callApi();
//
//   }
//
//
//
//   @override
//   void dispose() {
//     // Dispose the controllers
//     _landController.dispose();
//     _musilController.dispose();
//     _killaController.dispose();
//     super.dispose();
//   }
//   Future<List<String>> _fetchDistricts() async {
//     final response = await http.get(
//       Uri.parse(
//           'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/district'),
//     );
//
//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);
//       List<String> districts = List<String>.from(
//           jsonData['data'].map((district) => district['district']));
//       districts = districts.toSet().toList();
//       return districts;
//     } else {
//       throw Exception('Failed to load districts data');
//     }
//   }
//   Future<List<String>> _fetchTehsils(String district) async {
//     final response = await http.get(
//       Uri.parse(
//           'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/tehsil?district=$district'),
//     );
//
//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);
//       List<String> tehsils = List<String>.from(
//           jsonData['data'].map((tehsil) => tehsil['tehsil']));
//       tehsils= tehsils.toSet().toList();
//       return tehsils;
//     } else {
//       throw Exception('Failed to load tehsils data');
//     }
//   }
//   Future<List<String>> _fetchBlocks(String district, String tehsil) async {
//     final response = await http.get(
//       Uri.parse(
//           'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/block?district=$district&tehsil=$tehsil'),
//     );
//
//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);
//       List<String> blocks = List<String>.from(
//           jsonData['data'].map((block) => block['block']));
//       blocks = blocks.toSet().toList();
//       return blocks;
//     } else {
//       throw Exception('Failed to load blocks data');
//     }
//   }
//
//   Future<List<String>> _fetchVillages(String district, String tehsil,
//       String block) async {
//     final response = await http.get(
//       Uri.parse(
//           'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/village?district=$district&tehsil=$tehsil&block=$block'),
//     );
//
//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);
//       List<String> villages = List<String>.from(
//           jsonData['data'].map((village) => village['village']));
//       villages = villages.toSet().toList();
//       return villages;
//     } else {
//       throw Exception('Failed to load villages data');
//     }
//   }
//   Future<void> _callApi() async {
//     final apiUrl = 'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/applicationtype';
//
//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData['error'] == false) {
//           List<dynamic> applicationTypes = responseData['data'];
//
//           setState(() {
//             _applicationTypes = applicationTypes.map((type) => type['type'].toString()).toList();
//           });
//         } else {
//           // Handle error scenario
//           print('API Error: ${responseData['message']}');
//         }
//       } else {
//         // Handle other HTTP status codes
//         print('HTTP Error: ${response.statusCode}');
//       }
//     } catch (error) {
//       // Handle network or other errors
//       print('Error calling API: $error');
//     }
//   }
//
//   Future<void> _callNatureOfApplicationApi(String selectedApplicationType) async {
//     final natureOfApplicationApiUrl =
//         'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/natureofapplication?application_type=$selectedApplicationType';
//
//     try {
//       final response = await http.get(Uri.parse(natureOfApplicationApiUrl));
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData['error'] == false) {
//           List<dynamic> natureOfApplications = responseData['data'];
//
//           setState(() {
//             _natureOfApplications = natureOfApplications
//                 .map((nature) => nature['nature_of_application'].toString())
//                 .toList();
//             selectedNatureOfCase =
//             _natureOfApplications.isNotEmpty ? _natureOfApplications[0] : '';
//           });
//         } else {
//           // Handle API error
//           print('Nature of Case API Error: ${responseData['message']}');
//         }
//       } else {
//         // Handle HTTP error
//         print('Nature of Case API HTTP Error: ${response.statusCode}');
//       }
//     } catch (error) {
//       // Handle network or other errors
//       print('Nature of Case API Error: $error');
//     }
//   }
//   Future<void> fetchWaterChannels(String selectedDistrict, String selectedTehsil, String selectedBlock, String selectedVillage) async {
//     final apiUrl = 'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/waterchannel';
//
//     try {
//       final response = await http.get(
//         Uri.parse('$apiUrl?district=$selectedDistrict&tehsil=$selectedTehsil&block=$selectedBlock&village=$selectedVillage'),
//         headers: {"Content-Type": "application/json"},
//       );
//
//       if (response.statusCode == 200) {
//         final waterChannelData = jsonDecode(response.body);
//         final List<dynamic> waterChannelList = waterChannelData['data'];
//
//         setState(() {
//           waterChannels = waterChannelList.map((channel) => channel['water_channel'].toString()).toList();
//           selectedWaterChannel = waterChannels.isNotEmpty ? waterChannels[0] : '';
//         });
//       } else {
//         print('Failed to fetch water channels. Status code: ${response.statusCode}');
//         print(response.body);
//       }
//     } catch (error) {
//       print('Network error: $error');
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Display Registration Data'),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildTextField('Name', _registrationData['Name'] ?? ''),
//             _buildTextField('Father Name', _registrationData['Father Name'] ?? ''),
//             _buildTextField('Email', _registrationData['Email'] ?? ''),
//             _buildTextField('Mobile Number', _registrationData['Mobile Number'] ?? ''),
//
//             // Divider Section
//             SizedBox(height: 16.0),
//             Container(
//               height: 2.0,  // Adjust the thickness of the divider
//               color: Colors.blue,  // Adjust the color of the divider
//               margin: EdgeInsets.symmetric(vertical: 8.0),
//             ),
//             SizedBox(height: 8.0),
//             Center(
//               child: Text(
//                 'Create User',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16.0,
//                   color: Colors.blue,
//                 ),
//               ),
//             ),
//             SizedBox(height: 8.0),
//             Container(
//               height: 2.0,
//               color: Colors.blue,
//               margin: EdgeInsets.symmetric(vertical: 8.0),
//             ),
//
//             // Dropdown for displaying the fetched application types
//             DropdownButtonFormField<String>(
//               value: _selectedApplicationType,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedApplicationType = newValue;
//                   _selectedNatureOfApplication = null; // Reset the selected nature of application
//                   _callNatureOfApplicationApi(newValue!); // Fetch nature of application data
//                 });
//               },
//               items: _applicationTypes.map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               decoration: InputDecoration(
//                 labelText: 'Select Type of Application',
//               ),
//             ),
//             DropdownButtonFormField<String>(
//               value: _selectedNatureOfApplication,
//               onChanged: (value) {
//                 setState(() {
//                   _selectedNatureOfApplication = value!;
//                 });
//               },
//               items: _natureOfApplications.map((value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               decoration: InputDecoration(labelText: 'Select Nature of Case'),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please select Nature of Case';
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 16),
//             FutureBuilder<List<String>>(
//               future: _districtsFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else if (snapshot.hasError|| snapshot.data == null) {
//                   return Text('Error: Failed to load districts data ${snapshot.error}');
//                 } else {
//                   List<String> districts = snapshot.data!;
//                   return _buildDistrictDropdownButton(districts);
//                 }
//               },
//             ),
//             SizedBox(height: 16),
//             FutureBuilder<List<String>>(
//               future: _tehsilsFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error: Failed to load tehsils data${snapshot.error}');
//                 } else {
//                   List<String> tehsils = snapshot.data!;
//                   return _buildTehsilDropdownButton(tehsils);
//                 }
//               },
//             ),
//             SizedBox(height: 16),
//             FutureBuilder<List<String>>(
//               future: _blocksFuture,
//               builder: (context, snapshot) {
//
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else {
//                   List<String> blocks = snapshot.data!;
//                   return _buildBlockDropdownButton(blocks);
//                 }
//               },
//             ),
//             SizedBox(height: 16),
//             FutureBuilder<List<String>>(
//               future: _villagesFuture,
//               builder: (context, snapshot) {
//
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else {
//                   List<String> villages = snapshot.data!;
//                   return _buildVillageDropdownButton(villages);
//                 }
//               },
//             ),
//             SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: selectedWaterChannel,
//               onChanged: (value) {
//                 setState(() {
//                   selectedWaterChannel = value!;
//                 });
//               },
//               items: waterChannels.map((value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               decoration: InputDecoration(labelText: 'Select Water Channel'),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please select Water Channel';
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: _landController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Land',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: _musilController,
//               decoration: InputDecoration(
//                 labelText: 'Musil No',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: _killaController,
//               decoration: InputDecoration(
//                 labelText: 'Killa No',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             // ElevatedButton(
//             //   onPressed: () {
//             //     // Handle submit logic here
//             //   },
//             //   child: Text('Submit'),
//             // ),
//             // ElevatedButton(
//             //   onPressed: _submitData,
//             //   child: Text('Submit'),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//
//
//
//   Widget _buildTextField(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.0),
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(12.0),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               value,
//               style: TextStyle(color: Colors.grey[700]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDistrictDropdownButton(List<String> districts) {
//
//     // Set default district
//     String defaultDistrict = _selectedDistrict ?? districts.first;
//
//     // Check if _selectedDistrict is among the districts
//     if (!districts.contains(_selectedDistrict)) {
//       print('Selected district does not exist in the dropdown');
//       _selectedDistrict = defaultDistrict; // Set to default if not found
//     }
//
//     return DropdownButtonFormField<String>(
//       value: _selectedDistrict , // Use default value if _selectedDistrict is null
//       onChanged: (String? newValue) {
//         setState(() {
//           _selectedDistrict = newValue!;
//           _selectedTehsil = null;
//           _selectedBlock = null;
//           _selectedVillage = null;
//           _tehsilsFuture = _fetchTehsils(_selectedDistrict!);
//           _blocksFuture = Future.value([]); // Reset blocks future to empty
//           _villagesFuture = Future.value([]);
//           _registrationData['District'] = ''; // Provide a default value if newValue is null
//           _registrationData['Tehsil'] = '';
//           _registrationData['Block'] = '';
//           _registrationData['Village'] = '';
//         });
//       },
//       items: districts.map<DropdownMenuItem<String>>((district) {
//         return DropdownMenuItem<String>(
//           value: district,
//           child: Text(district),
//         );
//       }).toList(),
//       decoration: InputDecoration(
//         labelText: 'District',
//         border: OutlineInputBorder(),
//       ),
//     );
//   }
//   Widget _buildTehsilDropdownButton(List<String> tehsils) {
//     if (tehsils.isEmpty) {
//       return SizedBox.shrink(); // Hide the tehsil dropdown if no data is available
//     }
//     // Set default tehsil
//     String defaultTehsil = _selectedTehsil ?? tehsils.first;
//
//     // Check if _selectedTehsil is among the tehsils
//     if (!tehsils.contains(_selectedTehsil)) {
//       print('Selected tehsil does not exist in the dropdown');
//       _selectedTehsil = defaultTehsil; // Set to default if not found
//     }
//
//     return DropdownButtonFormField<String>(
//       value: _selectedTehsil , // Use default value if _selectedTehsil is null
//       onChanged: (newValue) {
//         setState(() {
//           _selectedTehsil = newValue!;
//           _selectedBlock = null;
//           _blocksFuture = _fetchBlocks(_selectedDistrict!, _selectedTehsil!);
//           _selectedVillage = null;
//           _villagesFuture = Future.value([]);
//           _registrationData['Tehsil'] = newValue ?? ''; // Provide a default value if newValue is null
//           _registrationData['Block'] = '';
//           _registrationData['Village'] = '';
//         });
//       },
//       items: tehsils.map<DropdownMenuItem<String>>((tehsil) {
//         return DropdownMenuItem<String>(
//           value: tehsil,
//           child: Text(tehsil),
//         );
//       }).toList(),
//       decoration: InputDecoration(
//         labelText: 'Tehsil',
//         border: OutlineInputBorder(),
//       ),
//     );
//   }
//   Widget _buildBlockDropdownButton(List<String> blocks) {
//     if (blocks.isEmpty) {
//       return SizedBox.shrink(); // Hide the village dropdown if no data is available
//     }
//     // Set default block
//     String defaultBlock = _selectedBlock ?? blocks.first;
//
//     // Check if _selectedBlock is among the blocks
//     if (!blocks.contains(_selectedBlock)) {
//       print('Selected block does not exist in the dropdown');
//       _selectedBlock = defaultBlock; // Set to default if not found
//     }
//
//     return DropdownButtonFormField<String>(
//       value: _selectedBlock ?? defaultBlock, // Use default value if _selectedBlock is null
//       onChanged: (newValue) {
//         setState(() {
//           _selectedBlock = newValue!;
//           _selectedVillage = null;
//           _villagesFuture = _fetchVillages(
//               _selectedDistrict!, _selectedTehsil!, _selectedBlock!);
//           _registrationData['Block'] = newValue ?? ''; // Provide a default value if newValue is null
//           _registrationData['Village'] = '';
//         });
//       },
//       items: blocks.map<DropdownMenuItem<String>>((block) {
//         return DropdownMenuItem<String>(
//           value: block,
//           child: Text(block),
//         );
//       }).toList(),
//       decoration: InputDecoration(
//         labelText: 'Block',
//         border: OutlineInputBorder(),
//       ),
//     );
//   }
//
//
//   Widget _buildVillageDropdownButton(List<String> villages) {
//     // Set default village
//     if (villages.isEmpty) {
//       return SizedBox.shrink(); // Hide the village dropdown if no data is available
//     }
//
//     String defaultVillage = _selectedVillage ?? villages.first;
//
//     // Check if _selectedVillage is among the villages
//     if (!villages.contains(_selectedVillage)) {
//       print('Selected village does not exist in the dropdown');
//       _selectedVillage = defaultVillage; // Set to default if not found
//     }
//
//     return DropdownButtonFormField<String>(
//       value: _selectedVillage ?? defaultVillage, // Use default value if _selectedVillage is null
//       onChanged: (newValue) {
//         setState(() {
//           _selectedVillage = newValue!;
//           _registrationData['Village'] = newValue ?? ''; // Provide a default value if newValue is null
//         });
//       },
//       items: villages.map<DropdownMenuItem<String>>((village) {
//         return DropdownMenuItem<String>(
//           value: village,
//           child: Text(village),
//         );
//       }).toList(),
//       decoration: InputDecoration(
//         labelText: 'Village',
//         border: OutlineInputBorder(),
//       ),
//     );
//   }
//
//
//
//
//   }
//
//
