import 'dart:convert';

import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';
import 'package:asthmaapp/utils/encryption_util.dart';

class PeakflowApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addPeakflow(String userId, int peakflowValue,
      Map<String, dynamic> location, int month, int year,
      [String? accessToken]) async {
    final addPeakflowUrl = ApiConstants.addPeakflowUrl(userId);

    // Prepare the data to be encrypted
    final dataToSend = {
      'peakflowValue': peakflowValue,
      'location': location,
      'month': month,
      'year': year,
    };

    // Convert the data to a JSON string and encrypt it
    final jsonString = jsonEncode(dataToSend); // Convert map to JSON
    final encryptedData =
        EncryptionUtil.encryptAES(jsonString); // Encrypt the JSON string

    // Send the encrypted data in the request
    final response = await _apiService.post(addPeakflowUrl, accessToken, {
      'data': encryptedData, // Sending the encrypted data under the 'data' key
    });
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

  Future<Map<String, dynamic>> getPeakflowHistory(
      String userId, int month, int year,
      [String? accessToken]) async {
    final getPeakflowHistoryUrl =
        ApiConstants.getPeakflowHistoryUrl(userId, month, year);
    final response = await _apiService.get(getPeakflowHistoryUrl, accessToken);

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
}
