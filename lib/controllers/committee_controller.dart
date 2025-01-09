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
  Future<List<Map<String, dynamic>>> getCommitteePresidium(int term, String? code) async {
    final String url = code == null || code == "łącznie"
        ? 'https://api.sejm.gov.pl/sejm/term$term/committees'
        : 'https://api.sejm.gov.pl/sejm/term$term/committees/$code';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load committee data');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final uniqueMembers = <String>{};
    final clubs = <String, List<String>>{};
    final peoples = <String, int>{};
    final functions = <String, Map<String, String>>{};

    if (code == null || code == "łącznie") {
      for (final committee in data) {
        for (final member in committee['members']) {
          if (member['club'] != null) {
            clubs.putIfAbsent(member['club'], () => []);
            if (!clubs[member['club']]!.contains(member['lastFirstName'])) {
              clubs[member['club']]!.add(member['lastFirstName']);
            }
          }
          peoples[member['lastFirstName']] = (peoples[member['lastFirstName']] ?? 0) + 1;

          // Adding function to the map
          if (member['function'] != null) {
            functions[member['lastFirstName']] = {
              'club': member['club'] ?? 'N/A',
              'function': member['function'] ?? 'N/A',
            };
          }
        }
      }
    } else {
      for (final member in data['members']) {
        if (member['club'] != null) {
          clubs.putIfAbsent(member['club'], () => []);
          clubs[member['club']]!.add(member['lastFirstName']);
        }
        peoples[member['lastFirstName']] = (peoples[member['lastFirstName']] ?? 0) + 1;

        // Adding function to the map
        if (member['function'] != null) {
          functions[member['lastFirstName']] = {
            'club': member['club'] ?? 'N/A',
            'function': member['function'] ?? 'N/A',
          };
        }
      }
    }

    return [
      {
        'clubs': clubs,
        'members': peoples,
        'functions': functions,
      }
    ];
  }




}