import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:realm/realm.dart';

import '../../../api/auth_api.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String accessToken;
  final Realm realm;
  final String? deviceToken, deviceType;
  ResetPasswordScreen({
    required this.email,
    required this.accessToken,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  bool _isLoading = false;
  final AuthApi authApi = AuthApi();
  bool _isNewPasswordVisible = false; // Track visibility of new password
  bool _isConfirmPasswordVisible =
  false; // Track visibility of confirm password
  final _formKey = GlobalKey<FormState>();

  Future<void> resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validate passwords
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both passwords')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Call API with new password
    setState(() {
      _isLoading = true;
    });

    final response = await authApi.resetPassword(
      widget.email,
      newPassword,
      widget.accessToken,
    );

    setState(() {
      _isLoading = false;
    });

    // Handle response
    if (response['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset successful!')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/signin', // Name of your sign-in route
            (Route<dynamic> route) => false,
        arguments: {
          'email': widget.email,
          'accessToken': '',
          'realm': widget.realm,
          'deviceToken': widget.deviceToken,
          'deviceType': widget.deviceType,
        },
      );

      /* ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset successful!')),
      );
      Navigator.pop(context);*/
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message'] ?? 'Failed to reset password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('Reset Password'),
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
                    TextField(
                      controller: _newPasswordController,
                      obscureText: !_isNewPasswordVisible, // Toggle visibility
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible, // Toggle visibility
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: resetPassword,
                      child: Text('Reset Password'),
                    ),
                  ],
                ),
              ),
            )));
  }
}
