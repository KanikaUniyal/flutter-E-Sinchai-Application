import 'dart:convert';
import 'dart:math';
import 'package:app/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  late TextEditingController _emailController;
  late String _emailLabelText;
  late String _generateOTPButtonText;
  late String _emailError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailLabelText = LanguagePreferences.isEnglish ? 'Email' : 'ਈ - ਮੇਲ';
    _generateOTPButtonText =
    LanguagePreferences.isEnglish ? 'Generate OTP' : 'ਓਟੀਪੀ ਬਣਾਓ';
    _emailError = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguagePreferences.isEnglish
            ? 'Forget Password'
            : 'ਪਾਸਵਰਡ ਭੁੱਲ ਗਏ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LanguagePreferences.isEnglish
                  ? 'Enter your email to receive OTP:'
                  : 'ਆਪਣਾ ਈਮੇਲ ਦਰਜ ਕਰੋ ਓਟੀਪੀ ਪ੍ਰਾਪਤ ਕਰਨ ਲਈ:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              decoration: InputDecoration(
                labelText: _emailLabelText,
                border: OutlineInputBorder(),
                errorText: _emailError.isNotEmpty ? _emailError : null,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Reset error message
                setState(() {
                  _emailError = '';
                });

                // Validate email before generating OTP
                String email = _emailController.text;
                if (!_isValidEmail(email)) {
                  setState(() {
                    _emailError = LanguagePreferences.isEnglish?'Invalid email address':'ਗਲਤ ਈਮੇਲ ਪਤਾ';
                  });
                  return;
                }

                // Generate and send OTP logic here
                String generatedOTP = generateOTP();

                // Send email with OTP
                await sendEmail(email, generatedOTP);

                // Show the OTP and verify it through an API
                _showOTPDialog(generatedOTP, email);

                print('Generated OTP: $generatedOTP');
                print('Email sent to: $email');
              },
              child: Text(_generateOTPButtonText),
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    // Use a regular expression for basic email validation
    final RegExp emailRegExp =
    RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  String generateOTP() {
    // Define the length of the OTP
    int otpLength = 6;

    // Generate a random OTP
    String otp = '';
    for (int i = 0; i < otpLength; i++) {
      otp += Random().nextInt(10).toString();
    }

    return otp;
  }

  Future<void> sendEmail(String recipient, String otp) async {
    final smtpServer = gmail('your.email@gmail.com', 'your-password');

    // Create the message
    final message = Message()
      ..from = Address('your.email@gmail.com', 'Your Name')
      ..recipients.add(recipient)
      ..subject = 'OTP for Password Reset'
      ..text = 'Your OTP is: $otp';

    // Send the message
    try {
      await send(message, smtpServer);
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  Future<void> _showOTPDialog(String otp, String email) async {
    // Display a loading indicator while making the API call
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verifying OTP...'),
          content: CircularProgressIndicator(),
        );
      },
    );

    // Make API call to verify OTP
    final apiUrl = 'https://your-api-endpoint.com/verify_otp';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'email': email, 'otp': otp},
    );

    // Close the loading dialog
    Navigator.of(context).pop();

    // Handle the API response
    if (response.statusCode == 200) {
      // Successful response, handle accordingly
      print('API Response: ${response.body}');
    } else {
      // Handle error
      print('API Error: ${response.statusCode}');
    }

    // Show the OTP in the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Generated OTP'),
          content: Text('Your OTP is: $otp'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ForgetPassword(),
  ));
}
