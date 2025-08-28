import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configuration/environment_config.dart';
import '../models/component.dart';

class ComponentService {
  final String baseUrl = '${EnvironmentConfig.apiBaseUrl}component/inbound';

  // Function to fetch all LPNs
  Future<List<Component>> fetchAllComponents() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse as List<dynamic>;
      return data.map((json) => Component.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Component? getSkuByUpc(String upc, List<Component> components) {
    // Search for a component that matches the given UPC
    final Component component = components.firstWhere(
          (component) => component.upc == upc
    );
    // Return the SKU if a match is found, otherwise null
  return component;
  }
}