import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mp.dart'; // Dodany import modelu Mp

class CommitteeService {
  // Fetch committees for a given term
  Future<List<Mp>> getMps(int term) async {
    final response =
        await http.get(Uri.parse('https://api.sejm.gov.pl/sejm/term$term/MP'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((mpJson) => Mp.fromJson(mpJson)).toList();
    } else {
      throw Exception('Failed to load MPs');
    }
  }

  Future<List<dynamic>> getCommittees(int term) async {
    final response = await http
        .get(Uri.parse('https://api.sejm.gov.pl/sejm/term$term/committees'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } else {
      throw Exception('Failed to load committees');
    }
  }

  // Fetch sittings for a committee
  Future<List<dynamic>> getSittings(int term, String committeeCode) async {
    final response = await http.get(Uri.parse(
        'https://api.sejm.gov.pl/sejm/term$term/committees/$committeeCode/sittings'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } else {
      throw Exception('Failed to load sittings');
    }
  }

  // Get future sitting date(s) for a committee
  // If returnList == false, returns a single DateTime (the closest future sitting date)
  // If returnList == true, returns a List<String> of future sitting dates
  Future<dynamic> getCommitteeFutureSitting(int term, String code, int time,
      {bool returnList = false}) async {
    final response = await http.get(Uri.parse(
        'https://api.sejm.gov.pl/sejm/term$term/committees/$code/sittings'));

    if (response.statusCode != 200) {
      return "wystąpił błąd";
    }

    final committee =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    List<String> dates = [];
    final today = DateTime.now().subtract(Duration(days: time)).toUtc();

    // Reverse iterate to find future dates
    for (var setting in committee.reversed) {
      final dateStr = setting['date'] as String;
      final date = DateTime.parse(dateStr).toUtc();
      if (date.isAfter(today) || date.isAtSameMomentAs(today)) {
        if (!returnList) {
          return date;
        } else {
          dates.add(date.toIso8601String().split('T').first);
        }
      }
    }

    if (returnList && dates.isNotEmpty) {
      return dates;
    }

    return null;
  }

  // Get the last N committee sitting dates
  Future<dynamic> getLastNSittingDates(
      String committeeCode, int numberOfSitting, int term) async {
    final response = await http.get(Uri.parse(
        'https://api.sejm.gov.pl/sejm/term$term/committees/$committeeCode/sittings'));

    if (response.statusCode != 200) {
      return "coś poszło nie tak";
    }

    final committee =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    List<String> datesList = [];
    int settingsCounter = 0;

    for (var setting in committee.reversed) {
      final date = setting['date'];
      final numSpotkania = setting['num'];
      datesList.add("$date. Numer spotkania komisji: $numSpotkania");
      settingsCounter += 1;
      if (settingsCounter >= numberOfSitting) {
        return datesList;
      }
    }

    return datesList;
  }

  // Get committee stats (clubs and members)
  // If code is null or 'łącznie', aggregates stats for all committees
  Future<Map<String, dynamic>> getCommitteeStats(int term,
      {String? code}) async {
    late String apiUrl;
    if (code == null || code == "łącznie") {
      apiUrl = 'https://api.sejm.gov.pl/sejm/term$term/committees';
    } else {
      apiUrl = 'https://api.sejm.gov.pl/sejm/term$term/committees/$code';
    }

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load committee stats');
    }

    final API_data = jsonDecode(utf8.decode(response.bodyBytes));

    Map<String, List<String>> clubs = {};
    Map<String, int> peoples = {};

    if (code == null || code == "łącznie") {
      // API_data should be List if it's all committees
      if (API_data is List) {
        for (var committee in API_data) {
          for (var member in committee['members']) {
            final club = member['club'] as String;
            final name = member['lastFirstName'] as String;
            clubs.putIfAbsent(club, () => []);
            if (!clubs[club]!.contains(name)) {
              clubs[club]!.add(name);
            }
            peoples[name] = (peoples[name] ?? 0) + 1;
          }
        }
      }
    } else {
      // Single committee
      if (API_data is Map) {
        for (var member in API_data['members']) {
          final club = member['club'] as String;
          final name = member['lastFirstName'] as String;
          clubs.putIfAbsent(club, () => []);
          clubs[club]!.add(name);
          peoples[name] = (peoples[name] ?? 0) + 1;
        }
      }
    }

    return {
      'clubs': clubs,
      'members': peoples,
    };
  }

  // Get committee member details (like education, district, or profession)
  Future<Map<String, Map<String, int>>> getCommitteeMemberDetails(
      Map<String, List<String>> committee,
      {int term = 10,
      String searchedInfo = 'edukacja'}) async {
    final response =
        await http.get(Uri.parse('https://api.sejm.gov.pl/sejm/term$term/MP'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load MP data');
    }

    final MPs = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    Map<String, Map<String, int>> MPsEducation = {};

    for (var party in committee.keys) {
      Map<String, int> educations = {};
      for (var person in committee[party]!) {
        final filteredMPs =
            MPs.where((mp) => mp['lastFirstName'] == person).toList();
        if (filteredMPs.isNotEmpty) {
          String educationOfMP = "";
          if (searchedInfo == 'edukacja') {
            // educationLevel
            educationOfMP =
                filteredMPs.map((mp) => mp['educationLevel']).join(", ");
          } else if (searchedInfo == 'okręg') {
            // districtName
            educationOfMP =
                filteredMPs.map((mp) => mp['districtName']).join(", ");
          } else if (searchedInfo == 'profesja') {
            // profession
            educationOfMP = filteredMPs
                .where((mp) => mp.containsKey('profession'))
                .map((mp) => mp['profession'])
                .join(", ");
          }

          educations[educationOfMP] = (educations[educationOfMP] ?? 0) + 1;
        }
      }
      MPsEducation[party] = educations;
    }

    return MPsEducation;
  }

  // Get committee member ages
  // Returns a tuple-like structure: { 'agesDataFrame': Map<String,List<int>>, 'MPsAge': Map<String,List<int>> }
  // For simplicity, we return the same data twice, as we have no DataFrame in Dart.
  Future<Map<String, dynamic>> getCommitteeMemberAges(
      Map<String, List<String>> committee,
      {int term = 10,
      String searchedInfo = 'birthDate'}) async {
    final response =
        await http.get(Uri.parse('https://api.sejm.gov.pl/sejm/term$term/MP'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load MP data');
    }

    final MPs = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

    DateTime currentTime = DateTime.now();
    if (term != 10) {
      // Get the end of term date
      final termResponse =
          await http.get(Uri.parse('https://api.sejm.gov.pl/sejm/term$term'));
      if (termResponse.statusCode == 200) {
        final termInfo = jsonDecode(termResponse.body);
        final endOfTerm = termInfo['to'] as String;
        currentTime = DateTime.parse(endOfTerm);
      }
    }

    Map<String, List<int>> MPsAge = {};

    for (var party in committee.keys) {
      List<int> ages = [];
      for (var person in committee[party]!) {
        final filteredMPs =
            MPs.where((mp) => mp['lastFirstName'] == person).toList();
        if (filteredMPs.isNotEmpty) {
          final mp = filteredMPs.first;
          final dateOfBirthStr = mp[searchedInfo] as String;
          final dateOfBirth = DateTime.parse(dateOfBirthStr);
          final ageInDays = currentTime.difference(dateOfBirth).inDays;
          final ageInYears = (ageInDays / 365).floor();
          ages.add(ageInYears);
        }
      }
      MPsAge[party] = ages;
    }

    // In Python code, it returns a DataFrame and a dict.
    // Here we just return two identical structures:
    return {
      'agesDataFrame': MPsAge,
      'MPsAge': MPsAge,
    };
  }
}
