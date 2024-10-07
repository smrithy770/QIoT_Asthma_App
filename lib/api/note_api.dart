import 'dart:convert';

import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';
import 'package:asthmaapp/utils/encryption_util.dart';

class NoteApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addNotes(
      String userId, String title, String description, String feelRating,
      [String? accessToken]) async {
    final getAllNotesUrl = ApiConstants.getAllNotesUrl(userId);

    // Prepare the data to be encrypted
    final dataToSend = {
      'title': title,
      'description': description,
      'feelRating': feelRating,
    };

    // Convert the data to a JSON string and encrypt it
    final jsonString = jsonEncode(dataToSend); // Convert map to JSON
    final encryptedData =
        EncryptionUtil.encryptAES(jsonString); // Encrypt the JSON string

    // Send the encrypted data in the request
    final response = await _apiService.post(getAllNotesUrl, accessToken, {
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

  Future<Map<String, dynamic>> getAllNotes(String userId,
      [String? accessToken]) async {
    final getAllNotesUrl = ApiConstants.getAllNotesUrl(userId);
    final response = await _apiService.get(getAllNotesUrl, accessToken);

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

  Future<Map<String, dynamic>> getNotesById(String userId, String noteId,
      [String? accessToken]) async {
    final getNotesByIdUrl = ApiConstants.getNotesByIdUrl(userId, noteId);
    return _apiService.get(getNotesByIdUrl, accessToken);
  }

  Future<Map<String, dynamic>> editNoteById(String userId, String noteId,
      String title, String description, String painRating,
      [String? accessToken]) async {
    final editNoteByIdUrl = ApiConstants.editNoteByIdUrl(userId, noteId);

    // Prepare the data to be encrypted
    final dataToSend = {
      'title': title,
      'description': description,
      'painRating': painRating,
    };

    // Convert the data to a JSON string and encrypt it
    final jsonString = jsonEncode(dataToSend); // Convert map to JSON
    final encryptedData =
        EncryptionUtil.encryptAES(jsonString); // Encrypt the JSON string

    // Send the encrypted data in the request
    final response = await _apiService.put(editNoteByIdUrl, accessToken, {
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

  Future<Map<String, dynamic>> deleteNoteById(String userId, String noteId,
      [String? accessToken]) async {
    final deleteNoteByIdUrl = ApiConstants.deleteNoteByIdUrl(userId, noteId);
    return _apiService.delete(
      deleteNoteByIdUrl,
      accessToken,
    );
  }
}
