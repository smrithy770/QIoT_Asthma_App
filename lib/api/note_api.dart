import 'package:asthmaapp/services/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class NoteApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addNotes(
      String userId, String title, String description, String feelRating,
      [String? accessToken]) async {
    final getAllNotesUrl = ApiConstants.getAllNotesUrl(userId);
    return _apiService.post(getAllNotesUrl, accessToken, {
      'title': title,
      'description': description,
      'feelRating': feelRating,
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
    return _apiService.put(
      editNoteByIdUrl,
      {
        'title': title,
        'description': description,
        'painRating': painRating,
      },
      accessToken,
    );
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
