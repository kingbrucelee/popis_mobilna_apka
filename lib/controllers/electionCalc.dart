import 'dart:math' as math;

/// Model jednego wiersza z CSV (np. dane o jednym okręgu)
class CsvRow {
  final Map<String, double> data;
  CsvRow(this.data);
}

/// Klasa ElectionCalc zawiera metody do obliczeń wyborczych
class ElectionCalc {
  /// Metoda do zsumowania głosów z listy CsvRow
  /// i zwrócenia łącznych głosów w postaci mapy {partia -> sumaGłosów}.
  /// Dodatkowo zwraca sumę wszystkich głosów (frekwencja).
  static Map<String, dynamic> sumVotesFromCsv(List<CsvRow> csvData) {
    final Map<String, double> totalVotes = {};
    double allVotes = 0.0;

    for (final row in csvData) {
      row.data.forEach((party, votes) {
        totalVotes[party] = (totalVotes[party] ?? 0) + votes;
        allVotes += votes;
      });
    }

    return {
      "allVotes": allVotes,
      "totalVotes": totalVotes,
    };
  }

  /// Metoda bazowa do sprawdzania, kto przekroczył progi
  static Map<String, dynamic> calculateVotesFromCsv({
    required List<CsvRow> csvData,
    required double threshold,
    required double coalitionThreshold,
    required List<String> exemptedParties,
  }) {
    final Map<String, dynamic> sumMap = sumVotesFromCsv(csvData);
    final double allVotes = sumMap["allVotes"];
    final Map<String, double> totalVotes =
        (sumMap["totalVotes"] as Map<String, double>);

    // Sprawdzamy progi:
    final qualifiedParties = <String>[];
    totalVotes.forEach((party, votes) {
      if (exemptedParties.contains(party)) {
        qualifiedParties.add(party);
      } else {
        final percent = allVotes == 0 ? 0 : (votes / allVotes) * 100.0;
        final upperParty = party.toUpperCase();
        // Koalicyjny?
        if (upperParty.contains("KOALICYJNY") ||
            upperParty.contains("KOALICJA")) {
          if (percent >= coalitionThreshold) {
            qualifiedParties.add(party);
          }
        } else {
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

  /// -----------------------
  /// Metody liczące podział mandatów (d'Hondt, Sainte-Laguë, Hare)
  /// -----------------------
  static Map<String, int> dhont(
    Map<String, int> seatsDict,
    Map<String, double> voteDict,
    int seatsNum,
  ) {
    if (voteDict.isEmpty || seatsNum <= 0) return seatsDict;

    // Kopiujemy głosy, by nie modyfikować oryginału
    final Map<String, double> quotient = Map.from(voteDict);
    // Inicjuj liczbę miejsc dla każdej partii
    voteDict.keys.forEach((key) => seatsDict[key] = seatsDict[key] ?? 0);

    for (int i = 0; i < seatsNum; i++) {
      final winner =
          quotient.keys.reduce((a, b) => quotient[a]! > quotient[b]! ? a : b);
      seatsDict[winner] = (seatsDict[winner] ?? 0) + 1;
      quotient[winner] = voteDict[winner]! / (seatsDict[winner]! + 1);
    }

    return seatsDict;
  }

  static Map<String, int> sainteLague(
    Map<String, int> seatsDict,
    Map<String, double> voteDict,
    int seatsNum,
  ) {
    if (voteDict.isEmpty || seatsNum <= 0) return seatsDict;

    final Map<String, double> copy = Map.from(voteDict);
    voteDict.keys.forEach((key) => seatsDict[key] = seatsDict[key] ?? 0);

    for (int i = 0; i < seatsNum; i++) {
      final maxParty = copy.keys.reduce((a, b) => copy[a]! > copy[b]! ? a : b);
      seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;
      copy[maxParty] = voteDict[maxParty]! / (2 * seatsDict[maxParty]! + 1);
    }

    return seatsDict;
  }

  static Map<String, int> modifiedSainteLague(
    Map<String, int> seatsDict,
    Map<String, double> voteDict,
    int seatsNum,
  ) {
    if (voteDict.isEmpty || seatsNum <= 0) return seatsDict;

    final Map<String, double> copy = Map.from(voteDict);
    voteDict.keys.forEach((key) => seatsDict[key] = 0);

    for (int i = 0; i < seatsNum; i++) {
      final maxParty = copy.keys.reduce((a, b) => copy[a]! > copy[b]! ? a : b);
      seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;

      if (seatsDict[maxParty] == 1) {
        // pierwszy mandat – dzielimy przez 1.4
        copy[maxParty] = voteDict[maxParty]! / 1.4;
      } else {
        final divisor = (2 * (seatsDict[maxParty]! - 1)) + 1;
        copy[maxParty] = voteDict[maxParty]! / divisor;
      }
    }

    return seatsDict;
  }

  static Map<String, int> hareDrop(
    Map<String, int> seatsDict,
    Map<String, double> voteDict,
    int seatsNum,
    double freq, {
    required bool biggest,
  }) {
    if (voteDict.isEmpty || seatsNum <= 0 || freq == 0) return seatsDict;

    voteDict.keys.forEach((key) => seatsDict[key] = 0);
    final Map<String, double> remainders = {};
    int assignedSeats = 0;

    // Najpierw obliczamy udział
    voteDict.forEach((party, votes) {
      final seatFraction = (votes * seatsNum) / freq;
      final baseSeats = seatFraction.floor();
      seatsDict[party] = baseSeats;
      remainders[party] = seatFraction - baseSeats;
      assignedSeats += baseSeats;
    });

    // Rozdajemy pozostałe mandaty wg największych/najmniejszych reszt
    while (assignedSeats < seatsNum) {
      final chosenParty = biggest
          ? remainders.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : remainders.entries.reduce((a, b) => a.value < b.value ? a : b).key;

      seatsDict[chosenParty] = (seatsDict[chosenParty] ?? 0) + 1;
      if (biggest) {
        // przy największych resztach – zerujemy, by partia nie otrzymała kolejnego
        remainders[chosenParty] = 0;
      } else {
        // przy najmniejszych resztach – wstawiamy infinity, by partia nie otrzymała kolejnego
        remainders[chosenParty] = double.infinity;
      }
      assignedSeats++;
    }

    return seatsDict;
  }

  /// Jednorazowe liczenie 4–5 głównych metod (d'Hondt, Sainte-Laguë, Hare itd.)
  static Map<String, Map<String, int>> chooseMethod({
    required List<String> qualifiedDictionary,
    required List<double> numberOfVotes,
    required String year,
    required int seatsNum,
  }) {
    if (qualifiedDictionary.isEmpty) return {};

    final voteDict = <String, double>{};
    for (int i = 0; i < qualifiedDictionary.length; i++) {
      voteDict[qualifiedDictionary[i]] = numberOfVotes[i];
    }

    final freq = voteDict.values.fold(0.0, (p, c) => p + c);

    final dhontResult = dhont({}, voteDict, seatsNum);
    final sainteResult = sainteLague({}, voteDict, seatsNum);
    final hareBig = hareDrop({}, voteDict, seatsNum, freq, biggest: true);
    final hareSmall = hareDrop({}, voteDict, seatsNum, freq, biggest: false);
    final modSainte = modifiedSainteLague({}, voteDict, seatsNum);

    return {
      "d'Hondt": dhontResult,
      "Sainte-Laguë": sainteResult,
      "Zmodyfikowany Sainte-Laguë": modSainte,
      "Kwota Hare’a (metoda największych reszt)": hareBig,
      "Kwota Hare’a (metoda najmniejszych reszt)": hareSmall,
    };
  }

  /// Liczenie po okręgach – sumuje wyniki ze wszystkich okręgów
  static Map<String, Map<String, int>> chooseMethodByDistricts({
    required List<CsvRow> csvData,
    required List<String> qualifiedParties,
    required List<int> seatsPerDistrict,
    required String year,
  }) {
    final Map<String, Map<String, int>> finalResults = {
      "d'Hondt": {},
      "Sainte-Laguë": {},
      "Zmodyfikowany Sainte-Laguë": {},
      "Kwota Hare’a (metoda największych reszt)": {},
      "Kwota Hare’a (metoda najmniejszych reszt)": {},
    };

    for (var methodKey in finalResults.keys) {
      for (final party in qualifiedParties) {
        finalResults[methodKey]![party] = 0;
      }
    }

    // seatsPerDistrict.length musi odpowiadać csvData.length w idealnym scenariuszu
    for (int i = 0; i < csvData.length; i++) {
      final row = csvData[i];
      final seatsNum = seatsPerDistrict[i];
      final voteDict = <String, double>{};

      for (final party in qualifiedParties) {
        voteDict[party] = row.data[party] ?? 0;
      }

      final freq = voteDict.values.fold(0.0, (p, c) => p + c);

      // d'Hondt
      final dHondtLocal = dhont({}, voteDict, seatsNum);
      dHondtLocal.forEach((party, seats) {
        finalResults["d'Hondt"]![party] =
            (finalResults["d'Hondt"]![party] ?? 0) + seats;
      });

      // Sainte-Laguë
      final slLocal = sainteLague({}, voteDict, seatsNum);
      slLocal.forEach((party, seats) {
        finalResults["Sainte-Laguë"]![party] =
            (finalResults["Sainte-Laguë"]![party] ?? 0) + seats;
      });

      // Zmodyfikowany Sainte-Laguë
      final modSlLocal = modifiedSainteLague({}, voteDict, seatsNum);
      modSlLocal.forEach((party, seats) {
        finalResults["Zmodyfikowany Sainte-Laguë"]![party] =
            (finalResults["Zmodyfikowany Sainte-Laguë"]![party] ?? 0) + seats;
      });

      // Hare (największe reszty)
      final hareBigLocal =
          hareDrop({}, voteDict, seatsNum, freq, biggest: true);
      hareBigLocal.forEach((party, seats) {
        finalResults["Kwota Hare’a (metoda największych reszt)"]![party] =
            (finalResults["Kwota Hare’a (metoda największych reszt)"]![party] ??
                    0) +
                seats;
      });

      // Hare (najmniejsze reszty)
      final hareSmallLocal =
          hareDrop({}, voteDict, seatsNum, freq, biggest: false);
      hareSmallLocal.forEach((party, seats) {
        finalResults["Kwota Hare’a (metoda najmniejszych reszt)"]![party] =
            (finalResults["Kwota Hare’a (metoda najmniejszych reszt)"]![
                        party] ??
                    0) +
                seats;
      });
    }

    return finalResults;
  }

  /// Metoda do wyboru jednej metody (zwraca [mapMandatów, nextDiff, prevDiff])
  static List<dynamic> specialChooseMethod({
    required Map<String, double> voteDict,
    required int seatsNum,
    required String method,
    required double freq,
  }) {
    final normalSeats = <String, int>{};
    final nextSeatsMap = <String, int>{};
    final prevSeatsMap = <String, int>{};

    for (final party in voteDict.keys) {
      normalSeats[party] = 0;
      nextSeatsMap[party] = 0;
      prevSeatsMap[party] = 0;
    }

    final totalVotes = voteDict.values.fold(0.0, (p, c) => p + c);
    if (totalVotes == 0 || seatsNum <= 0) {
      return [normalSeats, <String>{}, <String>{}];
    }

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
      case "Zmodyfikowany Sainte-Laguë":
        modifiedSainteLague(normalSeats, voteDict, seatsNum);
        modifiedSainteLague(nextSeatsMap, voteDict, seatsNum + 1);
        if (seatsNum - 1 > 0) {
          modifiedSainteLague(prevSeatsMap, voteDict, seatsNum - 1);
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
}
