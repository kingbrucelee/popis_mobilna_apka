import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> getClubs(int term) async {
  final response = await http.get(Uri.parse('https://api.sejm.gov.pl/sejm/term$term/clubs'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load clubs');
  }
}

Future<List<dynamic>> findMinimalCoalitions(int term, {int threshold = 231}) async {
  List<dynamic> clubs = await getClubs(term);
  clubs.sort((a, b) => b['membersCount'].compareTo(a['membersCount']));

  List<List<dynamic>> minimalCoalitions = [];

  for (int i = 1; i <= clubs.length; i++) {
    for (var coalition in combinations(clubs, i)) {
      int totalMPs = coalition.fold(0, (sum, club) => sum + club['membersCount'] as int);
      if (totalMPs >= threshold) {
        minimalCoalitions.add(coalition);
        break;
      }
    }
  }

  return minimalCoalitions;
}

Iterable<List<T>> combinations<T>(List<T> list, int k) sync* {
  if (k == 0) {
    yield [];
  } else {
    for (int i = 0; i <= list.length - k; i++) {
      for (var tail in combinations(list.sublist(i + 1), k - 1)) {
        yield [list[i], ...tail];
      }
    }
  }
}
