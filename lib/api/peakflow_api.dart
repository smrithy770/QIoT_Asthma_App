import 'package:asthmaapp/api/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class PeakflowApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addPeakflow(
      String userId, int peakflowValue, int month, int year,
      [String? accessToken]) async {
    final getAllNotesUrl = ApiConstants.getAllNotesUrl(userId);
    return _apiService.post(getAllNotesUrl, accessToken, {
      'peakflowValue': peakflowValue,
      'month': month,
      'year': year,
    });
  }

  Future<Map<String, dynamic>> getAllNotes(String userId,
      [String? accessToken]) async {
    final getAllNotesUrl = ApiConstants.getAllNotesUrl(userId);
    return _apiService.get(getAllNotesUrl, accessToken);
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
    return _apiService.put(editNoteByIdUrl, accessToken, {
      'title': title,
      'description': description,
      'painRating': painRating,
    });
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
