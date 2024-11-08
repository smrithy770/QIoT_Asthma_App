import 'dart:io';

import 'package:asthmaapp/api/auth_api.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class SigninScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const SigninScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _pobscureText = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void onSignIn() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      try {
        final response = await AuthApi().signin(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          null,
          widget.deviceToken!,
          widget.deviceType!,
        );

        logger.d('Signin response: $response');

        final jsonResponse = response;
        // logger.d('Signin response: $jsonResponse');
        final status = jsonResponse['status'];
        if (status == 200) {
          final accessToken = jsonResponse['accessToken'] as String;
          logger.d('Access Token: $accessToken');
          final refreshToken = jsonResponse['refreshToken'] as String;
          logger.d('Refresh Token: $refreshToken');
          final userData =
              jsonResponse['payload'][0]['user'] as Map<String, dynamic>;
          logger.d('User Data: ${userData['signupStep']}');

          final existingUser = widget.realm.find<UserModel>(userData['_id']);

          if (existingUser != null) {
            // Update the existing user data
            widget.realm.write(() {
              existingUser.accessToken = accessToken;
              existingUser.refreshToken = refreshToken;
            });
          } else {
            // Add new user if not found
            final userModel = UserModel(
              userData['_id'],
              '',
              accessToken,
              refreshToken,
            );
            widget.realm.write(() {
              widget.realm.add(userModel);
            });
          }
          if (mounted) {
            CustomSnackBarUtil.showCustomSnackBar("Sign in successful",
                success: true);
            String nextRoute = userData['signupStep'] == 'newSignup'
                ? '/additional_setup_screen'
                : '/home';
            Navigator.pushNamedAndRemoveUntil(
              context,
              nextRoute, // Named route
              (Route<dynamic> route) =>
                  false, // This removes all previous routes
              arguments: {
                'realm': widget.realm,
                'deviceToken': widget.deviceToken,
                'deviceType': widget.deviceType,
              },
            );
          }
        } else {
          // Handle different statuses
          String errorMessage;
          switch (status) {
            case 400:
              errorMessage = 'Bad request: Please check your input';
              break;
            case 401:
              errorMessage = 'Unauthorized: Invalid email or password';
              break;
            case 500:
              errorMessage = 'Server error: Please try again later';
              break;
            default:
              errorMessage = 'Unexpected error: Please try again';
          }

          // Show error message
          CustomSnackBarUtil.showCustomSnackBar(errorMessage, success: false);
        }
      } on RealmException catch (e) {
        // Handle Realm-specific exceptions
        logger.d('RealmException: $e');
        CustomSnackBarUtil.showCustomSnackBar('Database error: ${e.message}',
            success: false);
      } on SocketException catch (e) {
        // Handle network-specific exceptions
        logger.d('NetworkException: $e');
        CustomSnackBarUtil.showCustomSnackBar(
            'Network error: Please check your internet connection',
            success: false);
      } on Exception catch (e) {
        logger.d('Signin failed: $e');
        CustomSnackBarUtil.showCustomSnackBar('Signin failed: ${e.toString()}',
            success: false);
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  void _validateEmail(String value) {
    bool isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
    if (isValid != _isEmailValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
    logger.d('Email is valid: $_isEmailValid');
  }

  void _validatePassword(String value) {
    bool isValid = RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:"<>?]).{8,}$')
        .hasMatch(value);
    if (isValid != _isPasswordValid) {
      setState(() {
        _isPasswordValid = isValid;
      });
    }
    logger.d('Password is valid: $_isPasswordValid');
  }

  @override
  void dispose() {
    // widget.realm.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: screenSize.width,
                  // height: screenSize.height,
                  padding: const EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenRatio,
                      vertical: screenRatio,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenRatio * 20),
                        SvgPicture.asset(
                          'assets/svgs/user_assets/logo.svg',
                          width: screenRatio * 52,
                        ),
                        SizedBox(height: screenRatio * 44),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sign in to your account',
                            style: TextStyle(
                              color: AppColors.primaryBlueText,
                              fontSize: screenRatio * 9,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        SizedBox(height: screenRatio * 4),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: screenRatio * 8,
                                    vertical: screenRatio * 4,
                                  ),
                                  labelText: 'Email ID',
                                  labelStyle: TextStyle(
                                    color: _isEmailValid == true
                                        ? AppColors.primaryBlue
                                        : AppColors.errorRed,
                                    fontSize: screenRatio * 6,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  hintText: 'Email ID',
                                  hintStyle: TextStyle(
                                    color: _isEmailValid
                                        ? AppColors.primaryBlue
                                        : AppColors.errorRed,
                                    fontSize: screenRatio * 6,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  errorStyle: TextStyle(
                                    color: AppColors.errorRed,
                                    fontSize: screenRatio * 5,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  // enabledBorder: OutlineInputBorder(
                                  //   borderSide: const BorderSide(
                                  //     color: AppColors.primaryBlue,
                                  //     width: 2.0,
                                  //   ),
                                  //   borderRadius: BorderRadius.circular(8.0),
                                  // ),
                                  // focusedBorder: OutlineInputBorder(
                                  //   borderSide: const BorderSide(
                                  //     color: AppColors.primaryBlue,
                                  //     width: 2.0,
                                  //   ),
                                  //   borderRadius: BorderRadius.circular(8.0),
                                  // ),
                                  // errorBorder: OutlineInputBorder(
                                  //   borderSide: const BorderSide(
                                  //     color: AppColors.errorRed,
                                  //     width: 2.0,
                                  //   ),
                                  //   borderRadius: BorderRadius.circular(8.0),
                                  // ),
                                  // focusedErrorBorder: OutlineInputBorder(
                                  //   borderSide: const BorderSide(
                                  //     color: AppColors.errorRed,
                                  //     width: 2.0,
                                  //   ),
                                  //   borderRadius: BorderRadius.circular(8.0),
                                  // ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: _validateEmail,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email ID is required';
                                  } else if (!_isEmailValid) {
                                    return 'Enter valid Email ID';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: screenRatio * 3),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: screenRatio * 8,
                                    vertical: screenRatio * 4,
                                  ),
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    color: _isPasswordValid == true
                                        ? AppColors.primaryBlue
                                        : AppColors.errorRed,
                                    fontSize: screenRatio * 6,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                    color: _isPasswordValid
                                        ? AppColors.primaryBlue
                                        : AppColors.errorRed,
                                    fontSize: screenRatio * 6,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  errorStyle: TextStyle(
                                    color: AppColors.errorRed,
                                    fontSize: screenRatio * 5,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  // enabledBorder: OutlineInputBorder(
                                  //   borderSide: const BorderSide(
                                  //     color: AppColors.primaryBlue,
                                  //     width: 2.0,
                                  //   ),
                                  //   borderRadius: BorderRadius.circular(8.0),
                                  // ),
                                  // focusedBorder: OutlineInputBorder(
                                  //   borderSide: const BorderSide(
                                  //     color: AppColors.primaryBlue,
                                  //     width: 2.0,
                                  //   ),
                                  //   borderRadius: BorderRadius.circular(8.0),
                                  // ),
                                  // errorBorder: OutlineInputBorder(
                                  //   borderSide: const BorderSide(
                                  //     color: AppColors.errorRed,
                                  //     width: 2.0,
                                  //   ),
                                  //   borderRadius: BorderRadius.circular(8.0),
                                  // ),
                                  // focusedErrorBorder: OutlineInputBorder(
                                  //   borderSide: const BorderSide(
                                  //     color: AppColors.errorRed,
                                  //     width: 2.0,
                                  //   ),
                                  //   borderRadius: BorderRadius.circular(8.0),
                                  // ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _pobscureText = !_pobscureText;
                                      });
                                    },
                                    child: Icon(
                                      color: _isPasswordValid
                                          ? AppColors.primaryBlue
                                          : AppColors.errorRed,
                                      _pobscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: screenRatio * 10,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.visiblePassword,
                                onChanged: _validatePassword,
                                obscureText: _pobscureText,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  } else if (!_isPasswordValid) {
                                    return 'Enter valid Password';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenRatio * 10),
                        ElevatedButton(
                          onPressed: (_emailController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty)
                              ? onSignIn
                              : null,
                          style: ElevatedButton.styleFrom(
                            fixedSize:
                                Size(screenSize.width * 1.0, screenRatio * 26),
                            foregroundColor:
                                (_emailController.text.isNotEmpty &&
                                        _passwordController.text.isNotEmpty)
                                    ? AppColors.primaryBlueText
                                    : AppColors.primaryGreyText,
                            backgroundColor:
                                (_emailController.text.isNotEmpty &&
                                        _passwordController.text.isNotEmpty)
                                    ? AppColors.primaryBlue
                                    : AppColors.primaryGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                          ),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: screenRatio * 7,
                              color: (_emailController.text.isNotEmpty &&
                                      _passwordController.text.isNotEmpty)
                                  ? AppColors.primaryWhiteText
                                  : AppColors.primaryGreyText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: screenRatio * 8),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgotpassword');
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: screenRatio * 8,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        SizedBox(height: screenRatio * 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: TextStyle(
                                color: AppColors.primaryBlueText,
                                fontSize: screenRatio * 8,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/signup',
                                  arguments: {
                                    'realm': widget.realm,
                                    'deviceToken': widget.deviceToken ?? '',
                                    'deviceType': widget.deviceType ?? '',
                                  },
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: screenRatio * 8,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Center(
                child: Container(
                  width: screenRatio * 32,
                  height: screenRatio * 32,
                  padding: EdgeInsets.all(screenRatio * 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhite.withOpacity(1.0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const CircularProgressIndicator(
                    backgroundColor: AppColors.primaryWhite,
                    color: AppColors.primaryBlue,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
