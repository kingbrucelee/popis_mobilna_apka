// controllers/seatsCalculator.dart

import 'package:flutter/foundation.dart';
import 'electionCalc.dart';
import 'electionCalc.dart' show CsvRow;

/// Klasa SeatsCalculator – front do obliczeń z ElectionCalc
class SeatsCalculator {
  /// Metoda do obliczania głosów z CSV (na potrzeby "Rzeczywiste") – zostaje po staremu
  static Map<String, dynamic> calculateVotes({
    required double votesNeeded,
    required double votesNeededForCoalition,
    required String year,
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

  /// Metoda do wyboru metod *dla 4 typów naraz* – zostawiamy starą
  /// Zwraca strukturę:
  /// {
  ///   "d'Hondt": {"PiS": X, "KO": Y, ...},
  ///   "Sainte-Laguë": {...},
  ///   ...
  /// }
  static Map<String, Map<String, int>> chooseMethodAll({
    required double PiS,
    required double KO,
    required double TD,
    required double Lewica,
    required double Konfederacja,
    required double Freq,
    required int seatsNum,
  }) {
    // Słownik partii
    List<String> qualifiedDictionary = [
      "PiS",
      "KO",
      "Trzecia Droga",
      "Lewica",
      "Konfederacja",
    ];

    // Odpowiednie głosy
    List<double> numberOfVotes = [
      PiS,
      KO,
      TD,
      Lewica,
      Konfederacja,
    ];

    // Liczymy 4 metody jednocześnie
    final allResults = ElectionCalc.chooseMethod(
      qualifiedDictionary: qualifiedDictionary,
      numberOfVotes: numberOfVotes,
      year: '2020',
      seatsNum: seatsNum,
    );

    return allResults;
  }

  /// NOWA METODA – do wyboru *pojedynczej* metody i otrzymania [MapMandatów, nextDiff, prevDiff].
  ///
  /// Wewnętrznie woła "specialChooseMethod" z electionCalc.dart.
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
    // Budujemy mapę głosów
    Map<String, double> voteDict = {
      "PiS": PiS,
      "KO": KO,
      "Trzecia Droga": TD,
      "Lewica": Lewica,
      "Konfederacja": Konfederacja,
    };

    // Wywołujemy specialChooseMethod
    final result = ElectionCalc.specialChooseMethod(
      voteDict: voteDict,
      seatsNum: seatsNum,
      method: method,
      freq: Freq,
    );
    return result; // [mapSeats, differencesNext, differencesPrev]
  }
}
