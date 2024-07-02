import 'package:app/api_urls.dart';
import 'package:app/home.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:app/SignUp.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';


class RegistrationScreen extends StatefulWidget {

  final Map<String, String> registeredUsers;

  const RegistrationScreen({
    Key? key,
    required this.registeredUsers,
  }) : super(key: key);
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime? _selectedDate;
  TextEditingController _dobController = TextEditingController();
  TextEditingController _aadhaarController = TextEditingController();
  TextEditingController _mobileNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  //String? _selectedRegistrationType;
  String? _selectedRegistrationType = 'farmer';
  late List<Data> _districtList;
  String? _selectedDistrict;
  late List<Tehsil> _tehsilList;
  String? _selectedTehsil;
  late List<Block> _blockList;
  String? _selectedBlock;
  late List<Village> _villageList;
  String? _selectedVillage;

  // late String _password;
  // late String _email;

  List<String> _genderList = ['male'.tr, 'female'.tr, 'other'.tr];
  String? _selectedGender;
  // RegistrationDataSingleton _registrationDataSingleton =
  // RegistrationDataSingleton();

  @override
  void initState() {
    super.initState();
    _districtList = [];
    _tehsilList = [];
    _blockList = [];
    _villageList = [];
    // Initialize _tehsilList
    _fetchDistricts();
  }


  // void showCustomToast(
  //     // BuildContext context,
  //     String message,
  //     String imagePath, {
  //       int duration = 2,
  //     }) {
  //   OverlayEntry? overlayEntry;
  //
  //   // Create a builder function for the overlay entry
  //   OverlayEntry createOverlayEntry() {
  //     return OverlayEntry(
  //       builder: (BuildContext context) {
  //         // Calculate the maximum width for the toast message
  //         double maxWidth = MediaQuery.of(context).size.width * 0.8; // Adjust the fraction as needed
  //         double messageWidth = (message.length * 8.0) + 48.0; // Calculate initial width based on message length
  //
  //         // Ensure that the calculated width does not exceed the maximum width
  //         double finalWidth = messageWidth > maxWidth ? maxWidth : messageWidth;
  //
  //         return Positioned(
  //           bottom: 16.0, // Adjust this value to change the distance from the bottom
  //           left: (MediaQuery.of(context).size.width - finalWidth) / 2, // Center horizontally
  //           child: Material(
  //             color: Colors.transparent,
  //             child: Container(
  //               width: finalWidth, // Set the width of the container
  //               padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
  //               decoration: BoxDecoration(
  //                 color: Colors.black,
  //                 borderRadius: BorderRadius.circular(0.0),
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Image.asset(
  //                     imagePath,
  //                     height: 20,
  //                     width: 20,
  //                     //color: Colors.white,
  //                   ),
  //                   SizedBox(width: 1),
  //                   Text(
  //                     message,
  //
  //                     style: TextStyle(color: Colors.white,),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }
  //
  //   // Show the custom toast overlay
  //   overlayEntry = createOverlayEntry();
  //   Overlay.of(context)?.insert(overlayEntry!);
  //
  //   // Remove the overlay after a specified duration
  //   Future.delayed(Duration(seconds: duration), () {
  //     overlayEntry?.remove();
  //   });
  // }
  void showCustomToast(String message, String imagePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        //webPosition: 'center',
        // behavior: SnackBarBehavior.floating,
        // margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
        duration: Duration(seconds: 2),
        content:
        // FractionallySizedBox(
        //   widthFactor: 0.7, // Adjust the width factor as needed
        //   child:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 24, // Adjust the height as needed
              width: 24, // Adjust the width as needed
              //color: Colors.white, // Optional: Change the color of the image
            ),
            SizedBox(width: 1), // Adjust the spacing between the image and message
            Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 10,),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),

    );
  }



  void registerUser() async
  {
    var url = ApiUrls.registerUrl;
    //var url="http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/farmer/register";
    var data = {
      "email":_emailController.text,
      "password":_passwordController.text,
      "mobile":_mobileNumberController.text,
      "full_name":_nameController.text,
     // "user_name"
      "father_name":_fatherNameController.text,
      "district":_selectedDistrict,
      "tehsil":_selectedTehsil,
      "block":_selectedBlock,
      "village":_selectedVillage,
      // "gender":_selectedGender,
      "gender": _selectedGender == 'male'.tr ? 'm' : _selectedGender == 'female'.tr ? 'f' : 'o',
      "address":_addressController.text,
      "aadhar":_aadhaarController.text,
    };
    var bodyy=json.encode(data);
    var urlParse=Uri.parse(url);
    http.Response response= await http.post(
        urlParse,
        body: bodyy,
        headers: {
          "Content-Type":"application/json"
        }
    );
    var dataa=jsonDecode(response.body);
    print(dataa);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      String message = responseData['message'];
      //showToast(message);
      showCustomToast(message, 'images/wrd_logo.png');
    } else {
      //showCustomToast('Failed to register. Please try again.');
    }
  }

  Future<void> _fetchDistricts() async {
    try {
      List<Data> districts = await fetchData();
      setState(() {
        _districtList = districts;
      });
    } catch (error) {
      print('Error fetching districts: $error');
      // Handle error
    }
  }

  Future<void> _fetchTehsils(String district) async {
    try {
      List<Tehsil> tehsils = await fetchTehsils(district);
      setState(() {
        _tehsilList = tehsils;
      });
    } catch (error) {
      print('Error fetching tehsils: $error');
      // Handle error
    }
  }

  Future<void> _fetchBlocks(String district, String tehsil) async {
    try {
      List<Block> blocks = await fetchBlocks(district, tehsil);
      setState(() {
        _blockList = blocks;
      });
    } catch (error) {
      print('Error fetching blocks: $error');
      // Handle error
    }
  }

  Future<void> _fetchVillages(String district, String tehsil,
      String block) async {
    try {
      List<Village> villages = await fetchVillages(district, tehsil, block);
      setState(() {
        _villageList = villages;
      });
    } catch (error) {
      print('Error fetching villages: $error');
      // Handle error
    }
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
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
          decoration: BoxDecoration(
          image: DecorationImage(
          image: AssetImage('images/i2.jpg'),
      fit: BoxFit.cover,
    ),
    ),
    child: Padding(
    //padding: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.only(
        top: 40, // Adjust the top padding as needed
        right: 16,
        left: 16,
        bottom: 16, // Add padding to the bottom to prevent overflow
      ),
    child: Form( // Wrap your form with Form widget
    key: _formKey,
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Image.asset('images/wrd_logo.png', height: 100),
    SizedBox(width: 10),
    Text(
      'pims'.tr ,
    style: TextStyle(color: Colors.white, fontSize: 25,fontWeight: FontWeight.bold),
    ),

    SizedBox(width: 10),
    Image.asset('images/logo.png', height: 100),
    ],
    ),


    Text(
    'register'.tr,
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,color: Colors.white,
    ),
    ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AbsorbPointer(
                absorbing: false, // Make the child (Radio) clickable
                child: Radio(
                  value: 'farmer',
                  groupValue: _selectedRegistrationType,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedRegistrationType = value;
                      });
                    }
                  },
                ),
              ),
              Text(
                'registration'.tr,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
       Text(
        'Required'.tr,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,color: Colors.red,
        ),
      ),
        ],
      ),

      // Row(
      //   mainAxisAlignment: MainAxisAlignment.start,
      //   children: [
      //     AbsorbPointer(
      //       absorbing: false, // Make the child (Radio) clickable
      //       child: Radio(
      //         value: 'farmer',
      //         groupValue: _selectedRegistrationType,
      //         onChanged: (String? value) {
      //           if (value != null) {
      //             setState(() {
      //               _selectedRegistrationType = value;
      //             });
      //           }
      //         },
      //       ),
      //     ),
      //     Text(
      //       'registration'.tr,
      //       style: TextStyle(
      //         fontSize: 15,
      //         color: Colors.white,
      //       ),
      //     ),
      //   ],
      // ),
      // Container(
      //   margin: EdgeInsets.zero, // Remove any margin
      //   child:Column(
      //   crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
      //   children: [
      // Text(
      //   'Required'.tr,
      //   style: TextStyle(
      //     fontSize: 18,
      //     fontWeight: FontWeight.bold,color: Colors.red,
      //   ),
      // ),
      // ],
      // ),
      // ),
      SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [

      Text(
        'name'.tr+ '*',
        style: TextStyle(color: Colors.white),
      ),

      SizedBox(height: 4),
             //TextField(
                TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'name'.tr+ '*',
                  hintStyle: TextStyle(color: Colors.white),
            filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                prefixIcon: Icon(Icons.person,color: Colors.white,),
                ),

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

      SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
      Text(
        'fathername'.tr+ '*',
        style: TextStyle(color: Colors.white),
      ),

      SizedBox(height: 4),
              //TextField(
          TextFormField(
                controller: _fatherNameController,
                decoration: InputDecoration(
                  hintText: 'fathername'.tr+ '*',
    hintStyle: TextStyle(color: Colors.white),
    filled: true,
    fillColor: Colors.grey.withOpacity(0.2),
    prefixIcon: Icon(Icons.person,color: Colors.white,),
                ),
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
              SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
          Text(
            'Email'.tr+ '*',
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 4),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText:
                  'Email'.tr+ '*',
    hintStyle: TextStyle(color: Colors.white),
    filled: true,
    fillColor: Colors.grey.withOpacity(0.2),
    prefixIcon: Icon(Icons.email,color: Colors.white,),
                ),
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
              SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
          Text(
            'pass'.tr+ '*',
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 4),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText:
                      'pass'.tr+ '*',
               hintStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.2),
              prefixIcon: Icon(Icons.password,color:Colors.white,),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '';
                  }
                  return null;
                },
              ),
              ],
      ),
              SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
          Text(
            'DOB'.tr+ '*',
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
                      hintText: 'DOB'.tr+ '*',
                 hintStyle: TextStyle(color: Colors.white),
                    filled: true,
                   fillColor: Colors.grey.withOpacity(0.2),
                      prefixIcon: Icon(Icons.calendar_month,color: Colors.white,),
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
              ),
              ],
      ),
              SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
          Text(
            'Aadhar'.tr+ '*',
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 4),
              TextFormField(
                controller: _aadhaarController,
                decoration: InputDecoration(
                  hintText:'Aadhar'.tr+ '*',

    hintStyle: TextStyle(color: Colors.white),
    filled: true,
    fillColor: Colors.grey.withOpacity(0.2),
    prefixIcon: Icon(Icons.format_list_numbered_sharp,color: Colors.white,),
                ),
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
              SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
          Text(
            'Mobile No'.tr+ '*',
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 4),
              TextFormField(
                controller: _mobileNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Mobile No'.tr+ '*',
    hintStyle: TextStyle(color: Colors.white),
    filled: true,
    fillColor: Colors.grey.withOpacity(0.2),
    prefixIcon: Icon(Icons.call,color: Colors.white,),
                ),
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
      SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
          Text(
        'District'.tr+ '*',
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _selectedDistrict,
          dropdownColor: Colors.black,
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.grey.withOpacity(0.3),
            hintStyle: TextStyle(color: Colors.white),


          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child:
              Text(
                'District'.tr+ '*', // Assuming 'tr' is a localization function
                style: TextStyle(color: Colors.white),
              ),

            ),
            ..._districtList.map((Data district) {
              return DropdownMenuItem<String>(
                value: district.district,

                child: Text(district.district,style: TextStyle(color: Colors.white),),
              );
            }).toList(),

          ],
          onChanged: (String? value) {
            setState(() {
              _selectedDistrict = value;
              _selectedTehsil = null;
              _selectedBlock = null;
              _selectedVillage = null;
              _fetchTehsils(_selectedDistrict!);
            });
          },
          validator: (value) {
            if (value == null) {
              return '';
            }
            return null;
          },
        ),
      ],
      ),

      SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
          Text(
            'Tehsil'.tr+ '*',
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 4),
        DropdownButtonFormField<String>(
        value: _selectedTehsil,
          dropdownColor: Colors.black,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Tehsil'.tr+ '*', // You can use localization here if needed
          hintStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.3),
        ),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              'Tehsil'.tr+'*', // Assuming 'tr' is a localization function
              style: TextStyle(color: Colors.white),
            ),
          ),
          ..._tehsilList.map((Tehsil tehsil) {
            return DropdownMenuItem<String>(
              value: tehsil.tehsil,
              child: Text(tehsil.tehsil, style: TextStyle(color: Colors.white),),
            );
          }).toList(),
        ],
        onChanged: (String? value) {
          setState(() {
            _selectedTehsil = value;
            _selectedBlock = null;
            _selectedVillage = null;
            _fetchBlocks(_selectedDistrict!, _selectedTehsil!);
          });
        },
          validator: (value) {
            if (value == null) {
              return '';
            }
            return null;
          },
      ),
      // ),
          ],
      ),


      SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
          Text(
            'Block'.tr+ '*',
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 4),
        DropdownButtonFormField<String>(
        value: _selectedBlock,
          dropdownColor: Colors.black,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Block'.tr+ '*', // You can use localization here if needed
          hintStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.3),
        ),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              'Block'.tr+'*', // Assuming 'tr' is a localization function
              style: TextStyle(color: Colors.white),
            ),
          ),
          ..._blockList.map((Block block) {
            return DropdownMenuItem<String>(
              value: block.block,
              child: Text(block.block, style: TextStyle(color: Colors.white),),
            );
          }).toList(),
        ],
        onChanged: (String? value) {
          setState(() {
            _selectedBlock = value;
            _selectedVillage = null;
            _fetchVillages(_selectedDistrict!, _selectedTehsil!, _selectedBlock!);
          });
        },
          validator: (value) {
            if (value == null) {
              return '';
            }
            return null;
          },
      ),
      ],
      ),

      SizedBox(height: 16),

      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
          Text(
            'Village'.tr+ '*',
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 4),
      DropdownButtonFormField<String>(
        value: _selectedVillage,
        dropdownColor: Colors.black,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Village'.tr+ '*', // You can use localization here if needed
          hintStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.3),
        ),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              'Village'.tr+'*', // Assuming 'tr' is a localization function
              style: TextStyle(color: Colors.white),
            ),
          ),
          ..._villageList.map((Village village) {
            return DropdownMenuItem<String>(
              value: village.village,
              child: Text('${village.village} (${village.hadbastNo})', style: TextStyle(color: Colors.white),),
            );
          }).toList(),
        ],
        onChanged: (String? value) {
          setState(() {
            _selectedVillage = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return '';
          }
          return null;
        },
      ),
      ],
       ),

      SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
          Text(
            'Address'.tr+ '*',
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 4),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText:
                       'Address'.tr+ '*',
    hintStyle: TextStyle(color: Colors.white),
    filled: true,
    fillColor: Colors.grey.withOpacity(0.2),
    prefixIcon: Icon(Icons.home,color: Colors.white,),
                ),
                validator: (value) {
                  if (value == null) {
                    return '';
                  }
                  return null;
                },
              ),
      ],
      ),

      SizedBox(height: 32),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
          Text(
            'gender'.tr+ '*',
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 4),
      DropdownButtonFormField<String>(
        value: _selectedGender,
        dropdownColor: Colors.black,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'gender'.tr+ '*',
          hintStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.3),
        ),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              'gender'.tr+'*',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ..._genderList.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender.tr,style: TextStyle(color: Colors.white),),
            );
          }).toList(),
        ],
        onChanged: (String? value) {
          setState(() {
            _selectedGender = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return '';
          }
          return null;
        },
      ),
      ],
      ),


      SizedBox(height: 32),
      Container(
        width: double.infinity,
        child:ElevatedButton(
                onPressed: () {
    if (_formKey.currentState!.validate()) {
    registerUser();
    }

                //showToast(context, 'Your message here', 'assets/icon.png');
                  },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0), // Adjust the radius as needed
            ),// Text color
          ),
                child: Text(
                    'sign up'.tr.toUpperCase(),
                 ),
              ),
      ),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center, // Align children at the center horizontally
        children: [
          Text(
            'Already have account'.tr,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
              SizedBox(height: 16),
      Center(
        child: Container(
          //width: double.infinity,
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.purple), // Add border
          //   borderRadius: BorderRadius.circular(8), // Add border radius
          // ),
          child: ElevatedButton(
            onPressed: () {
              // Navigate to the Sign In screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(title: 'prsc'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.purple, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0), // Adjust border radius
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // Add padding
              child: Text(
                'sign'.tr.toUpperCase(),
                textAlign: TextAlign.center, // Center align the text
              ),
            ),
          ),
        ),
      ),

      // TextButton(
              //   onPressed: () {
              //     // Navigate to the Sign In screen
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => MyHomePage(title:'prsc'),
              //       ),
              //     );
              //   },
              //   child: Text(
              //      'sign'.tr),
              // ),
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }
}

Future<List<Data>> fetchData() async {
  var url = Uri.parse(ApiUrls.districtUrl);
  // var url = Uri.parse(
  //     'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/district');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    // Parse the response
    Map<String, dynamic> jsonResponse = json.decode(response.body);

    // Extract the "data" field
    List<dynamic> data = jsonResponse['data'];

    // Map the contents of "data" to your Data class
    List<Data> dataList =
    data.map((item) => Data.fromJson(item)).toList();

    return dataList;
  } else {
    throw Exception('Unexpected error occurred!');
  }
}

Future<List<Tehsil>> fetchTehsils(String district) async {
  var url = Uri.parse('${ApiUrls.tehsilUrl}?district=$district');
  // var url = Uri.parse(
  //     'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/tehsil?district=$district');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    // Parse the response
    Map<String, dynamic> jsonResponse = json.decode(response.body);

    // Extract the "data" field
    List<dynamic> data = jsonResponse['data'];

    // Map the contents of "data" to your Tehsil class
    List<Tehsil> tehsilList =
    data.map((item) => Tehsil.fromJson(item)).toList();

    return tehsilList;
  } else {
    throw Exception('Unexpected error occurred!');
  }
}
Future<List<Block>> fetchBlocks(String district, String tehsil) async {
  var url = Uri.parse('${ApiUrls.blockUrl}?district=$district&tehsil=$tehsil');
  // var url = Uri.parse(
  //     'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/block?district=$district&tehsil=$tehsil');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> data = jsonResponse['data'];
    List<Block> blockList =
    data.map((item) => Block.fromJson(item)).toList();
    return blockList;
  } else {
    throw Exception('Unexpected error occurred!');
  }
}

Future<List<Village>> fetchVillages(String district, String tehsil, String block) async {
  var url = Uri.parse('${ApiUrls.villageUrl}?district=$district&tehsil=$tehsil&block=$block');
 //  var url = 'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/village?district=$district&tehsil=$tehsil&block=$block';
   final response = await http.get(url);

  // final response = await http.get(
  //    'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/village?district=$district&tehsil=$tehsil&block=$block');
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> data = jsonResponse['data'];
    List<Village> villageList = data.map((item) => Village.fromJson(item)).toList();
    return villageList;
  } else {
    throw Exception('Unexpected error occurred!');
  }
}

class Data {
  final String id;
  final String district;

  Data({required this.id, required this.district});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      district: json['district'],
    );
  }
}

class Tehsil {
  final String district;
  final String tehsil;

  Tehsil({required this.district, required this.tehsil});

  factory Tehsil.fromJson(Map<String, dynamic> json) {
    return Tehsil(
      district: json['district'],
      tehsil: json['tehsil'],
    );
  }
}
class Block {
  final String district;
  final String tehsil;
  final String block;

  Block({required this.district, required this.tehsil, required this.block});

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      district: json['district'],
      tehsil: json['tehsil'],
      block: json['block'],
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
