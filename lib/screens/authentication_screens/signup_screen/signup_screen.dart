import 'dart:io';

import 'package:asthmaapp/api/auth_api.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class SignupScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const SignupScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  AuthApi authApi = AuthApi();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  bool _pobscureText = true;
  bool _cpobscureText = true;
  bool _firstNameEmpty = true;
  bool _lastNameEmpty = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;

  void onSignUp() async {
    DateTime dateTime = DateTime.now();
    if (_formKey.currentState!.validate()) {
      _validateFirstName(_firstNameController.text.trim());
      _validateLastName(_lastNameController.text.trim());
      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        final response = await authApi.signup(
            firstName,
            lastName,
            email,
            password,
            dateTime.timeZoneName,
            null,
            widget.deviceToken!,
            widget.deviceType!);
        final jsonResponse = response;
        final status = jsonResponse['status'] as int;
        if (status == 200) {
          if (mounted) {
            CustomSnackBarUtil.showCustomSnackBar("Sign up successful",
                success: true);
            Navigator.popAndPushNamed(
              context,
              '/signin',
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
        print('RealmException: $e');
        CustomSnackBarUtil.showCustomSnackBar('Database error: ${e.message}',
            success: false);
      } on SocketException catch (e) {
        // Handle network-specific exceptions
        print('NetworkException: $e');
        CustomSnackBarUtil.showCustomSnackBar(
            'Network error: Please check your internet connection',
            success: false);
      } on Exception catch (e) {
        print('Signup failed: $e');
        CustomSnackBarUtil.showCustomSnackBar('Signup failed: ${e.toString()}',
            success: false);
      }
    }
  }

  void _validateFirstName(String value) {
    if (value.isEmpty != _firstNameEmpty) {
      setState(() {
        _firstNameEmpty = value.isEmpty;
      });
    }
    print('Last Name is empty: $_lastNameEmpty');
  }

  void _validateLastName(String value) {
    if (value.isEmpty != _lastNameEmpty) {
      setState(() {
        _lastNameEmpty = value.isEmpty;
      });
    }
    print('Last Name is empty: $_lastNameEmpty');
  }

  void _validateEmail(String value) {
    bool isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
    if (isValid != _isEmailValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
    print('Email is valid: $_isEmailValid');
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
  }

  void _validateConfirmPassword(String value) {
    bool isValid = RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:"<>?]).{8,}$')
        .hasMatch(value);

    if (isValid) {
      // Check if the confirmed password matches the original password
      if (value == _passwordController.text) {
        setState(() {
          _isPasswordValid = true;
          _isConfirmPasswordValid = true;
        });
      } else {
        setState(() {
          _isPasswordValid = true;
          _isConfirmPasswordValid = false;
        });
      }
    } else {
      setState(() {
        _isPasswordValid = false;
      });
    }
  }

  @override
  void dispose() {
    // widget.realm.close();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenSize.height * 0.08),
                SvgPicture.asset(
                  'assets/svgs/logo.svg',
                  width: screenSize.width * 0.4,
                ),
                SizedBox(height: screenSize.height * 0.02),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sign up to your account',
                            style: TextStyle(
                              color: AppColors.primaryBlueText,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            // labelStyle: TextStyle(
                            //   color: !_lastNameEmpty
                            //       ? AppColors.primaryBlue
                            //       : AppColors.errorRed,
                            // ),
                            labelStyle: const TextStyle(
                              color: AppColors.primaryBlue,
                            ),
                            hintText: 'First Name',
                            // hintStyle: TextStyle(
                            //   color: !_lastNameEmpty
                            //       ? AppColors.primaryBlue
                            //       : AppColors.errorRed,
                            // ),
                            hintStyle: const TextStyle(
                              color: AppColors.primaryBlue,
                            ),
                            errorStyle: const TextStyle(
                              color: AppColors.errorRed,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.errorRed,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.errorRed,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          keyboardType: TextInputType.name,
                          // onChanged: (value) {
                          //   _validateLastName(value); // Call on change
                          // },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'First Name is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            // labelStyle: TextStyle(
                            //   color: !_lastNameEmpty
                            //       ? AppColors.primaryBlue
                            //       : AppColors.errorRed,
                            // ),
                            labelStyle: const TextStyle(
                              color: AppColors.primaryBlue,
                            ),
                            hintText: 'Last Name',
                            // hintStyle: TextStyle(
                            //   color: !_lastNameEmpty
                            //       ? AppColors.primaryBlue
                            //       : AppColors.errorRed,
                            // ),
                            hintStyle: const TextStyle(
                              color: AppColors.primaryBlue,
                            ),
                            errorStyle: const TextStyle(
                              color: AppColors.errorRed,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.errorRed,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.errorRed,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          keyboardType: TextInputType.name,
                          // onChanged: (value) {
                          //   _validateLastName(value); // Call on change
                          // },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Last Name is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email ID',
                            labelStyle: TextStyle(
                              color: _isEmailValid == true
                                  ? AppColors.primaryBlue
                                  : AppColors.errorRed,
                            ),
                            hintText: 'Email ID',
                            hintStyle: TextStyle(
                              color: _isEmailValid
                                  ? AppColors.primaryBlue
                                  : AppColors.errorRed,
                            ),
                            errorStyle: const TextStyle(
                              color: AppColors.errorRed,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.errorRed,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.errorRed,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
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
                        SizedBox(height: screenSize.height * 0.02),
                        // Password
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: _isPasswordValid == true
                                  ? AppColors.primaryBlue
                                  : AppColors.errorRed,
                            ),
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: _isPasswordValid
                                  ? AppColors.primaryBlue
                                  : AppColors.errorRed,
                            ),
                            errorStyle: const TextStyle(
                              color: AppColors.errorRed,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.errorRed,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.errorRed,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
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
                              return 'Minimum 8 characters, \nMinimum 1 special character, \nMinimum 1 numerical character, \nMinimum 1 uppercase & lowercase character';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        // Confirm Password
                        TextFormField(
                          controller: _confirmpasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                              color: _isConfirmPasswordValid == true
                                  ? AppColors.primaryBlue
                                  : AppColors.errorRed,
                            ),
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(
                              color: _isConfirmPasswordValid
                                  ? AppColors.primaryBlue
                                  : AppColors.errorRed,
                            ),
                            errorStyle: const TextStyle(
                              color: AppColors.errorRed,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.errorRed,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.errorRed,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _cpobscureText = !_cpobscureText;
                                });
                              },
                              child: Icon(
                                color: _isPasswordValid
                                    ? AppColors.primaryBlue
                                    : AppColors.errorRed,
                                _cpobscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          onChanged: _validateConfirmPassword,
                          obscureText: _cpobscureText,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm Password is required';
                            } else if (!_isPasswordValid) {
                              return 'Minimum 8 characters, \nMinimum 1 special character, \nMinimum 1 numerical character, \nMinimum 1 uppercase & lowercase character';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenSize.height * 0.04),
                        // Sign Up Button
                        ElevatedButton(
                          onPressed: (_emailController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty &&
                                  _confirmpasswordController.text.isNotEmpty)
                              ? onSignUp
                              : null,
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(screenSize.width * 1.0,
                                screenSize.height * 0.06),
                            foregroundColor: (_emailController
                                        .text.isNotEmpty &&
                                    _passwordController.text.isNotEmpty &&
                                    _confirmpasswordController.text.isNotEmpty)
                                ? AppColors.primaryBlueText
                                : AppColors.primaryGreyText,
                            backgroundColor: (_emailController
                                        .text.isNotEmpty &&
                                    _passwordController.text.isNotEmpty &&
                                    _confirmpasswordController.text.isNotEmpty)
                                ? AppColors.primaryBlue
                                : AppColors.primaryGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                          ),
                          child: Text('Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                color: (_emailController.text.isNotEmpty &&
                                        _passwordController.text.isNotEmpty &&
                                        _confirmpasswordController
                                            .text.isNotEmpty)
                                    ? AppColors.primaryWhiteText
                                    : AppColors.primaryGreyText,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgotpassword');
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account?',
                              style: TextStyle(
                                color: AppColors.primaryBlueText,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.popAndPushNamed(
                                  context,
                                  '/signin',
                                  arguments: {
                                    'realm': widget.realm,
                                    'deviceToken': widget.deviceToken,
                                    'deviceType': widget.deviceType,
                                  },
                                );
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
    );
  }
}
