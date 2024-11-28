import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';
import '../../../api/auth_api.dart';
import '../../../api/user_api.dart';
import '../../../constants/app_colors.dart';
import '../../../main.dart';
import '../../../models/user_model/user_model.dart';
import '../../../utils/custom_snackbar_util.dart'; // Update this import based on your project structure

class ChangePasswordScreen extends StatefulWidget {
  final Realm realm;

 // const ChangePasswordScreen({Key? key}) : super(key: key);
  final String? deviceToken, deviceType;
  const ChangePasswordScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
  TextEditingController();
  final AuthApi authApi = AuthApi();

  final _formKey = GlobalKey<FormState>();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  UserModel? userModel;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    setState(() {
      userModel = getUserData(widget.realm);
    });
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    if (results.isNotEmpty) {
      return results[0]; // Return the first user if available
    }
    return null; // Return null if no users are found
  }


  void _submitChangePassword() async {
    if (_formKey.currentState!.validate()) {
      String oldPassword = _oldPasswordController.text.trim();
      String newPassword = _newPasswordController.text.trim();
      String confirmNewPassword = _confirmNewPasswordController.text.trim();

      if (newPassword != confirmNewPassword) {
        _showErrorDialog('New passwords do not match.');
        return;
      }

      try {
        print('Attempting password change...');
        print('Access Token: ${userModel?.accessToken}');

        final response = await authApi.changePassword(
          oldPassword,
          newPassword,
          userModel!.accessToken,
        );

        print('Response: $response');

        if (response['status'] == 200) {
          // Password change successful
          logger.d('Password Change Successful');

          // Show a success message using a custom snackbar
          if (mounted) {
            CustomSnackBarUtil.showCustomSnackBar("Password changed successfully", success: true);

            // Navigate to the home screen (like you did after sign-in)
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home', // Named route for the Home screen
                  (Route<dynamic> route) => false, // This removes all previous routes
              arguments: {
                'realm': widget.realm,
                'deviceToken': widget.deviceToken,
                'deviceType': widget.deviceType,
              },
            );
          }
        } /*else {
          // Handle error scenario if the password change failed
          if (mounted) {
            CustomSnackBarUtil.showCustomSnackBar("Failed to change password", success: false);
          }
        }*/
    else {
          // Show error dialog with API-provided message or default
          await _showErrorDialog(response['message'] ?? 'Failed to change password.');
        }
      } catch (e) {
        print('An error occurred: $e');
        await _showErrorDialog('An error occurred. Please try again.');
      }
    }
  }


  Future<void> _showErrorDialog(String message) async {
    // Ensure this function is awaited so no other dialogs or navigation happen before it's dismissed
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the error dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    // Ensure this function is awaited so the code doesn't proceed before dialog is dismissed
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');

              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
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
                    'Change password',
                    style: TextStyle(
                      color: AppColors.primaryBlueText,
                      fontSize: screenRatio * 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildPasswordField(
                  controller: _oldPasswordController,
                  label: 'Old Password',
                  obscureText: _obscureOldPassword,
                  showIcon: false, // Hide icon for old password
                  onToggleVisibility: () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                  validator: _validatePassword,
                ),
                SizedBox(height: 20),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  obscureText: _obscureNewPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  validator: _validatePassword,
                ),
                SizedBox(height: 20),
                _buildPasswordField(
                  controller: _confirmNewPasswordController,
                  label: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: _validatePassword,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitChangePassword,
                  child: Text('Change Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required FormFieldValidator<String> validator,
    bool showIcon = false,
  }) {
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
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
            validator: validator,
          ),
        ),
        if (controller.text.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$label is required',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
