import 'dart:convert';
import 'package:app/api_urls.dart';
import 'package:app/home.dart';
import 'package:app/xen/delayjustification.dart';
import 'package:app/xen/mainxen.dart';
import 'package:http/http.dart'as http;
import 'package:app/farmer/totalapplicationfarmer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/farmer/mainfarmer.dart';

class delaydetailspage extends StatefulWidget {
  final Farmerz farmer;

  const delaydetailspage({Key? key, required this.farmer}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<delaydetailspage> {
  late Map<String, dynamic> applicationDetails = {};
  late String userName = ''; // Initialize with empty string
  late String userType = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  Future<void> fetchData() async {
    // final String apiUrl = 'http://202.164.39.164:8084/wrd_api/sumit_wrd_api/public/application/details';
    final String apiUrl = ApiUrls.applicationDetails;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String sessionKey = prefs.getString('userData_sessionKey') ?? '';
    userName = prefs.getString('userData_fullName') ?? '';
    userType = prefs.getString('userData_userType') ?? '';

    //final String sessionKey = 'f8329dce150599ba7ae97b4f053693cb9464d2723bb620ab38457c458eb8f8b2';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_key': sessionKey, 'id': widget.farmer.id}),
      );

      if (response.statusCode == 200) {
        setState(() {
          applicationDetails = jsonDecode(response.body)['data'];
        });
      } else {
        throw Exception('Failed to load application details');
      }
    } catch (error) {
      print('Error fetching data: $error');
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
    //List<dynamic> applicationTransactions = applicationDetails['application_transactions'];
    List<dynamic>? applicationTransactions = applicationDetails['application_transactions'];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          // Navigate to mainxenpage when back button is pressed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Mz()),
          );
          return false;
        },
        child:
        Scaffold(

          appBar: XenCustomAppBar(logoutCallback: _logout, userType: userType,

            // Access ScaffoldState and open drawer
          ),
          drawer: XenCustomDrawer(
            userName: userName,
            userType: userType,
          ),
          body: Stack(
            children: [
              // Background image
              Image.asset(
                'images/i2.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              SingleChildScrollView(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.all(16.0),
                    padding: EdgeInsets.all(16.0),
                    //width: 1000,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.19),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    // padding: const EdgeInsets.all(16.0),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Request ID: ${widget.farmer.id}'),
                            SizedBox(width: 1), // Add horizontal space
                            Text('Request Date: ${widget.farmer.created_date}'),
                          ],
                        ),

                        Text('Application Type: ${widget.farmer.application_type}'),
                        Text('Nature of Application: ${widget.farmer.nature_of_application}'),
                        Row( // Adjusted this section to add space between Outlet and Patwari Name
                          children: [
                            Text('Outlet: ${widget.farmer.outlet}'),
                            SizedBox(width: 20), // Add horizontal space
                            Text('Patwari Name: ${widget.farmer.patwari_name}'),
                          ],
                        ),
                        Row( // Adjusted this section to add space between Outlet and Patwari Name
                          children: [
                            Text('District: ${widget.farmer.district}'),
                            SizedBox(width: 20),
                            Text('Tehsil: ${widget.farmer.tehsil}'),
                          ],
                        ),
                        Row( // Adjusted this section to add space between Outlet and Patwari Name
                          children: [
                            Text('Block: ${widget.farmer.block}'),
                            SizedBox(width: 20),
                            Text('Water Channel: ${widget.farmer.water_channel} '),
                          ],
                        ),
                        Row( // Adjusted this section to add space between Outlet and Patwari Name
                          children: [
                            Text('Acreage of Land: ${widget.farmer.acerage_of_land}'),
                            SizedBox(width: 20),
                            Text('Mustil No: ${widget.farmer.mustil_no} '),
                          ],
                        ),
                        // Text('Acreage of Land: ${widget.farmer.acerage_of_land}               Mustil No: ${widget.farmer.mustil_no}'),
                        Text('Killa No: ${widget.farmer.killa_no}'),
                        Text('Reason: ${widget.farmer.reason}'),
                        Text('Village: ${widget.farmer.village}'),
                        // Text('village:${widget.farmer.jamabandi}'),

                        // Text('Status: ${widget.farmer.status}'),
                        // Text('Status Remarks: ${widget.farmer.status_remarks}'),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildStatusButton('Pending', 'pending', 'Pending '),
                            buildStatusButton('Rejected', 'rejected', 'Deadline Exceed'),
                            buildStatusButton('Approved', 'approved', 'Completed on time '),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity, // Button width covers the whole screen
                          child: ElevatedButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.purple), // Set button color to purple
                            ),
                            child: Text('Application Status',style: TextStyle(color: Colors.black),),
                          ),
                        ),

                        SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          padding: EdgeInsets.all(16.0),
                          width: double.infinity,
                          // height: 900,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //   Text(
                                //   'Status Remarks:',
                                //   style: TextStyle(
                                //     fontWeight: FontWeight.bold,
                                //     fontSize: 16,
                                //   ),
                                // ),

                                // Display the buttons vertically near the "Forward" text

                                SizedBox(height: 20),
                                // Display other information as before

                                SizedBox(height: 10),


                                // if (applicationTransactions != null)
                                // for (var i = applicationTransactions.length - 1; i >= 0; i--)
                                //
                                // Text(
                                // '${applicationTransactions.length - i}) ${applicationTransactions[i]['request_flow'] == 'forward' ? 'Forward to' : 'Sent to'} ${applicationTransactions[i]['request_send_to_full_name']} (${applicationTransactions[i]['request_send_to_user_type']}) (${widget.farmer.status ?? ''})\n Date: ${applicationTransactions[i]['created_date'] ?? ''}, Timeline: ${applicationTransactions[i]['timeline_days'] ?? ''}, Pending Days:${applicationTransactions[i]['pending_days'] ?? ''}, Expected End Date: ${applicationTransactions[i]['expected_end_date'] ?? ''} \n\n Action on request Details \n\n Date: ${applicationTransactions[i]['created_date'] ?? ''}\n Status: ${applicationTransactions[i]['request_approve_status'] ?? ''}\n Remarks:${applicationTransactions[i]['request_approve_remarks'] ?? ''}',
                                // style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
                                // ),
                                //         Column(
                                //           crossAxisAlignment: CrossAxisAlignment.start,
                                //           children: [
                                //             if (applicationTransactions != null)
                                //               for (var i = applicationTransactions.length - 1; i >= 0; i--)
                                //                 Row(
                                //                   crossAxisAlignment: CrossAxisAlignment.start,
                                //                   children: [
                                //                     buildStatusButton('', applicationTransactions[i]['request_approve_status'] ?? '', ''),
                                //                     Expanded(
                                //                       child: Text(
                                //                         '${applicationTransactions.length - i}) ${applicationTransactions[i]['request_flow'] == 'forward' ? 'Forward to' : 'Sent to'} ${applicationTransactions[i]['request_send_to_full_name']} (${applicationTransactions[i]['request_send_to_user_type']}) (${widget.farmer.status ?? ''})\n Date: ${applicationTransactions[i]['created_date'] ?? ''}, Timeline: ${applicationTransactions[i]['timeline_days'] ?? ''}, Pending Days:${applicationTransactions[i]['pending_days'] ?? ''}, Expected End Date: ${applicationTransactions[i]['expected_end_date'] ?? ''} \n\n Action on request Details \n\n Date: ${applicationTransactions[i]['created_date'] ?? ''}\n Status: ${applicationTransactions[i]['request_approve_status'] ?? ''}\n Remarks:${applicationTransactions[i]['request_approve_remarks'] ?? ''}',
                                //                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                //                       ),
                                //                     ),
                                //                   ],
                                //                 ),
                                //           ],
                                //         ),

                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (applicationTransactions != null)
                                        for (var i = applicationTransactions.length - 1; i >= 0; i--)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${applicationTransactions.length - i}) ${applicationTransactions[i]['request_flow'] == 'forward' ? 'Forward to' : 'Sent to'} ${applicationTransactions[i]['request_send_to_full_name']} (${applicationTransactions[i]['request_send_to_user_type']}) (${widget.farmer.status ?? ''})\n Date: ${applicationTransactions[i]['created_date'] ?? ''}, Timeline: ${applicationTransactions[i]['timeline_days'] ?? ''}, Pending Days:${applicationTransactions[i]['pending_days'] ?? ''}, Expected End Date: ${applicationTransactions[i]['expected_end_date'] ?? ''}',
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              SizedBox(height: 10),
                                              buildStatusButton('', applicationTransactions[i]['request_approve_status'] ?? '', ''),
                                              SizedBox(height: 10),
                                              Text(
                                                'Action on request Details',
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Date: ${applicationTransactions[i]['created_date'] ?? ''}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              Text(
                                                'Status: ${applicationTransactions[i]['request_approve_status'] ?? ''}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              Text(
                                                'Remarks: ${applicationTransactions[i]['request_approve_remarks'] ?? ''}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                    ],
                                  ),
                                ),








                                SizedBox(height: 10),
                                Text(
                                  ' (${widget.farmer.status ?? ''})',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  ' Date: ${widget.farmer.created_date ?? ''}',
                                  style: TextStyle(fontSize: 14),
                                ),

                                SizedBox(height: 10),
                                Column(
                                  children: [
                                    buildStatusButtonVertical(widget.farmer.status),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
  Widget buildStatusButtonVertical(String status) {
    return Column(
      children: [
        buildStatusButton('', status, ''),
      ],
    );
  }
  Widget buildStatusButton(
      String buttonText, String status, String additionalData) {
    return Column(
      children:[
        SizedBox(
          width: 100,
          height: 10,
          child: ElevatedButton(
            onPressed: () {
              // Handle button tap
            },
            style: getStatusButtonStyle(status),
            child: Text(''), // Empty button text
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
        buttonColor =
            Colors.grey; // Default color, you can change it as needed
    }

    return ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      minimumSize: Size(200, 1),
    );
  }
}
