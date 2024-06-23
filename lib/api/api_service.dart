import 'dart:convert';
import 'package:asthmaapp/api/utils/api_helpers.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> get(String endpoint, String? accessToken) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = ApiHelper.buildHeaders(accessToken);
    final response = await http.get(url, headers: headers);
    ApiHelper.handleError(response);
    return ApiHelper.parseResponse(response);
  }

  Future<Map<String, dynamic>> post(
      String endpoint, String? accessToken, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    if (accessToken == null) {
      final headers = ApiHelper.buildHeaders();
      final response =
          await http.post(url, headers: headers, body: json.encode(data));
      ApiHelper.handleError(response);
      return ApiHelper.parseResponse(response);
    } else {
      final headers = ApiHelper.buildHeaders(accessToken);
      final response =
          await http.post(url, headers: headers, body: json.encode(data));
      ApiHelper.handleError(response);
      return ApiHelper.parseResponse(response);
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = ApiHelper.buildHeaders(); // Adjust headers as needed
    final response = await http.delete(url, headers: headers);
    ApiHelper.handleError(response);
    return ApiHelper.parseResponse(response);
  }

  // Add more HTTP methods (GET, PUT, DELETE) as needed
}
