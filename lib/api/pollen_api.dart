import 'dart:convert';

import 'package:http/http.dart' as http;

class PollenDataApi {
  Future<Map<String, dynamic>?> getPollenData(
      double latitude, double longitude) async {
    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://pollen.googleapis.com/v1/forecast:lookup?key=AIzaSyAQVTLTQ27gisjnT1_7KaYpZAJoreM4pTo&location.longitude=$longitude&location.latitude=$latitude&days=1'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    String responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      try {
        if (responseBody.isNotEmpty) {
          Map<String, dynamic>? jsonResponse = json.decode(responseBody);
          if (jsonResponse != null) {
            // print(
            //     'Pollen Data: ${jsonResponse['dailyInfo'][0]['pollenTypeInfo']}');
            return jsonResponse;
          } else {
            print('Failed to decode JSON response');
            return null;
          }
        } else {
          print('Response body is empty or null');
          return null;
        }
      } catch (e) {
        print('Error decoding JSON or accessing token: $e');
        return null;
      }
    } else {
      print("Getting Pollen Data failed: ${response.reasonPhrase}");
      return null;
    }
  }
}
