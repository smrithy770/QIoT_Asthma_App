import 'dart:async';
import 'dart:io';

import 'package:asthmaapp/api/auth_api.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
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
  bool _isChecked = false;
  String pathPDF = "assets/pdfs/TermsCondition.pdf";

  @override
  void initState() {
    super.initState();
    fromAsset(pathPDF, 'TermsCondition.pdf').then((f) {
      setState(() {
        pathPDF = f.path;
      });
    });
  }

  // For Pdf file.
  Future<File> fromAsset(String asset, String filename) async {
    Completer<File> completer = Completer();
    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
    return completer.future;
  }

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
        final status = jsonResponse['status'];
        if (status == 201) {
          if (mounted) {
            CustomSnackBarUtil.showCustomSnackBar("Sign up successful",
                success: true);
            Navigator.pushNamedAndRemoveUntil(
              context,
            'signup_otp_verify',
                  (Route<dynamic> route) =>
              false, // This removes all previous routes
              arguments: {
                'realm': widget.realm,
                'email': email,
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
        logger.d('Signup failed: $e');
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
    logger.d('Last Name is empty: $_lastNameEmpty');
  }

  void _validateLastName(String value) {
    if (value.isEmpty != _lastNameEmpty) {
      setState(() {
        _lastNameEmpty = value.isEmpty;
      });
    }
    logger.d('Last Name is empty: $_lastNameEmpty');
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
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            // physics: const BouncingScrollPhysics(),
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
                    SizedBox(height: screenRatio * 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sign up to your account',
                        style: TextStyle(
                          color: AppColors.primaryBlueText,
                          fontSize: screenRatio * 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    SizedBox(height: screenRatio * 5),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenRatio * 8,
                                vertical: screenRatio * 2,
                              ),
                              labelText: 'First Name',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              // labelStyle: TextStyle(
                              //   color: !_lastNameEmpty
                              //       ? AppColors.primaryBlue
                              //       : AppColors.errorRed,
                              //   fontSize: screenRatio * 6,
                              // ),
                              labelStyle: TextStyle(
                                color: AppColors.primaryGreyText,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                              ),
                              hintText: 'First Name',
                              // hintStyle: TextStyle(
                              //   color: !_lastNameEmpty
                              //       ? AppColors.primaryBlue
                              //       : AppColors.errorRed,
                              // ),
                              hintStyle: TextStyle(
                                color: AppColors.primaryGreyText,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                              ),
                              errorStyle: TextStyle(
                                color: AppColors.errorRed,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:  BorderSide(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  width: 1.0,
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
                          SizedBox(height: screenRatio * 3),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenRatio * 8,
                                vertical: screenRatio * 4,
                              ),
                              labelText: 'Last Name',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              // labelStyle: TextStyle(
                              //   color: !_lastNameEmpty
                              //       ? AppColors.primaryBlue
                              //       : AppColors.errorRed,
                              // ),
                              labelStyle: TextStyle(
                                color: AppColors.primaryGreyText,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                              ),
                              hintText: 'Last Name',
                              // hintStyle: TextStyle(
                              //   color: !_lastNameEmpty
                              //       ? AppColors.primaryBlue
                              //       : AppColors.errorRed,
                              // ),
                              hintStyle: TextStyle(
                                color: AppColors.primaryGreyText,
                                fontSize: screenRatio * 6,
                                fontWeight: FontWeight.normal,
                              ),
                              errorStyle: TextStyle(
                                color: AppColors.errorRed,
                                fontSize: screenRatio * 5,
                                fontWeight: FontWeight.normal,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:  BorderSide(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:  BorderSide(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  width: 1.0,
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
                          SizedBox(height: screenRatio * 3),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenRatio * 8,
                                vertical: screenRatio * 4,
                              ),
                              labelText: 'Email ID',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              labelStyle: TextStyle(
                                color: _isEmailValid == true
                                    ? AppColors.primaryGreyText
                                    : AppColors.errorRed,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                              ),
                              hintText: 'Email ID',
                              hintStyle: TextStyle(
                                color: _isEmailValid
                                    ? AppColors.primaryGreyText
                                    : AppColors.errorRed,
                                fontSize: screenRatio * 6,
                                fontWeight: FontWeight.normal,
                              ),
                              errorStyle: TextStyle(
                                color: AppColors.errorRed,
                                fontSize: screenRatio * 5,
                                fontWeight: FontWeight.normal,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:  BorderSide(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  width: 1.0,
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
                          SizedBox(height: screenRatio * 3),
                          // Password
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenRatio * 8,
                                vertical: screenRatio * 4,
                              ),
                              labelText: 'Password',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              labelStyle: TextStyle(
                                color: _isPasswordValid == true
                                    ? AppColors.primaryGreyText
                                    : AppColors.errorRed,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                              ),
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                color: _isPasswordValid
                                    ? AppColors.primaryGreyText
                                    : AppColors.errorRed,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                              ),
                              errorStyle: TextStyle(
                                color: AppColors.errorRed,
                                fontSize: screenRatio * 5,
                                fontWeight: FontWeight.normal,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:  BorderSide(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  width: 1.0,
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
                                return 'Minimum 8 characters, \nMinimum 1 special character, \nMinimum 1 numerical character, \nMinimum 1 uppercase & lowercase character';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: screenRatio * 3),
                          // Confirm Password
                          TextFormField(
                            controller: _confirmpasswordController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenRatio * 8,
                                vertical: screenRatio * 4,
                              ),
                              labelText: 'Confirm Password',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              labelStyle: TextStyle(
                                color: _isConfirmPasswordValid == true
                                    ? AppColors.primaryGreyText
                                    : AppColors.errorRed,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                              ),
                              hintText: 'Confirm Password',
                              hintStyle: TextStyle(
                                color: _isConfirmPasswordValid
                                    ? AppColors.primaryGreyText
                                    : AppColors.errorRed,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                              ),
                              errorStyle: TextStyle(
                                color: AppColors.errorRed,
                                fontSize: screenRatio * 5,
                                fontWeight: FontWeight.normal,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:  BorderSide(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  width: 1.0,
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
                                  size: screenRatio * 10,
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
                        ],
                      ),
                    ),
                    SizedBox(height: screenRatio * 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (value) {
                            setState(() {
                              _isChecked = value!;
                            });
                          },
                        ),
                        Text(
                          'I have read and agree to the',
                          style: TextStyle(
                            color: AppColors.primaryBlack,
                            fontSize: screenRatio * 5.2,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/terms_conditions',
                              arguments: {
                                'realm': widget.realm,
                                'deviceToken': widget.deviceToken ?? '',
                                'deviceType': widget.deviceType ?? '',
                                'pathPDF': pathPDF,
                              },
                            );
                          },
                          child: Text(
                            'Terms & Conditions.',
                            style: TextStyle(
                              color: AppColors.primaryLightBlue,
                              fontSize: screenRatio * 5.2,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        // ClickableText(
                        //   textBeforeClickable: '',
                        //   clickableText: 'Terms & Conditions ',
                        //   color: Colors.blue,
                        //   textAfterClickable: '',
                        //   fontSize: 6 * screenRatio,
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) =>
                        //               TermsAndConditionsScreen(path: pathPDF)),
                        //     );
                        //   },
                        // )
                      ],
                    ),
                    SizedBox(height: screenRatio * 10),
                    // Sign Up Button
                    ElevatedButton(
                      onPressed: (_emailController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty &&
                          _confirmpasswordController.text.isNotEmpty)
                          ? onSignUp
                          : null,
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                        Size(screenSize.width * 1.0, screenRatio * 26),
                        foregroundColor: (_emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty &&
                            _confirmpasswordController.text.isNotEmpty)
                            ? AppColors.primaryBlueText
                            : AppColors.primaryGreyText,
                        backgroundColor: (_emailController.text.isNotEmpty &&
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
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: screenRatio * 7,
                          color: (_emailController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty &&
                              _confirmpasswordController.text.isNotEmpty)
                              ? AppColors.primaryWhiteText
                              : AppColors.primaryGreyText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: screenRatio * 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: AppColors.primaryBlueText,
                            fontSize: screenRatio * 8,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/signin', // Named route
                                  (Route<dynamic> route) =>
                              false, // This removes all previous routes
                              arguments: {
                                'realm': widget.realm,
                                'deviceToken': widget.deviceToken,
                                'deviceType': widget.deviceType,
                              },
                            );
                          },
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.primaryLightBlue,
                              fontSize: screenRatio * 8,
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
          ),
        ),
      ),
    );
  }
}
