import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:realm/realm.dart';
import '../../../api/auth_api.dart';
import '../../../constants/app_colors.dart';


class SignupOtpVerify extends StatefulWidget {
  final String email;

  final Realm realm;
  final String? deviceToken, deviceType;

  SignupOtpVerify({
    required this.email,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  _SignupOtpVerifyState createState() => _SignupOtpVerifyState();
}

class _SignupOtpVerifyState extends State<SignupOtpVerify> {
  final TextEditingController _otpController = TextEditingController();
  final AuthApi authApi = AuthApi();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    print('Email: ${widget.email}');
    print('Realm: ${widget.realm}');
    print('Device Token: ${widget.deviceToken}');
    print('Device Type: ${widget.deviceType}');
    _otpController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _otpController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _otpController.removeListener(_updateButtonState);
    _otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOTP() async {
    if (!_isButtonEnabled) return;
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

    final response = await authApi.signupverify(
      widget.email,
      otp,
    );

    setState(() {
      _isLoading = false;
    });
print('Signup otp response : $response');
    if (response['status'] == 200) {
      Navigator.pushNamed(
        context,
        '/verified_screen', // Name of your sign-in route

        arguments: {
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

  Future<void> resendOTP() async {

    setState(() {
      _isLoading = true;
    });

    final response = await authApi.resendOTP(
      widget.email,
        widget.deviceToken!,
        widget.deviceType!
    );

    setState(() {
      _isLoading = false;
    });
    print('resend otp response : $response');
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      backgroundColor:  AppColors.primaryWhite,
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
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: TextField(
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Enter the OTP',
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8),

                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40),
                            _isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                              onPressed: verifyOTP,
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: screenRatio * 7,
                                  color: (_isButtonEnabled)
                                      ? AppColors.primaryWhiteText
                                      : AppColors.primaryGreyText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                fixedSize:
                                Size(screenSize.width * 1.0, screenRatio * 26),
                                backgroundColor: _isButtonEnabled
                                    ? AppColors.primaryBlue
                                    : AppColors.primaryGrey,
                                foregroundColor:_isButtonEnabled
                                    ? AppColors.primaryBlue
                                    : AppColors.primaryGrey ,
                                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            SizedBox(height: screenRatio * 8),
                            TextButton(
                              onPressed: () {
                                resendOTP();
                              },

                              child: Text(
                                'Resend OTP ',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: screenRatio * 8,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )))),
    );
  }
}
