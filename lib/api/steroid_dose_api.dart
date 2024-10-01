import 'dart:io';

import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class SteroidDoseApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addSteroidDose(String userId,
      int steroidDoseValue, Map<String, dynamic> location, int month, int year,
      [String? accessToken]) async {
    final addSteroidDoseUrl = ApiConstants.addSteroidDoseUrl(userId);
    return _apiService.post(addSteroidDoseUrl, accessToken, {
      'steroidDoseValue': steroidDoseValue,
      'location': location,
      'month': month,
      'year': year,
    });
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
    final getSteroidDoseHistoryUrl = ApiConstants.getSteroidDoseHistoryUrl(userId, month, year);
    return _apiService.get(getSteroidDoseHistoryUrl, accessToken);
  }
}
