import 'package:flutter/foundation.dart';
import 'electionCalc.dart' show CsvRow, ElectionCalc;

class SeatsCalculator {
  /// Metoda do obliczania głosów z CSV (na potrzeby "Rzeczywiste")
  static Map<String, dynamic> calculateVotes({
    required double votesNeeded,
    required double votesNeededForCoalition,
    required List<CsvRow> csvData,
    List<String> exemptedParties = const [],
  }) {
    return ElectionCalc.calculateVotesFromCsv(
      csvData: csvData,
      threshold: votesNeeded,
      coalitionThreshold: votesNeededForCoalition,
      exemptedParties: exemptedParties,
    );
  }

  /// Liczy 4 metody naraz (bez podziału na okręgi – wszystko w jednym worku).
  static Map<String, Map<String, int>> chooseMethodAll({
    required double PiS,
    required double KO,
    required double TD,
    required double Lewica,
    required double Konfederacja,
    required int seatsNum,
  }) {
    final qualifiedDictionary = <String>[
      "PiS",
      "KO",
      "Trzecia Droga",
      "Lewica",
      "Konfederacja",
    ];
    final numberOfVotes = <double>[PiS, KO, TD, Lewica, Konfederacja];

    final allResults = ElectionCalc.chooseMethod(
      qualifiedDictionary: qualifiedDictionary,
      numberOfVotes: numberOfVotes,
      year: '', // tu ewentualnie np. "2023"
      seatsNum: seatsNum,
    );
    return allResults;
  }

  /// NOWA METODA – analog "chooseMethods" do wywołania *pojedynczej* metody.
  /// Zwraca: [mapMandatów, nextDiff, prevDiff].
  static List<dynamic> chooseMethods({
    required double PiS,
    required double KO,
    required double TD,
    required double Lewica,
    required double Konfederacja,
    required double Freq,
    required int seatsNum,
    required String method,
  }) {
    final voteDict = <String, double>{
      "PiS": PiS,
      "KO": KO,
      "Trzecia Droga": TD,
      "Lewica": Lewica,
      "Konfederacja": Konfederacja,
    };

    // Korzystamy z "specialChooseMethod" z `electionCalc.dart`
    final result = ElectionCalc.specialChooseMethod(
      voteDict: voteDict,
      seatsNum: seatsNum,
      method: method,
      freq: Freq,
    );
    return result; // [mapSeats, differencesNext, differencesPrev]
  }

  /// Przykład nowej metody liczącej PO OKRĘGACH, analogicznie do Pythona:
  static Map<String, Map<String, int>> chooseMethodByAllDistricts({
    required List<String> qualifiedParties,
    required List<CsvRow> csvData,
    required List<int> seatsPerDistrict,
    required String year,
  }) {
    return ElectionCalc.chooseMethodByDistricts(
      csvData: csvData,
      qualifiedParties: qualifiedParties,
      seatsPerDistrict: seatsPerDistrict,
      year: year,
    );
  }
}
