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
  final TextEditingController _confirmNewPasswordController =
  TextEditingController();
  final AuthApi authApi = AuthApi();
  bool _isButtonEnabled = false;
  final _formKey = GlobalKey<FormState>();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    setState(() {
      userModel = getUserData(widget.realm);
      _oldPasswordController.addListener(_updateButtonState);
      _newPasswordController.addListener(_updateButtonState);
      _confirmNewPasswordController.addListener(_updateButtonState);
    });
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

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _oldPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty &&
          _confirmNewPasswordController.text.isNotEmpty &&
          _validatePassword(_oldPasswordController.text) == null &&
          _validatePassword(_newPasswordController.text) == null &&
          _validatePassword(_confirmNewPasswordController.text) == null;
    });
  }

  void _submitChangePassword() async {
    if (!_isButtonEnabled) return;
    if (_formKey.currentState!.validate()) {
      String oldPassword = _oldPasswordController.text.trim();
      String newPassword = _newPasswordController.text.trim();
      String confirmNewPassword = _confirmNewPasswordController.text.trim();

      if (newPassword != confirmNewPassword) {
        _showErrorDialog('New passwords do not match.');
        return;
      }

      try {
        final response = await authApi.changePassword(
          oldPassword,
          newPassword,
          userModel!.accessToken,
        );

        if (response['status'] == 200) {
          CustomSnackBarUtil.showCustomSnackBar("Password changed successfully", success: true);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
                (Route<dynamic> route) => false,
            arguments: {
              'realm': widget.realm,
              'deviceToken': widget.deviceToken,
              'deviceType': widget.deviceType,
            },
          );
        } else {
          await _showErrorDialog(response['message'] ?? 'Failed to change password.');
        }
      } catch (e) {
        await _showErrorDialog('An error occurred. Please try again.');
      }
    }
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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
    } else if (!RegExp(
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:"<>?]).{8,}$')
        .hasMatch(value)) {
      return 'Password must contain an uppercase, lowercase, number, and special character';
    }
    return null;
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
                    'Change password',
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
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isButtonEnabled ? _submitChangePassword : null,
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
  }) {
    return Container(
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
        validator: validator,
      ),
    );
  }
}
