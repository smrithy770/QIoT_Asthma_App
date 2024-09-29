import 'package:asthmaapp/api/api_service.dart';
import 'package:asthmaapp/api/utils/api_constants.dart';

class NoteApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addNotes(
      String id, String title, String description, String feelRating,
      [String? accessToken]) async {
    final getAllNotesUrl = ApiConstants.getAllNotesUrl(id);
    return _apiService.post(getAllNotesUrl, accessToken, {
      'title': title,
      'description': description,
      'feelRating': feelRating,
    });
  }

  Future<Map<String, dynamic>> getAllNotes(String id,
      [String? accessToken]) async {
    final getAllNotesUrl = ApiConstants.getAllNotesUrl(id);
    return _apiService.get(getAllNotesUrl, accessToken);
  }

  Future<Map<String, dynamic>> getNotesById(String id, String noteId,
      [String? accessToken]) async {
    final getNotesByIdUrl = ApiConstants.getNotesByIdUrl(id, noteId);
    return _apiService.get(getNotesByIdUrl, accessToken);
  }

  Future<Map<String, dynamic>> editNoteById(String id, String noteId,
      String title, String description, String painRating,
      [String? accessToken]) async {
    final editNoteByIdUrl = ApiConstants.editNoteByIdUrl(id, noteId);
    return _apiService.put(editNoteByIdUrl, accessToken, {
      'title': title,
      'description': description,
      'painRating': painRating,
    });
  }

  Future<Map<String, dynamic>> deleteNoteById(String id, String noteId,
      [String? accessToken]) async {
    final deleteNoteByIdUrl = ApiConstants.deleteNoteByIdUrl(id, noteId);
    return _apiService.delete(
      deleteNoteByIdUrl,
      accessToken,
    );
  }
}
