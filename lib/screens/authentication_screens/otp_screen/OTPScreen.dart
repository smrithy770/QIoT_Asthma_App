import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import '../../../api/auth_api.dart';
import '../reset_password/reset_password.dart';

class OTPScreen extends StatefulWidget {
  final String email;

  final Realm realm;
  final String? deviceToken, deviceType;

  OTPScreen({required this.email,
  required this.realm,
    required this.deviceToken,
    required this.deviceType,

  });


  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthApi authApi = AuthApi();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('Email: ${widget.email}');
    print('Realm: ${widget.realm}');
    print('Device Token: ${widget.deviceToken}');
    print('Device Type: ${widget.deviceType}');
  }


  Future<void> verifyOTP() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await authApi.verifyOTP(widget.email,otp,);

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 200) {
      // Navigate to ResetPasswordScreen and pass OTP
    /*  Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: widget.email, accessToken: '',
            'realm': widget.realm,
            'deviceToken': widget.deviceToken,
            'deviceType': widget.deviceType,
          ),
        ),
      );*/
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/reset_password', // Name of your sign-in route
            (Route<dynamic> route) => false,
        arguments: {
          'email': widget.email, // Adding the email
          'accessToken': '',
          'realm': widget.realm,
          'deviceToken': widget.deviceToken ?? '', // Fallback to an empty string
          'deviceType': widget.deviceType ?? '', // Fallback to an empty string
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter the OTP',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: verifyOTP,
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
