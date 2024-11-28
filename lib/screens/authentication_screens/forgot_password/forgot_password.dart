
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:realm/realm.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../api/auth_api.dart';
import '../../../constants/app_colors.dart';
import '../otp_screen/OTPScreen.dart';


class ForgotPasswordScreen extends StatefulWidget {
  final String email;
  final String accessToken;
  final Realm realm;
  final String? deviceToken, deviceType;

  ForgotPasswordScreen({required this.email, required this.accessToken,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthApi authApi = AuthApi();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    //initDynamicLinks();
  }

/*  initDynamicLinks() async {
    // this is called when app comes from background
    FirebaseDynamicLinks.instance.onLink;

    // this is called when app is not open in background

    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      print('the link is : $deepLink');
      Navigator.pushNamed(context, '/reset_password'*//*, arguments: deepLink.queryParameters['title']*//*);
    }
  }*/
/*  void _submitEmail() async {
    String email = _emailController.text.trim();
    if (email.isNotEmpty) {
      try {
        print("Submitting email: $email"); // Debug print for the email
        // Call API to send forgot password request
        final response = await authApi.forgotPassword(email);
        print('Submitting email to $Uri with headers');

        print("API Response: $response");

        if (response['status'] == 200) {
          // Open email client with a predefined subject and body
          final Uri emailLaunchUri = Uri(
            scheme: 'mailto',
            path: email,
            queryParameters: {
              'subject': 'Password Reset Request',
              'body': 'Please follow the instructions to reset your password.'
            },
          );

          if (await canLaunch(emailLaunchUri.toString())) {
            await launch(emailLaunchUri.toString());
            // After sending email, navigate to reset password screen
            Navigator.pushReplacementNamed(context, '/reset_password');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch email client')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send reset email')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email address')),
      );
    }
  }*/
/*  Future<void> sendOTP() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await authApi.sendOTP(widget.email,);

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(email: email,),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Failed to send OTP')),
      );
    }
  }*/


  Future<void> sendOTP() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await authApi.sendOTP(email);

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 200) {
      Navigator.pushNamed(
        context,
        '/otp_screen', // Name of your sign-in route
        arguments: {
          'email':email,
          'realm': widget.realm,
          'deviceToken': widget.deviceToken,
          'deviceType': widget.deviceType,
        },
      );
      print('emailllllllllllllllllll: ');
      print(widget.email);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Failed to send OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
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
                  child: Text(
                    'Enter your email to reset your password',
                    style: TextStyle(
                      color: AppColors.primaryBlueText,
                      fontSize: screenRatio * 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildEmailField(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: sendOTP,
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey),
          ),
          child: TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email address';
              } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ),
        if (_emailController.text.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Email address is required',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}