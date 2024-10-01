import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class PeakflowApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addPeakflow(String userId, int peakflowValue,
      Map<String, dynamic> location, int month, int year,
      [String? accessToken]) async {
    final addPeakflowUrl = ApiConstants.addPeakflowUrl(userId);
    return _apiService.post(addPeakflowUrl, accessToken, {
      'peakflowValue': peakflowValue,
      'location': location,
      'month': month,
      'year': year,
    });
  }

  Future<Map<String, dynamic>> getPeakflowHistory(
      String userId, int month, int year,
      [String? accessToken]) async {
    final getPeakflowHistoryUrl = ApiConstants.getPeakflowHistoryUrl(userId, month, year);
    return _apiService.get(getPeakflowHistoryUrl, accessToken);
  }
}
