// controllers/electionCalc.dart

import 'dart:math' as math;

/// Model jednego wiersza z CSV (np. dane o jednym okręgu)
class CsvRow {
  final Map<String, double> data;
  CsvRow(this.data);
}

/// Klasa ElectionCalc zawiera metody do obliczeń wyborczych
class ElectionCalc {
  /// -----------------------------------------------------------------------
  /// NOWA METODA "specialChooseMethod"
  /// -----------------------------------------------------------------------
  /// Zwraca: [mapMandatów, setPartiiZmieniajacychPrzy(+1), setPartiiZmieniajacychPrzy(-1)].
  ///
  /// Wewnątrz wywołuje jedną z metod: dhont, sainteLague, hareDrop
  /// i dodatkowo liczy liczbę mandatów przy (+1) i (-1).
  static List<dynamic> specialChooseMethod({
    required Map<String, double> voteDict,
    required int seatsNum,
    required String method,
    required double freq,
  }) {
    // Przygotuj słowniki (dla seatsNum, seatsNum+1, seatsNum-1)
    final normalSeats = <String, int>{};
    final nextSeatsMap = <String, int>{};
    final prevSeatsMap = <String, int>{};

    for (final party in voteDict.keys) {
      normalSeats[party] = 0;
      nextSeatsMap[party] = 0;
      prevSeatsMap[party] = 0;
    }

    // Bezpiecznik: jeśli brak głosów lub seatsNum <= 0, zwracamy puste
    final totalVotes = voteDict.values.fold(0.0, (p, c) => p + c);
    if (totalVotes == 0 || seatsNum <= 0) {
      return [normalSeats, <String>{}, <String>{}];
    }

    // Oblicz główne seats
    switch (method) {
      case "d'Hondt":
        dhont(normalSeats, voteDict, seatsNum);
        dhont(nextSeatsMap, voteDict, seatsNum + 1);
        if (seatsNum - 1 > 0) {
          dhont(prevSeatsMap, voteDict, seatsNum - 1);
        }
        break;
      case "Sainte-Laguë":
        sainteLague(normalSeats, voteDict, seatsNum);
        sainteLague(nextSeatsMap, voteDict, seatsNum + 1);
        if (seatsNum - 1 > 0) {
          sainteLague(prevSeatsMap, voteDict, seatsNum - 1);
        }
        break;
      case "Kwota Hare’a (metoda największych reszt)":
        hareDrop(normalSeats, voteDict, seatsNum, freq, biggest: true);
        hareDrop(nextSeatsMap, voteDict, seatsNum + 1, freq, biggest: true);
        if (seatsNum - 1 > 0) {
          hareDrop(prevSeatsMap, voteDict, seatsNum - 1, freq, biggest: true);
        }
        break;
      case "Kwota Hare’a (metoda najmniejszych reszt)":
        hareDrop(normalSeats, voteDict, seatsNum, freq, biggest: false);
        hareDrop(nextSeatsMap, voteDict, seatsNum + 1, freq, biggest: false);
        if (seatsNum - 1 > 0) {
          hareDrop(prevSeatsMap, voteDict, seatsNum - 1, freq, biggest: false);
        }
        break;
      default:
        // Domyślnie d'Hondt
        dhont(normalSeats, voteDict, seatsNum);
        dhont(nextSeatsMap, voteDict, seatsNum + 1);
        if (seatsNum - 1 > 0) {
          dhont(prevSeatsMap, voteDict, seatsNum - 1);
        }
        break;
    }

    // Policz różnice
    final differencesNext = <String>{};
    final differencesPrev = <String>{};

    for (final party in normalSeats.keys) {
      if (normalSeats[party] != nextSeatsMap[party]) {
        differencesNext.add(party);
      }
      if (normalSeats[party] != prevSeatsMap[party]) {
        differencesPrev.add(party);
      }
    }

    return [normalSeats, differencesNext, differencesPrev];
  }

  /// Funkcja wybierająca metodę podziału *dla wszystkich* (dhont, sainte-lague, hare, hareSmall)
  /// i zwracająca wyniki w postaci Map -> { "d'Hondt": {...}, "Sainte-Laguë": {...}, ...}
  static Map<String, Map<String, int>> chooseMethod({
    required List<String> qualifiedDictionary,
    required List<double> numberOfVotes,
    required String year,
    required int seatsNum,
  }) {
    // Tworzenie mapy {partia -> liczba głosów}
    Map<String, double> voteDict = {};
    for (int i = 0; i < qualifiedDictionary.length; i++) {
      voteDict[qualifiedDictionary[i]] = numberOfVotes[i];
    }

    // Suma głosów
    double freq = voteDict.values.fold(0.0, (prev, el) => prev + el);

    // Liczymy wszystkie metody
    final dhontResult = dhont({}, voteDict, seatsNum);
    final sainteResult = sainteLague({}, voteDict, seatsNum);
    final hareBig = hareDrop({}, voteDict, seatsNum, freq, biggest: true);
    final hareSmall = hareDrop({}, voteDict, seatsNum, freq, biggest: false);

    return {
      "d'Hondt": dhontResult,
      "Sainte-Laguë": sainteResult,
      "Kwota Hare’a (metoda największych reszt)": hareBig,
      "Kwota Hare’a (metoda najmniejszych reszt)": hareSmall,
    };
  }

  /// Metoda d'Hondt
  static Map<String, int> dhont(
    Map<String, int> seatsDict,
    Map<String, double> voteDict,
    int seatsNum,
  ) {
    // Bezpieczniki
    if (voteDict.isEmpty || seatsNum <= 0) {
      return seatsDict;
    }
    final double totalVotes = voteDict.values.fold(0.0, (p, c) => p + c);
    if (totalVotes == 0) {
      return seatsDict;
    }

    final copy = Map<String, double>.from(voteDict);

    for (int i = 0; i < seatsNum; i++) {
      final maxParty = copy.keys.reduce((a, b) => copy[a]! > copy[b]! ? a : b);
      seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;
      copy[maxParty] = voteDict[maxParty]! / (seatsDict[maxParty]! + 1);
    }
    return seatsDict;
  }

  /// Metoda Sainte-Laguë
  static Map<String, int> sainteLague(
    Map<String, int> seatsDict,
    Map<String, double> voteDict,
    int seatsNum,
  ) {
    if (voteDict.isEmpty || seatsNum <= 0) {
      return seatsDict;
    }
    final double totalVotes = voteDict.values.fold(0.0, (p, c) => p + c);
    if (totalVotes == 0) {
      return seatsDict;
    }

    final copy = Map<String, double>.from(voteDict);

    for (int i = 0; i < seatsNum; i++) {
      final maxParty = copy.keys.reduce((a, b) => copy[a]! > copy[b]! ? a : b);
      seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;
      copy[maxParty] = voteDict[maxParty]! / (2.0 * seatsDict[maxParty]! + 1.0);
    }
    return seatsDict;
  }

  /// Metoda Hare’a (największych / najmniejszych reszt)
  static Map<String, int> hareDrop(
    Map<String, int> seatsDict,
    Map<String, double> voteDict,
    int seatsNum,
    double freq, {
    required bool biggest,
  }) {
    if (voteDict.isEmpty || seatsNum <= 0) {
      return seatsDict;
    }
    final double totalVotes = voteDict.values.fold(0.0, (p, c) => p + c);
    if (totalVotes == 0) {
      return seatsDict;
    }

    final copy = Map<String, double>.from(voteDict);
    int remaining = seatsNum;

    // Podział bazowy
    copy.forEach((party, votes) {
      final value = (votes * seatsNum) / freq;
      final baseSeats = value.floor();
      seatsDict[party] = baseSeats;
      copy[party] = value - baseSeats;
      remaining -= baseSeats;
    });

    // Rozdział reszt
    for (int i = 0; i < remaining; i++) {
      if (biggest) {
        final maxParty =
            copy.keys.reduce((a, b) => copy[a]! > copy[b]! ? a : b);
        seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;
        copy[maxParty] = 0.0;
      } else {
        final minParty =
            copy.keys.reduce((a, b) => copy[a]! < copy[b]! ? a : b);
        seatsDict[minParty] = (seatsDict[minParty] ?? 0) + 1;
        copy[minParty] = double.infinity;
      }
    }
    return seatsDict;
  }

  /// Metoda Zmodyfikowany Sainte-Laguë
  static Map<String, int> modifiedSainteLague(
    Map<String, int> seatsDict,
    Map<String, double> voteDict,
    int seatsNum,
  ) {
    if (voteDict.isEmpty || seatsNum <= 0) {
      return seatsDict;
    }
    final double totalVotes = voteDict.values.fold(0.0, (p, c) => p + c);
    if (totalVotes == 0) {
      return seatsDict;
    }

    final copy = Map<String, double>.from(voteDict);

    for (int i = 0; i < seatsNum; i++) {
      final maxParty = copy.keys.reduce((a, b) => copy[a]! > copy[b]! ? a : b);
      seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;

      if (seatsDict[maxParty] == 1) {
        // pierwszy mandat dzielimy przez 1.4
        copy[maxParty] = voteDict[maxParty]! / 3.0;
      } else {
        double nextDivisor = (seatsDict[maxParty]! * 2) + 1.0;
        copy[maxParty] = voteDict[maxParty]! / nextDivisor;
      }
    }
    return seatsDict;
  }

  /// Funkcja licząca, które partie przekroczyły progi wyborcze – na potrzeby
  /// RealElectionCalculatorTab
  static Map<String, dynamic> calculateVotesFromCsv({
    required List<CsvRow> csvData,
    required double threshold,
    required double coalitionThreshold,
    required List<String> exemptedParties,
  }) {
    // Zsumuj głosy dla wszystkich kolumn
    final Map<String, double> totalVotes = {};
    double allVotes = 0;

    for (var row in csvData) {
      row.data.forEach((party, votes) {
        totalVotes[party] = (totalVotes[party] ?? 0) + votes;
        allVotes += votes;
      });
    }

    // Sprawdzamy progi
    final qualifiedParties = <String>[];
    totalVotes.forEach((party, votes) {
      if (exemptedParties.contains(party)) {
        qualifiedParties.add(party);
      } else {
        final percent = (votes / (allVotes == 0 ? 1 : allVotes)) * 100.0;
        if (party.toUpperCase().contains("KOALICYJNY") ||
            party.toUpperCase().contains("KOALICJA")) {
          // Koalicyjny komitet
          if (percent >= coalitionThreshold) {
            qualifiedParties.add(party);
          }
        } else {
          // Zwykły komitet
          if (percent >= threshold) {
            qualifiedParties.add(party);
          }
        }
      }
    });

    // Głosy tylko tych, co przeszli
    final receivedVotes =
        qualifiedParties.map((p) => totalVotes[p] ?? 0.0).toList();

    return {
      "allVotes": allVotes,
      "totalVotes": totalVotes,
      "qualifiedParties": qualifiedParties,
      "receivedVotes": receivedVotes,
    };
  }
}
