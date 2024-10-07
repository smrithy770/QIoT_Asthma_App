import 'dart:convert';
import 'dart:io';

import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';
import 'package:asthmaapp/utils/encryption_util.dart';

class SteroidDoseApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addSteroidDose(String userId,
      int steroidDoseValue, Map<String, dynamic> location, int month, int year,
      [String? accessToken]) async {
    final addSteroidDoseUrl = ApiConstants.addSteroidDoseUrl(userId);

    // Prepare the data to be encrypted
    final dataToSend = {
      'steroidDoseValue': steroidDoseValue,
      'location': location,
      'month': month,
      'year': year,
    };

    // Convert the data to a JSON string and encrypt it
    final jsonString = jsonEncode(dataToSend); // Convert map to JSON
    final encryptedData =
        EncryptionUtil.encryptAES(jsonString); // Encrypt the JSON string

    final response = await _apiService.post(addSteroidDoseUrl, accessToken, {
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

  Future<Map<String, dynamic>> uploadSteroidCard(String userId, String? file,
      [String? accessToken]) async {
    final uploadSteroidCardUrl = ApiConstants.uploadSteroidCardUrl(userId);
    return _apiService.post(
      uploadSteroidCardUrl,
      accessToken,
      {},
      file: file != null ? File(file) : null,
    );
  }

  Future<Map<String, dynamic>> getSteroidDoseHistory(
      String userId, int month, int year,
      [String? accessToken]) async {
    final getSteroidDoseHistoryUrl =
        ApiConstants.getSteroidDoseHistoryUrl(userId, month, year);
    final response =
        await _apiService.get(getSteroidDoseHistoryUrl, accessToken);

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
