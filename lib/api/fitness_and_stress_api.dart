import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class FitnessAndStressApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addFitnessAndStress(
      String userId,
      String fitness,
      String stress,
      Map<String, dynamic> location,
      int month,
      int year,
      [String? accessToken]) async {
    final addFitnessandStressUrl = ApiConstants.addFitnessandStressUrl(userId);
    return _apiService.post(addFitnessandStressUrl, accessToken, {
      'fitness': fitness,
      'stress': stress,
      'location': location,
      'month': month,
      'year': year,
    });
  }

  Future<Map<String, dynamic>> getFitnessAndStressHistory(
      String userId, int month, int year,
      [String? accessToken]) async {
    final getFitnessandStressHistoryUrl =
        ApiConstants.getFitnessandStressHistoryUrl(userId, month, year);
    return _apiService.get(getFitnessandStressHistoryUrl, accessToken);
  }
}
