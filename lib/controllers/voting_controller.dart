import 'package:http/http.dart' as http;
import 'dart:convert';

class VotingController {
  final String baseUrl = 'https://api.sejm.gov.pl/sejm';

  Future<List<Map<String, dynamic>>> getMps(int term) async {
    final response = await http.get(Uri.parse('$baseUrl/term$term/MP'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load MPs');
    }
  }

  Future<List<int>> getProceedingNumbers(int term) async {
    final response = await http.get(Uri.parse('$baseUrl/term$term/votings'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      Set<int> proceedingNumbers = {};
      for (var voting in data) {
        proceedingNumbers.add(voting['proceeding']);
      }
      return proceedingNumbers.toList()..sort();
    } else {
      throw Exception('Failed to load proceeding numbers');
    }
  }

  Future<List<String>> getVotingDates(int term, int proceedingNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/term$term/votings/$proceedingNumber'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      Set<String> votingDates = {};
      for (var voting in data) {
        votingDates.add(voting['date']);
      }
      return votingDates.toList()..sort();
    } else {
      throw Exception('Failed to load voting dates');
    }
  }

  Future<List<Map<String, dynamic>>> getVotingDetails(int term, int mpId, int proceedingNumber, String date) async {
    final response = await http.get(Uri.parse('$baseUrl/term$term/MP/$mpId/votings/$proceedingNumber/$date'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load voting details');
    }
  }
}