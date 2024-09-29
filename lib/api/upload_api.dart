import 'dart:io';

import 'package:asthmaapp/api/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class UploadApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> uploadSteroidCard(String id, String? file,
      [String? accessToken]) async {
    print('file: $file');
    final uploadSteroidCardUrl = ApiConstants.uploadSteroidCardUrl(id);
    return _apiService.post(
      uploadSteroidCardUrl,
      accessToken,
      {},
      file: file != null ? File(file) : null,
    );
  }
}
