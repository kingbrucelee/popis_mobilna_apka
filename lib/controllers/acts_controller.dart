import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/act.dart';

class ActsController {
  final String baseUrl = "https://api.sejm.gov.pl";

  Future<List<Act>> getAllActsForYear(int year) async {
    final url = Uri.parse("$baseUrl/eli/acts/DU/$year");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)); // Obsługa polskich znaków
      final List<dynamic> items = data['items'] ?? [];

      // Tworzenie listy aktów prawnych
      return items
          .map((item) => Act(
        title: item['title'] ?? 'Brak tytułu',
        type: item['type'] ?? 'Nieznany typ',
      ))
          .toList();
    } else {
      throw Exception('Błąd podczas pobierania danych: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getProcessDetails(int term, String processNumber) async {
    final url = Uri.parse("$baseUrl/sejm/term$term/processes/$processNumber");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)); // Obsługa polskich znaków
    } else {
      throw Exception('Błąd podczas pobierania szczegółów procesu: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getLegislativeProcesses(int term) async {
    final url = Uri.parse("$baseUrl/sejm/term$term/processes");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)); // Obsługa polskich znaków
    } else {
      throw Exception('Błąd podczas pobierania procesów: ${response.statusCode}');
    }
  }
}
