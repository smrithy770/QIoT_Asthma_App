import 'dart:io';

import 'package:asthmaapp/api/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';
import 'package:asthmaapp/main.dart';

class UploadApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

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
}
