import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:realm/realm.dart';
import '../../../api/auth_api.dart';
import '../../../constants/app_colors.dart';
import '../reset_password/reset_password.dart';

class OTPScreen extends StatefulWidget {
  final String email;

  final Realm realm;
  final String? deviceToken, deviceType;

  OTPScreen({
    required this.email,
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
  final _formKey = GlobalKey<FormState>();

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

    final response = await authApi.verifyOTP(
      widget.email,
      otp,
    );

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
      Navigator.pushNamed(
        context,
        '/reset_password', // Name of your sign-in route

        arguments: {
          'email': widget.email, // Adding the email
          'accessToken': '',
          'realm': widget.realm,
          'deviceToken':
          widget.deviceToken ?? '', // Fallback to an empty string
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
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenRatio * 20),
                      SvgPicture.asset(
                        'assets/svgs/user_assets/logo.svg', // Optional logo
                        width: screenRatio * 52,
                      ),
                      SizedBox(height: screenRatio * 44),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Text(
                              'Enter the OTP',
                              style: TextStyle(
                                color: AppColors.primaryBlueText,
                                fontSize: screenRatio * 9,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
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
                    ],
                  )))),
    );
  }
}
