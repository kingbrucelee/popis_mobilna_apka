import 'dart:convert';
import 'package:http/http.dart' as http;

class CommitteeController {
  final String baseUrl = "https://api.sejm.gov.pl/sejm";

  /// Fetches the list of committees for a specific term
  Future<List<Map<String, dynamic>>> getCommittees(int term) async {
    final response = await http.get(Uri.parse('$baseUrl/term$term/committees'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to fetch committees');
    }
  }

  /// Fetches sittings for a specific committee and term
  Future<List<Map<String, dynamic>>> getSittings(int term, String committeeCode) async {
    final response = await http.get(Uri.parse('$baseUrl/term$term/committees/$committeeCode/sittings'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to fetch sittings');
    }
  }

  /// Fetches recent sittings (last N) for a specific committee
  Future<List<String>> getLastNSittings(int term, String committeeCode, int count) async {
    final response = await http.get(Uri.parse('$baseUrl/term$term/committees/$committeeCode/sittings'));

    if (response.statusCode == 200) {
      final sittings = List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
      return sittings.reversed
          .take(count)
          .map((sitting) => "${sitting['date']}. Numer posiedzenia: ${sitting['num']}")
          .toList();
    } else {
      throw Exception('Failed to fetch last N sittings');
    }
  }

  /// Fetches details of a specific sitting
  Future<Map<String, dynamic>> getSittingDetails(int term, String committeeCode, String sittingNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/term$term/committees/$committeeCode/sittings/$sittingNumber'));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to fetch sitting details');
    }
  }

  /// Fetches future sittings for a committee within the next X days
  Future<List<String>> getFutureSittings(int term, String code, int days) async {
    final response = await http.get(Uri.parse('$baseUrl/term$term/committees/$code/sittings'));

    if (response.statusCode == 200) {
      final sittings = List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
      final today = DateTime.now();
      final thresholdDate = today.add(Duration(days: days));

      return sittings
          .where((sitting) => DateTime.parse(sitting['date']).isAfter(today) &&
          DateTime.parse(sitting['date']).isBefore(thresholdDate))
          .map((sitting) => sitting['date'] as String)
          .toList();
    } else {
      throw Exception('Failed to fetch future sittings');
    }
  }

  /// Fetches details of a specific committee (if required)
  Future<Map<String, dynamic>> getCommitteeDetails(int term, String committeeCode) async {
    final response = await http.get(Uri.parse('$baseUrl/term$term/committees/$committeeCode'));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to fetch committee details');
    }
  }

  /// Fetches presidium of a specific committee
  Future<List<Map<String, dynamic>>> getCommitteePresidium(int term, String committeeCode) async {
    final response = await http.get(Uri.parse('$baseUrl/term$term/committees/$committeeCode/presidium'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to fetch committee presidium');
    }
  }
}