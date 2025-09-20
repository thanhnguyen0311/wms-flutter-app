import 'dart:convert'; // For encoding the request body and decoding the response
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:shared_preferences/shared_preferences.dart';
import '../configuration/environment_config.dart'; // Import EnvironmentConfig for API base URL

class AuthService {
  final String baseUrl = '${EnvironmentConfig.apiBaseUrl}auth/login';

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final Map<String, String> requestBody = {
        'email': username,
        'password': password,
      };

      final http.Response response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final String token = response.body;

        if (token.isNotEmpty) {
          return {'token': token};
        } else {
          throw Exception('Empty token received');
        }
      } else {
        throw Exception(
            'Failed to login (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // Log the entire error for debugging
      print('Error during login: $e');
      throw Exception('An error occurred during login: $e');
    }
  }

  // Static function to retrieve the token from shared preferences
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

}