import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class SejmAPI {
  final String baseUrl = 'https://api.sejm.gov.pl/sejm';

  Future<http.Response> getClubs(int term) async {
    final url = Uri.parse('$baseUrl/term$term/clubs');
    return await http.get(url);
  }

  Future<Map<String, dynamic>> getClub(int term, String id) async {
    final url = Uri.parse('$baseUrl/term$term/clubs/$id');
    final response = await http.get(url);

    // Tu może się zdarzyć, że `response.bodyBytes` jest pusty
    // albo `jsonDecode(...)` zwróci null
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  Future<Uint8List> getClubLogo(int term, String id) async {
    final url = Uri.parse('$baseUrl/term$term/clubs/$id/logo');
    final response = await http.get(url);
    return response.bodyBytes;
  }

  /// Metoda wyszukująca minimalne koalicje
  /// [term] – numer kadencji, [threshold] – próg większości (np. 231),
  /// [maxCombinations] – maksymalny rozmiar grupy, do której ma sens rozpatrywać kombinacje.
  ///
  /// Zwraca listę list klubów (każda z list to jedna możliwa minimalna koalicja).
  Future<List<List<Map<String, dynamic>>>> findMinimalCoalitions({
    int term = 10,
    int threshold = 231,
    int? maxCombinations,
  }) async {
    final response = await getClubs(term);
    List<dynamic> clubs = jsonDecode(utf8.decode(response.bodyBytes));

    // Sortowanie – kluby z największą liczbą posłów najpierw
    clubs.sort((a, b) =>
        (b['membersCount'] as num).compareTo(a['membersCount'] as num));

    maxCombinations ??= clubs.length;

    List<List<Map<String, dynamic>>> minimalCoalitions = [];
    Set<Set<String>> minimalCoalitionNames = {};

    for (int coalitionSize = 1;
        coalitionSize <= clubs.length && coalitionSize <= maxCombinations;
        coalitionSize++) {
      // Generujemy wszystkie kombinacje klubów o wielkości `coalitionSize`
      Iterable<List<dynamic>> combinations =
          generateCombinations(clubs, coalitionSize);

      for (var coalition in combinations) {
        int totalMPs = coalition.fold<int>(
          0,
          (sum, club) => sum + (club['membersCount'] as int),
        );

        // Tworzymy Set<String> nazw (lub ID) klubów,
        // żeby później porównywać, czy dana koalicja nie jest już "zawarta" w innej
        Set<String> coalitionNames =
            coalition.map((club) => club['name'] as String).toSet();

        // Warunek: przekracza próg (231) i nie jest nadzbędna w innej dotychczas znalezionej
        if (totalMPs >= threshold &&
            !minimalCoalitionNames
                .any((existing) => existing.containsAll(coalitionNames))) {
          // Sprawdzamy minimalność: usunięcie któregokolwiek klubu powoduje spadek < threshold?
          bool isMinimal = true;
          for (var club in coalition) {
            int subsetMPs = coalition
                .where((c) => c != club)
                .fold<int>(0, (sum, c) => sum + (c['membersCount'] as int));

            if (subsetMPs >= threshold) {
              isMinimal = false;
              break;
            }
          }

          if (isMinimal) {
            minimalCoalitions.add(List<Map<String, dynamic>>.from(coalition));
            minimalCoalitionNames.add(coalitionNames);
          }
        }
      }
    }

    return minimalCoalitions;
  }

  /// Generator kombinacji (rekurencyjny)
  Iterable<List<T>> generateCombinations<T>(List<T> list, int size) sync* {
    if (size == 0) {
      yield [];
    } else {
      for (int i = 0; i < list.length; i++) {
        for (var combination
            in generateCombinations(list.sublist(i + 1), size - 1)) {
          yield [list[i], ...combination];
        }
      }
    }
  }

  /// Przykładowy print wszystkich koalicji w terminalu
  void printCoalitionsTable(List<List<Map<String, dynamic>>> coalitions) {
    print('Coalitions:');
    for (int i = 0; i < coalitions.length; i++) {
      final coalition = coalitions[i];
      final int totalMPs = coalition.fold<int>(
        0,
        (sum, club) => sum + (club['membersCount'] as int),
      );
      final String clubNames =
          coalition.map((club) => club['name'] as String).join(', ');
      print('Coalition ${i + 1}: Clubs: $clubNames, Total MPs: $totalMPs');
    }
  }
}

// --------------------------------------------------
// Szybki test w `main()`:
void main() async {
  final api = SejmAPI();
  final coalitions = await api.findMinimalCoalitions();
  api.printCoalitionsTable(coalitions);
}
