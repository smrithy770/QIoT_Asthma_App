import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';
import '../../../api/auth_api.dart';
import '../../../constants/app_colors.dart';
import '../../../models/user_model/user_model.dart';
import '../../../utils/custom_snackbar_util.dart';

class ChangePasswordScreen extends StatefulWidget {
  final Realm realm;
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
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final AuthApi authApi = AuthApi();
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _isOldPasswordValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;

  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    userModel = getUserData(widget.realm);
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    if (results.isNotEmpty) {
      return results[0];
    }
    return null;
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }
  void _checkFormValidity() {
    setState(() {
      _isFormValid = _isOldPasswordValid &&
          _isPasswordValid &&
          _isConfirmPasswordValid &&
          _oldPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty &&
          _confirmNewPasswordController.text.isNotEmpty;
    });
  }

  void _validateOldPassword(String value) {
    setState(() {
      _isOldPasswordValid = value.isNotEmpty;// Ensure it's not empty
      _checkFormValidity();
    });
  }

  void _validatePassword(String value) {
    bool isValid = RegExp(
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:"<>?]).{8,}$')
        .hasMatch(value);
    setState(() {
      _isPasswordValid = isValid;
      _checkFormValidity();
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      _isConfirmPasswordValid =
          value.isNotEmpty && value == _newPasswordController.text;
      _checkFormValidity();
    });
  }

  void _submitChangePassword() async {
    if (_formKey.currentState!.validate()) {
      String oldPassword = _oldPasswordController.text.trim();
      String newPassword = _newPasswordController.text.trim();
      String confirmNewPassword = _confirmNewPasswordController.text.trim();

      if (newPassword != confirmNewPassword) {
        setState(() {
          _isConfirmPasswordValid = false; // Show error if passwords don't match
        });
        return;
      }

      try {
        final response = await authApi.changePassword(
          oldPassword,
          newPassword,
          userModel!.accessToken,
        );

        if (response['status'] == 200) {
          CustomSnackBarUtil.showCustomSnackBar(
              "Password changed successfully",
              success: true);
          Navigator.pushNamed(
            context,
            '/home',

            arguments: {
              'realm': widget.realm,
              'deviceToken': widget.deviceToken,
              'deviceType': widget.deviceType,
            },
          );
        } else {
          CustomSnackBarUtil.showCustomSnackBar(
              response['message'] ?? 'Failed to change password.',
              success: false);
        }
      } catch (e) {
        CustomSnackBarUtil.showCustomSnackBar(
            'An error occurred. Please try again.',
            success: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
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
                    'Change Password',
                    style: TextStyle(
                      color: AppColors.primaryBlueText,
                      fontSize: screenRatio * 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildPasswordField(
                  controller: _oldPasswordController,
                  label: 'Old Password',
                  obscureText: _obscureOldPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                  errorText: !_isOldPasswordValid
                      ? 'Old password cannot be empty'
                      : null,
                  onChanged: _validateOldPassword,
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
                  errorText: !_isPasswordValid
                      ? 'Password must contain uppercase, lowercase, number, and special character'
                      : null,
                  onChanged: _validatePassword,
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
                  errorText: !_isConfirmPasswordValid
                      ? 'Passwords do not match'
                      : null,
                  onChanged: _validateConfirmPassword,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed:  _isFormValid ? _submitChangePassword : null,
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: screenRatio * 7,
                      color: AppColors.primaryWhiteText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize:
                    Size(screenSize.width * 1.0, screenRatio * 26),
                    backgroundColor: _isOldPasswordValid &&
                        _isPasswordValid &&
                        _isConfirmPasswordValid
                        ? AppColors.primaryBlue
                        : AppColors.primaryGrey,
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? errorText,
    required ValueChanged<String> onChanged,
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
              floatingLabelBehavior: FloatingLabelBehavior.never,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

}
