import 'dart:io';

import 'package:asthmaapp/api/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';
import 'package:asthmaapp/main.dart';

class SteroidDoseApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addSteroidDose(String userId,
      int steroidDoseValue, Map<String, dynamic> location, int month, int year,
      [String? accessToken]) async {
    final addSteroidDoseUrl = ApiConstants.addSteroidDoseUrl(userId);
    logger.d('Steroid Dose Value: $steroidDoseValue');
    return _apiService.post(addSteroidDoseUrl, accessToken, {
      'steroidDoseValue': steroidDoseValue,
      'location': location,
      'month': month,
      'year': year,
    });
  }

  Future<Map<String, dynamic>> uploadSteroidCard(String userId, String? file,
      [String? accessToken]) async {
    logger.d('file: $file');
    final uploadSteroidCardUrl = ApiConstants.uploadSteroidCardUrl(userId);
    return _apiService.post(
      uploadSteroidCardUrl,
      accessToken,
      {},
      file: file != null ? File(file) : null,
    );
  }

  Future<Map<String, dynamic>> getAllSteroidDose(
      String userId, int month, int year,
      [String? accessToken]) async {
    final getAllSteroidDoseUrl = ApiConstants.getAllSteroidDoseUrl(userId);
    return _apiService.get(getAllSteroidDoseUrl, accessToken);
  }
}
