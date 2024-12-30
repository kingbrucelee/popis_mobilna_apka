import 'dart:convert';
import 'package:http/http.dart' as http;

class LegislativeController {
  final String baseUrl = "https://api.sejm.gov.pl";

  Future<List<Map<String, dynamic>>> fetchLegislativeProcesses(int term) async {
    final response = await http.get(Uri.parse('$baseUrl/sejm/term$term/processes'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load legislative processes');
    }
  }

  Future<Map<String, dynamic>> fetchProcessDetails(int term, String processNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/sejm/term$term/processes/$processNumber'));
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load process details');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLatestLaws(int year) async {
    final response = await http.get(Uri.parse('$baseUrl/eli/acts/DU/$year'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes))['items'] ?? []);
    } else {
      throw Exception('Failed to load laws');
    }
  }
}
