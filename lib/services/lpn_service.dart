import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lpn.dart';
import '../configuration/environment_config.dart';


class LpnService {
  final String baseUrl = '${EnvironmentConfig.apiBaseUrl}lpn';
  final String addLPNUrl = '${EnvironmentConfig.apiBaseUrl}lpn/new';

// Function to fetch all LPNs
  Future<List<Lpn>> fetchAllLpns() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse as List<dynamic>;
      return data.map((json) => Lpn.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load LPNs');
    }
  }

  bool isLpnExists(String tagID, List<Lpn> allLpns) {
    // Iterate over allLpns and check if any Lpn's tagID matches the given tagID
    return allLpns.any((lpn) => lpn.tagID == tagID);
  }


  // Function to add a new LPN
  Future<void> addNewLpn(Lpn newLpn) async {
    final url = Uri.parse(addLPNUrl);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization' : 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuY3QwMzExOTRAaWNsb3VkLmNvbSIsImlhdCI6MTc1NTI4Mjg1OSwiZXhwIjoxNzU1MzE4ODU5fQ.Efyn0w4UyYjaPZaTCACDhocZ4qLoui6bEXNEy4KCXmo'
      },
      body: jsonEncode(newLpn.toLPNRequestDtoJson()), // Convert LPN object to JSON
    );

    if (response.statusCode == 200) {
      // Successfully added the LPN
      print('LPN added successfully: ${response.body}');
    } else {
      // Handle errors
      throw Exception('Failed to add LPN: ${response.body}');
    }
  }

}