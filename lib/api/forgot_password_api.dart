import 'dart:convert';
import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';
import 'package:asthmaapp/utils/encryption_util.dart';

class AuthApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final dataToSend = {
      'email': email,
    };
    final jsonString = jsonEncode(dataToSend); // Convert map to JSON
    final encryptedData = EncryptionUtil.encryptAES(jsonString); // Encrypt the JSON string

    // Send the encrypted data in the request
    final response = await _apiService.post(ApiConstants.forgotPasswordUrl, null, {
      'data': encryptedData,
    });

    // Assuming the encrypted data is in 'encryptedResponse' key
    if (response.containsKey('encryptedResponse')) {
      String encryptedResponse = response['encryptedResponse'];
      String decryptedData = EncryptionUtil.decryptAES(encryptedResponse);
      return jsonDecode(decryptedData);
    }

    return response; // Return response directly if there's no encryption
  }
}