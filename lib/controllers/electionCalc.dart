// controllers/electionCalc.dart
import 'dart:math' as math;

/// Struktura przykładowego wiersza danych (odpowiednik jednego `district` w Pythonie).
/// Zawiera klucz `Liczba głosów ważnych oddanych łącznie na wszystkie listy kandydatów`
/// oraz nazwy kolumn z komitetami.
class CsvRow {
  final Map<String, double> data;

  CsvRow(this.data);
}

/// Główna funkcja licząca, które komitety przekroczyły progi.
Map<String, dynamic> calculateVotes({
  required double votesNeeded,
  required double votesNeededForCoalition,
  required String year,
  required List<CsvRow> csvData,
}) {
  String realYear = year == "2023" ? "" : "_$year";
  final Map<String, double> votes = {"Frekwencja": 0.0};
  final List<String> clubsWithSeats = [];
  final List<double> receivedVotes = [];

  if (csvData.isNotEmpty) {
    final firstRow = csvData.first.data;
    for (var columnName in firstRow.keys) {
      if (columnName.toUpperCase().contains("KOMITET")) {
        votes[columnName] = 0.0;
      }
    }
  }

  for (var row in csvData) {
    for (var columnName in row.data.keys) {
      if (columnName.toUpperCase().contains("KOMITET")) {
        votes[columnName] =
            (votes[columnName] ?? 0.0) + (row.data[columnName] ?? 0.0);
      }
    }

    final validVotes = row.data[
            "Liczba głosów ważnych oddanych łącznie na wszystkie listy kandydatów"] ??
        0.0;
    receivedVotes.add(validVotes);
    votes["Frekwencja"] = (votes["Frekwencja"] ?? 0.0) + validVotes;
  }

  final totalVotes = votes["Frekwencja"] ?? 1.0;
  votes.forEach((key, val) {
    if (key == "Frekwencja") return;
    final result = (val * 100.0) / totalVotes;
    if (result >= votesNeeded) {
      // Sprawdzamy, czy to komitet koalicyjny
      if (key.toUpperCase().contains("KOALICYJNY")) {
        if (result >= votesNeededForCoalition) {
          clubsWithSeats.add(key);
        }
      } else {
        clubsWithSeats.add(key);
      }
    }
  });

  return {
    "ClubsWithSeats": clubsWithSeats,
    "votes": votes,
    "receivedVotes": receivedVotes,
  };
}

/// Funkcja wybierająca jedną z kilku metod podziału mandatów.
/// Zwraca mapę z 5 kluczami – nazwami metod (każdy klucz to podmapa z rozdziałem mandatów).
Map<String, Map<String, int>> chooseMethod({
  required List<String> qualifiedDictionary,
  required List<double> numberOfVotes,
  required String year,
  required List<CsvRow> csvData,
}) {
  if (qualifiedDictionary.isEmpty) {
    return {};
  }

  final Map<String, int> seatDictAll = {};
  final Map<String, int> seatDict = {};
  final Map<String, double> voteDict = {};
  final Map<double, String> reversedVoteDict = {};

  for (var element in qualifiedDictionary) {
    seatDict[element] = 0;
    voteDict[element] = 0.0;
    seatDictAll[element] = 0;
  }

  // Przykładowa liczba mandatów w poszczególnych okręgach (dla uproszczenia):
  final List<int> seats = [
    12,
    8,
    14,
    12,
    13,
    15,
    12,
    12,
    10,
    9,
    12,
    8,
    14,
    10,
    9,
    10,
    9,
    12,
    20,
    12,
    12,
    11,
    15,
    14,
    12,
    14,
    9,
    7,
    9,
    9,
    12,
    9,
    16,
    8,
    10,
    12,
    9,
    9,
    10,
    8,
    12
  ];

  // Dostosowanie liczby mandatów do starszych lat
  final int? yearInt = int.tryParse(year);
  if (yearInt != null && yearInt <= 2007) {
    seats[12] -= 1;
    seats[13] -= 1;
    seats[18] -= 1;
    seats[19] -= 1;
    seats[20] += 1;
    seats[23] += 1;
    seats[28] += 1;
    if (yearInt <= 2001) {
      // ewentualne dalsze modyfikacje
    }
  }

  final Map<String, Map<String, int>> methodDict = {
    "dhont": {},
    "Zmodyfikowany Sainte-Laguë": {},
    "Sainte-Laguë": {},
    "Kwota Kwota Hare’a (metoda największych reszt)": {},
    "Kwota Hare’a (metoda najmniejszych reszt)": {},
  };

  int distictIndex = 0;
  for (var row in csvData) {
    for (var party in qualifiedDictionary) {
      voteDict[party] = row.data[party] ?? 0.0;
      reversedVoteDict[row.data[party] ?? 0.0] = party;
    }
    final seatsForThisDistrict =
        (distictIndex < seats.length) ? seats[distictIndex] : 0;

    // 1) d'Hondt
    final tempDictDhont = Map<String, int>.from(seatDict);
    final recivedSeatsDhont =
        dhont(tempDictDhont, voteDict, seatsForThisDistrict);
    recivedSeatsDhont.forEach((k, v) {
      methodDict["dhont"]![k] = (methodDict["dhont"]![k] ?? 0) + v;
    });

    // 2) Sainte-Laguë
    final tempDictSainte = Map<String, int>.from(seatDict);
    final recivedSeatsSainte =
        sainteLague(tempDictSainte, voteDict, seatsForThisDistrict);
    recivedSeatsSainte.forEach((k, v) {
      methodDict["Sainte-Laguë"]![k] =
          (methodDict["Sainte-Laguë"]![k] ?? 0) + v;
    });

    // 3) Kwota Hare’a (metoda największych reszt)
    final tempDictHareBig = Map<String, int>.from(seatDict);
    final recivedSeatsHareBig = hareDrop(
      tempDictHareBig,
      voteDict,
      seatsForThisDistrict,
      numberOfVotes[distictIndex],
      biggest: true,
    );
    recivedSeatsHareBig.forEach((k, v) {
      methodDict["Kwota Kwota Hare’a (metoda największych reszt)"]![k] =
          (methodDict["Kwota Kwota Hare’a (metoda największych reszt)"]![k] ??
                  0) +
              v;
    });

    // 4) Kwota Hare’a (metoda najmniejszych reszt)
    final tempDictHareSmall = Map<String, int>.from(seatDict);
    final recivedSeatsHareSmall = hareDrop(
      tempDictHareSmall,
      voteDict,
      seatsForThisDistrict,
      numberOfVotes[distictIndex],
      biggest: false,
    );
    recivedSeatsHareSmall.forEach((k, v) {
      methodDict["Kwota Hare’a (metoda najmniejszych reszt)"]![k] =
          (methodDict["Kwota Hare’a (metoda najmniejszych reszt)"]![k] ?? 0) +
              v;
    });

    // 5) Zmodyfikowany Sainte-Laguë
    final tempDictModified = Map<String, int>.from(seatDict);
    final recivedSeatsModified =
        modifiedSainteLague(tempDictModified, voteDict, seatsForThisDistrict);
    recivedSeatsModified.forEach((k, v) {
      methodDict["Zmodyfikowany Sainte-Laguë"]![k] =
          (methodDict["Zmodyfikowany Sainte-Laguë"]![k] ?? 0) + v;
    });

    distictIndex++;
  }

  return methodDict;
}

/// Metoda Zmodyfikowany Sainte-Laguë
Map<String, int> modifiedSainteLague(
  Map<String, int> seatsDict,
  Map<String, double> voteDict,
  int seatsNum,
) {
  final voteDictCopy = Map<String, double>.from(voteDict);

  for (int i = 0; i < seatsNum; i++) {
    final maxParty = voteDictCopy.keys.reduce((curr, next) =>
        voteDictCopy[curr]! > voteDictCopy[next]! ? curr : next);

    seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;

    if (seatsDict[maxParty] == 1) {
      voteDictCopy[maxParty] = voteDict[maxParty]! / 1.4;
    } else {
      voteDictCopy[maxParty] =
          voteDict[maxParty]! / (2 * (seatsDict[maxParty]! - 1) + 1);
    }
  }
  return seatsDict;
}

/// Metoda Sainte-Laguë
Map<String, int> sainteLague(
  Map<String, int> seatsDict,
  Map<String, double> voteDict,
  int seatsNum,
) {
  final voteDictCopy = Map<String, double>.from(voteDict);

  for (int i = 0; i < seatsNum; i++) {
    final maxParty = voteDictCopy.keys.reduce((curr, next) =>
        voteDictCopy[curr]! > voteDictCopy[next]! ? curr : next);

    seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;

    // Dzielnik 2n+1
    voteDictCopy[maxParty] =
        voteDict[maxParty]! / (2.0 * seatsDict[maxParty]! + 1.0);
  }

  return seatsDict;
}

/// Metoda d'Hondta
Map<String, int> dhont(
  Map<String, int> seatsDict,
  Map<String, double> voteDict,
  int seatsNum,
) {
  final voteDictCopy = Map<String, double>.from(voteDict);

  for (int i = 0; i < seatsNum; i++) {
    final maxParty = voteDictCopy.keys.reduce((curr, next) =>
        voteDictCopy[curr]! > voteDictCopy[next]! ? curr : next);

    seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;

    voteDictCopy[maxParty] = voteDict[maxParty]! / (seatsDict[maxParty]! + 1.0);
  }

  return seatsDict;
}

/// Kwota Hare’a (metoda największych lub najmniejszych reszt).
Map<String, int> hareDrop(
  Map<String, int> seatsDict,
  Map<String, double> voteDict,
  int seatsNum,
  double freq, {
  required bool biggest,
}) {
  final voteDictCopy = Map<String, double>.from(voteDict);
  int remainingSeats = seatsNum;

  // 1. Każdej partii przypisujemy "podstawowe" mandaty = floor((partia_glosy * seatsNum) / freq)
  voteDictCopy.forEach((party, votes) {
    final value = (votes * seatsNum) / freq;
    final baseSeats = value.floor();
    seatsDict[party] = baseSeats;
    voteDictCopy[party] = value - baseSeats; // reszta
    remainingSeats -= baseSeats;
  });

  // 2. Rozdzielamy pozostałe mandaty wg. największych / najmniejszych reszt
  for (int i = 0; i < remainingSeats; i++) {
    if (biggest) {
      // Metoda największych reszt: wybieramy partię z najwyższą resztą
      final maxParty = voteDictCopy.keys.reduce((curr, next) =>
          voteDictCopy[curr]! > voteDictCopy[next]! ? curr : next);
      seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;
      voteDictCopy[maxParty] = 0.0; // "wyzerowujemy" resztę
    } else {
      // Metoda najmniejszych reszt: wybieramy partię z najniższą (ale dodatnią) resztą
      // (jeśli w resztach są same zera, to i tak wszystkie równe – można dodać mandat "pierwszej z listy")
      final minParty = voteDictCopy.keys.reduce((curr, next) =>
          voteDictCopy[curr]! < voteDictCopy[next]! ? curr : next);
      seatsDict[minParty] = (seatsDict[minParty] ?? 0) + 1;
      // Aby "ominąć" tę partię w kolejnej iteracji
      voteDictCopy[minParty] = double.infinity;
    }
  }

  return seatsDict;
}
