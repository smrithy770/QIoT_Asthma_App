import 'dart:convert';
import 'dart:io';
import 'package:asthmaapp/api/auth_api.dart';
import 'package:asthmaapp/api/utils/api_helpers.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/screens/authentication_screens/signin_screen/signin_screen.dart';
import 'package:asthmaapp/services/token_refresh_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:realm/realm.dart';

class ApiService {
  final String baseUrl;
  


  ApiService(
      {required this.baseUrl});

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    if (results.isNotEmpty) {
      return results[0];
    }
    return null;
  }

  Future<Map<String, dynamic>> get(String endpoint, String? accessToken) async {
    final url = Uri.parse('$baseUrl$endpoint');
    logger.d("url is ${url}");

    final headers = ApiHelper.buildHeaders(accessToken);
 
    var response = await http.get(url, headers: headers);
    logger.d("the response is");
    logger.d(response.statusCode);

    if (response.statusCode == 403) {
      await TokenRefreshService().refreshToken();

      var newAccessToken = TokenRefreshService().userModel!.accessToken;
      var newheader = ApiHelper.buildHeaders(newAccessToken);

      response = await http.get(url, headers: newheader);
    }
    // var response = await client.get(url);

    ApiHelper.handleError(response);
    

    return ApiHelper.parseResponse(response);
  }

  Future<Map<String, dynamic>> post(
      String endpoint, String? accessToken, Map<String, dynamic> data,
      {File? file}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    if (accessToken == null) {
      final headers = ApiHelper.buildHeaders();
      var response =
          await http.post(url, headers: headers, body: json.encode(data));

      logger.d('response is ${response.statusCode}');
      //call refresh
      if (response.statusCode == 403) {
        await TokenRefreshService().refreshToken();

        var newAccessToken = TokenRefreshService().userModel!.accessToken;
        var newheader = ApiHelper.buildHeaders(newAccessToken);
        response =
            await http.post(url, headers: newheader, body: json.encode(data));
      }

      ApiHelper.handleError(response);
      return ApiHelper.parseResponse(response);
    } else {
      if (file != null) {
        // Multipart request for file upload
        var request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $accessToken';
        logger.d('file: ${file.path}');
        // Add file
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        // Send request
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        return ApiHelper.parseResponse(
            http.Response(responseBody, response.statusCode));
      } else {
        // Standard JSON request
        final headers = ApiHelper.buildHeaders(accessToken);
        var response =
            await http.post(url, headers: headers, body: json.encode(data));
        logger.d(response.statusCode);
        if (response.statusCode == 401) {
          
          var userModel = TokenRefreshService().userModel;
          var userid = TokenRefreshService().userModel?.userId;
          var devicetoken = TokenRefreshService().deviceToken;
          var devicetype = TokenRefreshService().deviceType;
          var realm = TokenRefreshService().realm;
          
          await _signOut(userModel, userid, realm, devicetoken, devicetype);
          logger.d("Calling sign out function");

          // AuthApi().signout(userId)
        } else if (response.statusCode == 403) {
          await TokenRefreshService().refreshToken();
          

          var newAccessToken = TokenRefreshService().userModel!.accessToken;
          var newheader = ApiHelper.buildHeaders(newAccessToken);
          response =
              await http.post(url, headers: newheader, body: json.encode(data));
        }

        
        logger.d(response.statusCode);
        logger.d(response.body);

        ApiHelper.handleError(response);
        return ApiHelper.parseResponse(response);
      }
    }
  }

  
  Future<Map<String, dynamic>> put(
    String endpoint,
    String? accessToken,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    if (accessToken == null) {
      final headers = ApiHelper.buildHeaders();
      var response =
          await http.put(url, headers: headers, body: json.encode(data));

      if (response.statusCode == 403) {
        await TokenRefreshService().refreshToken();
       

        var newAccessToken = TokenRefreshService().userModel!.accessToken;
        var newheader = ApiHelper.buildHeaders(newAccessToken);
        response =
            await http.put(url, headers: newheader, body: json.encode(data));
      }

      ApiHelper.handleError(response);
      return ApiHelper.parseResponse(response);
    } else {
      final headers = ApiHelper.buildHeaders(accessToken);
      var response =
          await http.put(url, headers: headers, body: json.encode(data));

      if (response.statusCode == 403) {
        await TokenRefreshService().refreshToken();
        var newAccessToken = TokenRefreshService().userModel!.accessToken;
        var newheader = ApiHelper.buildHeaders(newAccessToken);
        response =
            await http.put(url, headers: newheader, body: json.encode(data));
      }

      ApiHelper.handleError(response);
      return ApiHelper.parseResponse(response);
    }
  }

  Future<Map<String, dynamic>> delete(
      String endpoint, String? accessToken) async {
    final url = Uri.parse('$baseUrl$endpoint');
    if (accessToken == null) {
      final headers = ApiHelper.buildHeaders();
      var response = await http.delete(url, headers: headers);
     

      if (response.statusCode == 403) {
        await TokenRefreshService().refreshToken();
        var newAccessToken = TokenRefreshService().userModel!.accessToken;
        var newheader = ApiHelper.buildHeaders(newAccessToken);
        response = await http.delete(url, headers: newheader);
      }

      ApiHelper.handleError(response);
      return ApiHelper.parseResponse(response);
    } else {
      final headers = ApiHelper.buildHeaders(accessToken);
      var response = await http.delete(url, headers: headers);
      
      if (response.statusCode == 403) {
        await TokenRefreshService().refreshToken();
        var newAccessToken = TokenRefreshService().userModel!.accessToken;
        var newheader = ApiHelper.buildHeaders(newAccessToken);
        response = await http.delete(url, headers: newheader);
      }
      ApiHelper.handleError(response);
      return ApiHelper.parseResponse(response);
    }
  }

  // Add more HTTP methods (GET, PUT, DELETE) as needed



  Future<void> _signOut(
      var userModel, var userid, realm, var devicetoken, var devicetype) async {
    
    if (userModel != null) {
     
      try {
        // Sign out from the API
       
        final response = await AuthApi().signout(userid);
        final jsonResponse = response;
        final status = jsonResponse['status'];
        

        if (status == 200) {
          // Clear user data from Realm

          
          realm?.write(() {
            if (userModel != null) {
              realm?.delete<UserModel>(userModel!);
              logger.d('User has been successfully deleted from Realm.');
            }
          });

          
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => SigninScreen(
                realm: realm,
                deviceToken: devicetoken,
                deviceType: devicetype,
              ),
            ),
            (Route<dynamic> route) =>
                false, // Removes all routes from the stack
          );

          logger.d('User logged out successfully');
        } else {
          logger.d('Logout failed: ${jsonResponse['message']}');
        }
      } catch (e) {
        logger.d('Error during sign out: $e');
      }
    }
  }

}