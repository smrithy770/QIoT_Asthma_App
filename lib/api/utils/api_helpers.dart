import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  // Method to handle common headers for API requests
  static Map<String, String> buildHeaders([String? accessToken]) {
    return {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }

  // Method to parse the API response
  static dynamic parseResponse(http.Response response) {
    final String responseBody = response.body;
    try {
      return json.decode(responseBody);
    } catch (e) {
      return responseBody; // Return as string if not JSON
    }
  }

  // Method to handle API errors
  static void handleError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      switch (response.statusCode) {
        case 400:
          throw Exception('Bad request: ${response.body}');
        case 401:
          throw Exception('Unauthorized: ${response.body}');
        case 403:
          throw Exception('Forbidden: ${response.body}');
        case 404:
          throw Exception('Not found: ${response.body}');
        case 500:
          throw Exception('Internal server error: ${response.body}');
        default:
          throw Exception('Unknown error: ${response.body}');
      }
    }
  }
}
