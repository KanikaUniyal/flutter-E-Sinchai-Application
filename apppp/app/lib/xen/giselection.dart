import 'package:app/api_urls.dart';
import 'package:app/home.dart';
import 'package:app/xen/mainxen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
// void main() => runApp(MyApp());
class giselection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GIS Election',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHome> {
  List<String> districtList = [];
  List<String> acList = [];
  String selectedDistrict = '';
  String selectedAc = '';
  String webviewHtml = '';
  late WebViewController? webView;
  String userName = ''; // Variable to hold the user's name
  String userType = '';

  @override
  void initState() {
    super.initState();
    fetchDistrict();
    _getUserData();
    webviewHtml = osmMap();
    // Add default values to dropdowns
    districtList = ["--Select District--".tr];
    selectedDistrict = districtList.first;

    acList = ["--Select Assembly Constituency--".tr];
    selectedAc = acList.first;
  }

  // // Method to initialize webView
  // void initializeWebView() {
  //   webView = WebViewController.fromWebView(WebView());
  // }
  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userData_userName') ?? "";
    userType = prefs.getString('userData_userType') ?? "";
    setState(() {});
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
        //showCustomToast(context, message, 'images/wrd_logo.png');


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
        child:Scaffold(
          appBar: XenCustomAppBar(logoutCallback: _logout, userType: userType,
          ),
          drawer: XenCustomDrawer(
            userName: userName,
            userType: userType,
          ),
          body: Stack(
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
                  // Dropdowns (moved to the top)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          buildDropdown('District', districtList, selectedDistrict,
                                  (value) {
                                setState(() {
                                  selectedDistrict = value!;
                                  selectedAc = '--Select Assembly Constituency--'.tr;
                                  DistrictZoom(selectedDistrict);
                                  acList.clear();
                                  fetchAc(); // Fetch villages based on the selected LPA
                                });
                              }),
                          buildDropdown('AC', acList, selectedAc, (value) {
                            setState(() {
                              selectedAc = value!;
                              AcZoom(selectedAc);
                            });
                          }),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: WebView(
                      initialUrl: Uri.dataFromString(webviewHtml,
                          mimeType: 'text/html',
                          encoding: Encoding.getByName('utf-8'))
                          .toString(),
                      onWebViewCreated: (controller) {
                        webView = controller;
                        // Load HTML content into WebView when it's created
                      },
                      javascriptMode: JavascriptMode.unrestricted,
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

  Widget buildDropdown(String label, List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*SizedBox(height: 10),
        Text('Select $label:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),*/
        SizedBox(height: 5),
        Container(
          // Wrap the DropdownButton with a Container
          width: double.infinity, // Set the width to match the parent's width
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              dropdownColor: Colors.black,
              value: selectedValue,
              onChanged: onChanged,
              // isDense: true, // Set isDense to reduce padding around dropdown items
              underline: Container(), // Remove the underline
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item,style: TextStyle(color: Colors.white),),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> fetchDistrict() async {
    try {
      final response = await http.get(Uri.parse(
          'http://202.164.39.164:8084/election/fetch_district.php'));

      final jsonResponse = json.decode(response.body);
      print('API Response: $jsonResponse');
      final studentArray = jsonResponse['District'];
      // final List<String> lpaNames = ['-- Select LPA --']; // Placeholder option
      print("studentArray,$studentArray");
      final List<String> districtNames = ['--Select District--'.tr];

      for (var student in studentArray) {
        final distName = student['district'];
        print("districtName, $distName");
        districtNames.add(distName);
      }

      setState(() {
        districtList = districtNames;
        selectedDistrict = districtNames.isNotEmpty ? districtNames.first : '';
      });
    } catch (error) {
      print('Error fetching lpa: $error');
    }
  }

  Future<void> DistrictZoom(String districtName) async {
    print('APIResponsedz');

    try {
      final response = await http.post(
        Uri.parse('http://202.164.39.164:8084/election/fetch_latlong_district.php'),
        body: {
          'Selecteddistrict': districtName, // Ensure correct spelling
        },
      );

      // Log the raw response body
      print('Raw response: ${response.body}');

      try {
        final jsonResponse = json.decode(response.body);
        print('APIResponsedz: $jsonResponse');

        final studentArray = jsonResponse['Student'];
        print("studentArraydz,$studentArray");

        for (var student in studentArray) {
          final distNamee = student['district'];
          final lattii = student['lat'];
          final longgii = student['longi'];
          print("districtNamedz, $distNamee, $lattii, $longgii");
          webView?.evaluateJavascript("zoomToDistrict($lattii , $longgii)");
        }
      } catch (jsonError) {
        print('Error decoding JSON: $jsonError');
      }
    } catch (error) {
      print('Error fetching district zoom: $error');
    }
  }

  Future<void> fetchAc() async {
    try {
      final response = await http.post(
          Uri.parse('http://202.164.39.164:8084/election/fetch_assemblyconstituency.php'),
          body: {'district': selectedDistrict});

      final jsonResponse = json.decode(response.body);
      final studentArray = jsonResponse['ac'];
      final List<String> acNames = ['--Select Assembly Constituency--'.tr];

      for (var student in studentArray) {
        final acName = student['ac'];
        if (acName != null && acName.isNotEmpty) {
          acNames.add(acName);
        }
      }

      setState(() {
        acList = acNames;
        selectedAc = acNames.isNotEmpty ? acNames.first : '';
      });
    } catch (error) {
      print('Error fetching ac: $error');
    }
  }

  Future<void> AcZoom(String tehsilName) async {
    print('APIResponsedz');

    try {
      final response = await http.post(
        Uri.parse('http://202.164.39.164:8084/election/fetch_latlong_ac.php'),
        body: {
          'Selectedac': selectedAc
        },
      );

      // Log the raw response body
      print('Raw response: ${response.body}');

      try {
        final jsonResponse = json.decode(response.body);
        print('APIResponsedz: $jsonResponse');

        final studentArray = jsonResponse['Student'];
        print("studentArraydz,$studentArray");

        for (var student in studentArray) {
          final acNamee = student['ac'];
          final lattii = student['lat'];
          final longgii = student['longi'];
          print("districtNamedz, $acNamee, $lattii, $longgii");
          webView?.evaluateJavascript("zoomToAC($lattii , $longgii)");
        }
      } catch (jsonError) {
        print('Error decoding JSON: $jsonError');
      }
    } catch (error) {
      print('Error fetching ac zoom: $error');
    }
  }

}

String osmMap() {
  return "<!DOCTYPE html>\n" +
      "<html>\n" +
      "<head>\n" +
      "  <title>OpenLayers WMS Layer Example</title> \n" +
      "  <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/ol@latest/dist/ol.css\" />\n" +
      "<script src=\"https://code.jquery.com/jquery-3.6.0.min.js\"></script>\n" +
      "    <style>\n" +
      "        #zoom-controls {\n" +
      "            position: absolute;\n" +
      "            top: 10px;\n" +
      "            left: 10px;\n" +
      "            z-index: 1000;\n" +
      "        }\n" +
      "        /* Style for the custom overlay */\n" +
      "        .ol-popup {\n" +
      "            position: absolute;\n" +
      "            background-color: white;\n" +
      "            box-shadow: 0 1px 4px rgba(0, 0, 0, 0.2);\n" +
      "            padding: 10px;\n" +
      "            border: 1px solid #ccc;\n" +
      "            max-width: 300px;\n" +
      "        }\n" +
      "        .ol-popup-closer {\n" +
      "            position: absolute;\n" +
      "            top: 0;\n" +
      "            right: 0;\n" +
      "            padding: 5px;\n" +
      "            cursor: pointer;\n" +
      "        }\n" +
      "        /* Style for the vertical table */\n" +
      "        .vertical-table {\n" +
      "            display: flex;\n" +
      "            flex-direction: column;\n" +
      "        }\n" +
      "        .vertical-table table {\n" +
      "            border-collapse: collapse;\n" +
      "            width: 100%;\n" +
      "        }\n" +
      "        .vertical-table th, .vertical-table td {\n" +
      "            text-align: left;\n" +
      "            padding: 8px;\n" +
      "            border-bottom: 1px solid #ddd;\n" +
      "        }\n" +
      "        .vertical-table th {\n" +
      "            background-color: #f2f2f2;\n" +
      "        }\n" +
      "        /* Add this CSS style for the close button */\n" +
      "        .popup-close-button {\n" +
      "            position: absolute;\n" +
      "            top: 5px;\n" +
      "            right: 10px;\n" +
      "            font-size: 20px;\n" +
      "            cursor: pointer;\n" +
      "        }\n" +
      "        .popup-close-button:hover {\n" +
      "            color: red;\n" +
      "        }\n" +
      "    </style>\n" +
      "</head>\n" +
      "<body>\n" +
      "<div id=\"map\" style=\"width: 100%; height: 1000px;\"></div>\n" +
      "  <script src=\"https://cdn.jsdelivr.net/npm/ol@latest/dist/ol.js\"></script>\n" +
      "  <script>\n" +
      " var latitude, longitude; \n" + // Declare latitude and longitude globally
      "var baseMapLayer = new ol.layer.Tile({\n" +
      "    source: new ol.source.OSM()\n" +
      "});\n" +
      "var District_Boundary = new ol.layer.Tile({\n" +
      "    title: \"district_boundary\",\n" +
      "    source: new ol.source.TileWMS({\n" +
      "        url: 'https://punjabgis.punjab.gov.in:8085/geoserver/GOP/wms',\n" +
      "        crossOrigin: null,\n" +
      "        params: {\n" +
      "            layers: 'pb_district',\n" +
      "            'TILED': false, transparent: true, visibility: true, isBaseLayer: true,\n" +
      "            buffer: 0\n" +
      "        }\n" +
      "    }),\n" +
      "    showLegend: true,\n" +
      "    serverType: 'geoserver',\n" +
      "    transition: 0,\n" +
      "    name: 'District_Boundary'\n" +
      "});\n" +
      "var Tehsil_Boundary = new ol.layer.Tile({\n" +
      "    title: \"tehsil_boundary\",\n" +
      "    source: new ol.source.TileWMS({\n" +
      "        url: 'https://punjabgis.punjab.gov.in:8085/geoserver/GOP/wms',\n" +
      "        crossOrigin: null,\n" +
      "        params: {\n" +
      "            layers: 'dwss_ac_bound',\n" +
      "            'TILED': false, transparent: true, visibility: true, isBaseLayer: true,\n" +
      "            buffer: 0\n" +
      "        }\n" +
      "    }),\n" +
      "    showLegend: true,\n" +
      "    serverType: 'geoserver',\n" +
      "    transition: 0,\n" +
      "    name: 'Tehsil_Boundary'\n" +
      "});\n" +
      "var map = new ol.Map({\n" +
      "    target: 'map',\n" +
      "    layers: [\n" +
      "        baseMapLayer,\n" +
      "        District_Boundary, // CM Status \n" +
      "        Tehsil_Boundary // CM Status \n" +
      "    ],\n" +
      "    view: new ol.View({\n" +
      "        center: ol.proj.fromLonLat([75.85733, 30.90054]),\n" +
      "        zoom: 7,\n" +
      "    }),\n" +
      "});\n" +
      "function zoomToDistrict(lattii, longgii) {\n" +
      "    var view = map.getView();\n" +
      "    view.setCenter(ol.proj.fromLonLat([parseFloat(longgii), parseFloat(lattii)]));\n" +
      "    view.setZoom(11);\n" +
      "}\n" +
      "function zoomToAC(lattii, longgii) {\n" +
      "    var view = map.getView();\n" +
      "    view.setCenter(ol.proj.fromLonLat([parseFloat(longgii), parseFloat(lattii)]));\n" +
      "    view.setZoom(13);\n" +
      "}\n" +
      "  </script>\n" +
      "</body>\n" +
      "</html>\n";
}