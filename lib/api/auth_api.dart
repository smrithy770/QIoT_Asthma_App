import 'dart:convert';

import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';
import 'package:asthmaapp/utils/encryption_util.dart';
import 'package:realm_dart/src/realm_class.dart';

class AuthApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> signin(String email, String password,
      String? accessToken, String? deviceToken, String? deviceType) async {
    final response = await _apiService.post(ApiConstants.signin, accessToken, {
      'email': email,
      'password': password,
      'deviceToken': deviceToken,
      'deviceType': deviceType,
    });
    // Assuming the encrypted data is in 'encryptedResponse' key
    if (response.containsKey('encryptedResponse')) {
      String encryptedData = response['encryptedResponse'];
      // Decrypt the data
      String decryptedData = EncryptionUtil.decryptAES(encryptedData);

      // Parse the decrypted JSON string into a Map
      return jsonDecode(decryptedData);
    }

    // Return the response directly if there's no encryption
    return response;
  }

  Future<Map<String, dynamic>> refreshToken(String accessToken,
      String refreshToken, String? deviceToken, String? deviceType) async {
    return _apiService.post(ApiConstants.refreshtoken, accessToken, {
      'refreshToken': refreshToken,
      'deviceToken': deviceToken,
      'deviceType': deviceType,
    });
  }

  Future<Map<String, dynamic>> signup(
      String firstName,
      String lastName,
      String email,
      String password,
      String dateTimeZone,
      String? accessToken,
      String deviceToken,
      String deviceType) async {
    final response =
        await _apiService.post(ApiConstants.signupUrl, accessToken, {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'dateTimeZone': dateTimeZone,
      'deviceToken': deviceToken,
      'deviceType': deviceType,
    });
    // Assuming the encrypted data is in 'encryptedResponse' key
    if (response.containsKey('encryptedResponse')) {
      String encryptedData = response['encryptedResponse'];
      // Decrypt the data
      String decryptedData = EncryptionUtil.decryptAES(encryptedData);

      // Parse the decrypted JSON string into a Map
      return jsonDecode(decryptedData);
    }

    // Return the response directly if there's no encryption
    return response;
  }

  Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    final dataToSend = {
      'email': email,
    };
    final jsonString = jsonEncode(dataToSend); // Convert map to JSON
    logger.d('jsonString: $jsonString');
    final encryptedData =
        EncryptionUtil.encryptAES(jsonString); // Encrypt the JSON string

    // Send the encrypted data in the request
    final response =
        await _apiService.post(ApiConstants.resendVerificationEmailUrl, null, {
      'data': encryptedData,
    });
    // Assuming the encrypted data is in 'encryptedResponse' key
    if (response.containsKey('encryptedResponse')) {
      String encryptedData = response['encryptedResponse'];
      // Decrypt the data
      String decryptedData = EncryptionUtil.decryptAES(encryptedData);

      // Parse the decrypted JSON string into a Map
      return jsonDecode(decryptedData);
    }

    // Return the response directly if there's no encryption
    return response;
  }

  Future<Map<String, dynamic>> checkVerification(String email) async {
    final dataToSend = {
      'email': email,
    };
    final jsonString = jsonEncode(dataToSend); // Convert map to JSON
    logger.d('jsonString: $jsonString');
    final encryptedData =
        EncryptionUtil.encryptAES(jsonString); // Encrypt the JSON string

    // Send the encrypted data in the request
    final response =
        await _apiService.post(ApiConstants.checkVerificationUrl, null, {
      'data': encryptedData,
    });
    // Assuming the encrypted data is in 'encryptedResponse' key
    if (response.containsKey('encryptedResponse')) {
      String encryptedData = response['encryptedResponse'];
      // Decrypt the data
      String decryptedData = EncryptionUtil.decryptAES(encryptedData);

      // Parse the decrypted JSON string into a Map
      return jsonDecode(decryptedData);
    }

    // Return the response directly if there's no encryption
    return response;
  }

  Future<Map<String, dynamic>> signout(String userId) async {
    final signoutUrl = ApiConstants.getSignoutUrl(userId);
    return _apiService.delete(signoutUrl, null);
  }
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final dataToSend = {
      'email': email,  // Send email directly without encryption
    };

    print("Request Data: $dataToSend");

    // Send the email data directly in the request
    try {
      // Send POST request with the email data
      final response = await _apiService.post(ApiConstants.forgotPasswordUrl, null, dataToSend);

      // Print the raw response to inspect it
      print("Full API Response: $response");

      // If the response is not in expected format or empty
      if (response == null || response.isEmpty) {
        print("Received empty response or null response.");
        return {};  // Return empty map if the response is empty or null
      }

      // Check if the response contains the 'status' key and it's 200
      if (response.containsKey('status')) {
        if (response['status'] == 200) {
          // API Success: User found, print the message and user data
          print("API Success: ${response['message']}");
          print("User Data: ${response['user']}");

          // You can further process or return the user data if needed
          return response;
        } else {
          print("API Error: ${response['message']}");
          return {};  // Return empty map in case of API error (e.g., user not found)
        }
      } else {
        // If the 'status' key is missing or the response format is not as expected
        print("Error: Response doesn't contain expected 'status' field.");
        return {};  // Return empty map in this case
      }
    } catch (e) {
      print("Error during API call: $e");
      return {};  // Return empty map in case of an exception
    }
  }

  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword, [String? accessToken]) async {

    // Prepare data to send
    final dataToSend = {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
    print('Data to send: $dataToSend'); // Debug print

    // Convert map to JSON and encrypt
    final jsonString = jsonEncode(dataToSend);
    final encryptedData = EncryptionUtil.encryptAES(jsonString);

    // Call the API with encrypted data and accessToken
    final response = await _apiService.post(
      ApiConstants.changePasswordUrl,
      accessToken, // Optional accessToken passed here
      {
        'data': encryptedData,
      },
    );

    print('Encrypted Data: $encryptedData'); // Debug print

    // Check if the response has encrypted data
    if (response.containsKey('encryptedResponse')) {
      String encryptedResponse = response['encryptedResponse'];
      print('Encrypted Response: $encryptedResponse'); // Debug print

      // Decrypt and parse the response
      String decryptedData = EncryptionUtil.decryptAES(encryptedResponse);
      print('Decrypted Data: $decryptedData'); // Debug print
      return jsonDecode(decryptedData);
    }

    // Return the response directly if no encryption
    return response;
  }

  /// Sends OTP to the provided email.

  Future<Map<String, dynamic>> sendOTP(String email, [String? accessToken]) async {
    // Prepare data to send
    final dataToSend = {
      'email': email,
    };
    print('Data to send: $dataToSend'); // Debug print

    // Call the API with data and optional accessToken
    final response = await _apiService.post(
      ApiConstants.sendOTPUrl,
      accessToken, // Optional accessToken passed here
      dataToSend,
    );

    print('Response: $response'); // Debug print

    // Return the response directly
    return response;
  }



  /// Verifies the entered OTP for a given email.

  Future<Map<String, dynamic>> verifyOTP(String email, String otp, [String? accessToken]) async {
    // Prepare data to send
    final dataToSend = {
      'email': email,
      'otp': otp,
    };
    print('Data to send: $dataToSend'); // Debug print

    // Call the API with data and optional accessToken
    final response = await _apiService.post(
      ApiConstants.verifyOTPUrl,
      accessToken, // Optional accessToken passed here
      dataToSend,
    );

    print('Response: $response'); // Debug print

    // Return the response directly
    return response;
  }

  /// Verifies the entered OTP for a given email.
  Future<Map<String, dynamic>> signupverify(String email, String otp, [String? accessToken]) async {
    final dataToSend = {
      'email': email,
      'otp': otp
    };
    print('Data to send: $dataToSend');

    try {
      final response = await _apiService.post(
        ApiConstants.signupverifyUrl,
        accessToken,
        dataToSend,
      );

      print('Sign up Response(auth): $response');
      return response;
    } catch (e) {
      print('Error in signupverify: $e');
      throw Exception('Failed to verify OTP');
    }
  }

  /// Sends OTP to the provided email.

  Future<Map<String, dynamic>> resendOTP(String email, String deviceToken,String deviceType,
  [String? accessToken]) async {
    // Prepare data to send
    final dataToSend = {
      'email': email,
      'deviceToken': deviceToken,
      'deviceType': deviceType,
    };

    final jsonString = jsonEncode(dataToSend); // Convert map to JSON
    final encryptedData = EncryptionUtil.encryptAES(jsonString); // Encrypt the JSON string
    print('Data to send: $dataToSend'); // Debug print

    // Call the API with data and optional accessToken
    final response = await _apiService.post(ApiConstants.resendOTPUrl,
      accessToken,
      {'data': encryptedData,}
    );

    if (response.containsKey('encryptedResponse')) {
      String encryptedResponse = response['encryptedResponse'];
      String decryptedData = EncryptionUtil.decryptAES(encryptedResponse);
      return jsonDecode(decryptedData);
    }

    print('Response: $response'); // Debug print

    // Return the response directly
    return response;
  }

  Future<Map<String, dynamic>> resetPassword(String email, String password, [String? accessToken]) async {
    // Prepare data to send
    final dataToSend = {
      'email': email,
      'password': password,
    };
    print('Data to send: $dataToSend'); // Debug print

    // Call the API with data and optional accessToken
    final response = await _apiService.post(
      ApiConstants.resetPassword,
      accessToken, // Optional accessToken passed here
      dataToSend,
    );

    print('Response: $response'); // Debug print

    // Return the response directly
    return response;
  }


}
